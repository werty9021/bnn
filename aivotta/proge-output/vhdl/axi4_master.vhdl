library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity read_channel_axi4_master is
  generic (
    data_width_g          : integer := 32;
    addr_width_g          : integer := 32
  );
  port (
    -- Global signals:
    clk          : in std_logic;
    rstx         : in std_logic;

    -- AXI4 Read address channel
    m_axi_araddr  : out std_logic_vector(addr_width_g - 1 downto 0);
    m_axi_arcache : out std_logic_vector(4 - 1 downto 0);
    m_axi_arlen   : out std_logic_vector(8 - 1 downto 0);
    m_axi_arsize  : out std_logic_vector(3 - 1 downto 0);
    m_axi_arburst : out std_logic_vector(2 - 1 downto 0);
    m_axi_arprot  : out std_logic_vector(3 - 1 downto 0);
    m_axi_arvalid : out std_logic;
    m_axi_arready : in  std_logic;
    -- AXI4 Read channel
    m_axi_rdata   : in  std_logic_vector(data_width_g - 1 downto 0);
    --m_axi_rresp   : in std_logic_vector(2 - 1 downto 0);
    m_axi_rvalid  : in  std_logic;
    m_axi_rlast   : in  std_logic;
    m_axi_rready  : out std_logic;

    -- Control interface
    data_out         : out std_logic_vector(data_width_g - 1 downto 0);
    data_valid_out   : out std_logic;
    data_ready_in    : in std_logic;
    data_last_out    : out std_logic;
    ar_ack_out       : out std_logic;

    cmd_valid_in     : in std_logic;
    cmd_length_in    : in std_logic_vector(8 - 1 downto 0);
    cmd_address_in   : in std_logic_vector(addr_width_g - 1 downto 0);
    cmd_ready_out      : out std_logic;

    ready_out        : out std_logic;
    init_done_out    : out std_logic
);
end read_channel_axi4_master;

architecture rtl of read_channel_axi4_master is
  constant byte_count_log2_c : integer := integer(log2(real(data_width_g/8)));

  type   read_state_t is (S_READY, S_WAITARREADY, S_READDATA);
  signal read_state  : read_state_t;

  signal read_iter_r        : unsigned(m_axi_arlen'range);
  signal m_axi_rready_r     : std_logic;
  signal data_r             : std_logic_vector(data_width_g-1 downto 0);
  signal data_valid_r       : std_logic;
  signal data_last_r        : std_logic;
  signal stall_data_r       : std_logic_vector(data_width_g-1 downto 0);
  signal stall_data_valid_r : std_logic;
  signal stall_data_last_r  : std_logic;
  signal cmd_ack_r          : std_logic;
  signal ar_acknowledged_r  : std_logic;
begin

  m_axi_rready <= m_axi_rready_r;

  m_axi_arprot  <= "000"; -- Unprivileged, secure data access
  m_axi_arcache <= "0011"; -- Normal, non-cacheable, modifiable,  bufferable
  m_axi_arburst <= "01"; -- INCR, i.e. sequential addresses
  m_axi_arsize  <= std_logic_vector(to_unsigned(byte_count_log2_c,3));

  ready_out     <= '1' when read_state = S_READY else '0';
  init_done_out <= '1' when read_state = S_READDATA else '0';

  data_out        <= data_r;
  data_valid_out  <= data_valid_r;
  data_last_out   <= data_last_r;
  cmd_ready_out   <= cmd_ack_r;
  ar_ack_out      <= ar_acknowledged_r;

  axi_read_sm : process(clk, rstx)
  begin
    if (rstx = '0') then
      m_axi_araddr    <= (others => '0');
      m_axi_arlen     <= (others => '0');
      m_axi_arvalid   <= '0';
      m_axi_rready_r  <= '0';

      read_state      <= S_READY;
      read_iter_r     <= (others => '0');

      data_r             <= (others => '0');
      data_valid_r       <= '0';
      stall_data_r       <= (others => '0');
      stall_data_valid_r <= '0';
      cmd_ack_r          <= '0';
      data_last_r        <= '0';
      ar_acknowledged_r  <= '0';
    elsif rising_edge(clk) then
      cmd_ack_r <= '0';
      ar_acknowledged_r  <= '0';
      if data_valid_r = '1' and data_ready_in = '1' then
        if stall_data_valid_r = '1' then
          stall_data_valid_r <= '0';
          data_r <= stall_data_r;
          data_last_r <= stall_data_last_r;
        else
          data_valid_r <= '0';
        end if;
      end if;

      case read_state is
        when S_READY =>
          if cmd_valid_in = '1' then
            m_axi_araddr  <= cmd_address_in;
            read_iter_r   <= unsigned(cmd_length_in);
            m_axi_arlen   <= cmd_length_in;
            m_axi_arvalid <= '1';
            cmd_ack_r     <= '1';

            read_state      <= S_WAITARREADY;
          end if;

        when S_WAITARREADY =>
          if m_axi_arready  = '1' then
            m_axi_arvalid      <= '0';
            read_state         <= S_READDATA;
            m_axi_rready_r     <= not stall_data_valid_r;
            ar_acknowledged_r  <= '1';
          end if;

        when S_READDATA =>
          m_axi_rready_r  <= not (stall_data_valid_r or (m_axi_rvalid and m_axi_rready_r and data_valid_r)) or data_ready_in;
          if m_axi_rvalid = '1' and m_axi_rready_r = '1' then
            if data_valid_r = '1' and (data_ready_in = '0' or stall_data_valid_r = '1') then
              stall_data_r       <= m_axi_rdata;
              stall_data_valid_r <= '1';
              stall_data_last_r  <= m_axi_rlast;
            else
              data_r           <= m_axi_rdata;
              data_valid_r     <= '1';
              data_last_r      <= m_axi_rlast;
            end if;

            if read_iter_r = 0 then
              read_state <= S_READY;
              m_axi_rready_r <= '0';
            else
              read_iter_r <= read_iter_r - 1;
            end if;
          end if;

      end case;
    end if;
  end process;

end rtl;

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity write_channel_axi4_master is
  generic (
    data_width_g          : integer := 32;
    addr_width_g          : integer := 32
  );
  port (
    -- Global signals:
    clk          : in std_logic;
    rstx         : in std_logic;

    -- AXI4 Write address channel:
    m_axi_awaddr  : out std_logic_vector(addr_width_g - 1 downto 0);
    m_axi_awcache : out std_logic_vector(4 - 1 downto 0);
    m_axi_awlen   : out std_logic_vector(8 - 1 downto 0);
    m_axi_awsize  : out std_logic_vector(3 - 1 downto 0);
    m_axi_awburst : out std_logic_vector(2 - 1 downto 0);
    m_axi_awprot  : out std_logic_vector(3 - 1 downto 0);
    m_axi_awvalid : out std_logic;
    m_axi_awready : in  std_logic;
    -- AXI4 Write channel:
    m_axi_wdata   : out std_logic_vector(data_width_g - 1 downto 0);
    m_axi_wstrb   : out std_logic_vector(data_width_g/8 - 1 downto 0);
    m_axi_wlast   : out std_logic;
    m_axi_wvalid  : out std_logic;
    m_axi_wready  : in  std_logic;
    -- AXI4 Write response channel
    -- m_axi_bresp : in std_logic_vector(2 - 1 downto 0);
    m_axi_bvalid  : in  std_logic;
    m_axi_bready  : out std_logic;

    -- Control interface
    data_in          : in std_logic_vector(data_width_g - 1 downto 0);
    data_valid_in    : in std_logic;
    data_ready_out     : out std_logic;

    cmd_valid_in       : in std_logic;
    cmd_length_in      : in std_logic_vector(8 - 1 downto 0);
    cmd_address_in     : in std_logic_vector(addr_width_g - 1 downto 0);
    cmd_wstrb_first_in : in std_logic_vector(data_width_g/8 - 1 downto 0);
    cmd_wstrb_last_in  : in std_logic_vector(data_width_g/8 - 1 downto 0);
    cmd_ready_out        : out std_logic;

    ready_out        : out std_logic
);
end write_channel_axi4_master;

architecture rtl of write_channel_axi4_master is
  constant byte_count_c : integer := data_width_g/8;
  constant byte_count_log2_c : integer := integer(log2(real(byte_count_c)));

  type   write_state_t is (S_READY, S_WAITAWREADY, S_WRITEDATA);
  signal write_state  : write_state_t;

  signal wstrb_last_r   : std_logic_vector(m_axi_wstrb'range);
  signal write_iter_r   : unsigned(m_axi_awlen'range);
  signal m_axi_wvalid_r : std_logic;
  signal m_axi_wstrb_r : std_logic_vector(m_axi_wstrb'range);
  signal data_ready_r     : std_logic;
  signal cmd_ack_r      : std_logic;
  signal write_data_valid : std_logic;
  signal write_data : std_logic_vector(data_width_g - 1 downto 0);
  signal data_valid_r : std_logic;
  signal data_r : std_logic_vector(data_width_g - 1 downto 0);
begin

  m_axi_awprot  <= "000"; -- Unprivileged, secure data access
  m_axi_awcache <= "0011"; -- Normal, non-cacheable, modifiable,  bufferable
  m_axi_awburst <= "01"; -- INCR, i.e. sequential addresses
  m_axi_awsize  <= std_logic_vector(to_unsigned(byte_count_log2_c, 3));
  -- Just ignore bresp
  m_axi_bready <= '1';

  cmd_ready_out  <= cmd_ack_r;
  m_axi_wvalid <= m_axi_wvalid_r;
  m_axi_wstrb  <= m_axi_wstrb_r;
  ready_out    <= '1' when write_state = S_READY else '0';

  m_axi_write_sync : process(clk, rstx)
    variable wstrb_tmp : std_logic_vector(m_axi_wstrb'range);
  begin
    if (rstx = '0') then
      m_axi_awaddr   <= (others => '0');
      m_axi_awlen    <= (others => '0');
      m_axi_awvalid  <= '0';
      m_axi_wvalid_r <= '0';
      m_axi_wlast    <= '0';
      m_axi_wstrb_r  <= (others => '0');
      m_axi_wdata    <= (others => '0');

      cmd_ack_r     <= '0';
      write_state   <= S_READY;
      write_iter_r  <= (others => '0');
      wstrb_last_r  <= (others => '0');
    elsif rising_edge(clk) then
      cmd_ack_r   <= '0';

      case write_state is
        when S_READY =>
          if cmd_valid_in = '1' then
            cmd_ack_r <= '1';
            m_axi_awaddr  <= cmd_address_in;
            m_axi_awlen   <= cmd_length_in;
            m_axi_wstrb_r <= cmd_wstrb_first_in;
            write_iter_r  <= unsigned(cmd_length_in);
            wstrb_last_r  <= cmd_wstrb_last_in;
            m_axi_awvalid <= '1';

            write_state   <= S_WAITAWREADY;
          end if;

        when S_WAITAWREADY =>
          if m_axi_awready = '1' then
              m_axi_awvalid    <= '0';
              write_state      <= S_WRITEDATA;
          end if;


        when S_WRITEDATA =>
          if m_axi_wready = '1' and m_axi_wvalid_r = '1' then

            if write_iter_r = 1 then
              wstrb_tmp := wstrb_last_r;
              m_axi_wlast <= '1';
            else
              wstrb_tmp := (others => '1');
            end if;
            m_axi_wstrb_r <= wstrb_tmp;

            if write_iter_r = 0 then
              write_state    <= S_READY;
              m_axi_wvalid_r <= '0';
              m_axi_wlast    <= '0';
            else
              write_iter_r <= write_iter_r - 1;
              if write_data_valid = '1' then
                for I in 0 to byte_count_c-1 loop
                  if wstrb_tmp(byte_count_c-I-1) = '0' then
                    m_axi_wdata(I*8+7 downto I*8) <= (others => '0');
                  else
                    m_axi_wdata(I*8+7 downto I*8) <= data_in(I*8+7 downto I*8);
                  end if;
                end loop;
                m_axi_wvalid_r <= '1';
              else
                m_axi_wvalid_r <= '0';
              end if;
            end if;
          elsif write_data_valid = '1' and m_axi_wvalid_r = '0' then
            for I in 0 to byte_count_c-1 loop
              if m_axi_wstrb_r(byte_count_c-I-1) = '0' then
                m_axi_wdata(I*8+7 downto I*8) <= (others => '0');
              else
                m_axi_wdata(I*8+7 downto I*8) <= data_in(I*8+7 downto I*8);
              end if;
            end loop;
            m_axi_wvalid_r <= '1';
            if write_iter_r = 0 then
              m_axi_wlast <= '1';
            end if;
          end if;
      end case;
    end if;
  end process m_axi_write_sync;

  m_axi_write_comb : process(write_state, m_axi_wvalid_r, write_iter_r, m_axi_wready, data_valid_in)
  begin
    if ((m_axi_wready = '1' and m_axi_wvalid_r = '1' and write_iter_r /= 0)
       or m_axi_wvalid_r = '0')
       and write_state = S_WRITEDATA then
      data_ready_out <= '1';
      write_data_valid <= data_valid_in;
    else
      data_ready_out   <= '0';
      write_data_valid <= '0';
    end if;
  end process m_axi_write_comb;

end rtl;
