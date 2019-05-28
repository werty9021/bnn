import numpy as np
import os

size = (481, 321)
size = (50, 50)
size = (5, 5)
for filename in sorted(os.listdir('../data/output/')):
    suffix = filename.split('.')[0]
    if suffix in ['conv0', 'conv16', 'act15']:
        ref_dtype = np.float32
        out_dtype = np.float32
    elif 'conv' in suffix:
        ref_dtype = np.float32
        out_dtype = np.uint32
    else:
        ref_dtype = out_dtype = np.uint32

    if 'act' in suffix and suffix != 'act15':
        ref = np.fromfile('../data/ref/{}x{}/{}.bin'.format(size[0], size[1], suffix), dtype=ref_dtype)
        out = np.fromfile('../data/output/{}.bin'.format(suffix), dtype=out_dtype)
        # ref=ref.reshape((64,*size))
        # out=out.reshape((64,*size))
        # print(ref[8])
        # print(out[8])
        # for i in range(64):
        #     print((ref[i]-out[i]).sum())
        for i in range(5):
            print(bin(ref[i]), " ", end='')
        print("\n")
        for i in range(5):
            print(bin(out[i]), " ", end='')
        print("\n")
        mean = np.bitwise_xor(ref, out).mean()

    elif 'conv' in suffix and suffix not in ['conv0', 'conv16']:
        ref = np.fromfile('../data/ref/{}x{}/{}.bin'.format(size[0], size[1], suffix), dtype=ref_dtype).reshape((64, *size))
        out = np.fromfile('../data/output/{}.bin'.format(suffix), dtype=out_dtype).reshape((64, *size))
        # out2=out
        out2 = np.zeros_like(out,dtype=np.int32)
        for k in range(0, 64):
            for j in range(0, size[0]):
                for i in range(0, size[1]):
                    T = 9*64
                    if (i==0 or i==size[1]-1):
                        T -= 3*64;
                    if (j==0 or j==size[0]-1):
                        T -= 3*64;
                    if ((j==0 and i==0) or (j==size[0]-1 and i==0) or (j==0 and i==size[1]-1) or (j==size[0]-1 and i==size[1]-1)):
                        T += 1*64;
                    out2[k,j,i] = 2*out[k,j,i] - T
        print(ref[8])
        print(out2[8])
        print((ref==out2).mean())
        mean = (ref-out2).mean()
    # else:
        # if suffix not in ['conv0', 'conv16']:
        #     # ref = np.fromfile('../data/ref/{}.bin'.format(suffix), dtype=ref_dtype).reshape((64, 5,5))
        #     # out = np.fromfile('../data/output/{}.bin'.format(suffix), dtype=out_dtype).reshape((64, 5,5))
        #     # out2 = np.zeros_like(out,dtype=np.int32)
        #     # for k in range(0, 64):
        #     #     for j in range(0, 5):
        #     #         for i in range(0, 5):
        #     #             T = 9*64
        #     #             if (i==0 or i==4):
        #     #                 T -= 3*64;
        #     #             if (j==0 or j==4):
        #     #                 T -= 3*64;
        #     #             if ((j==0 and i==0) or (j==4 and i==0) or (j==0 and i==4) or (j==4 and i==4)):
        #     #                 T += 1*64;
        #     #             out2[k,j,i] = 2*out[k,j,i] - T
        #     # print(ref[3])
        #     # print(out2[3])
        #     # mean = (ref-out2).mean()
    else:
        ref = np.fromfile('../data/ref/{}x{}/{}.bin'.format(size[0], size[1], suffix), dtype=ref_dtype)
        out = np.fromfile('../data/output/{}.bin'.format(suffix), dtype=out_dtype)
        print(ref[:10])
        print(out[:10])
        mean = (ref-out).mean()
    print("{} mean diff: {}\n".format(suffix, mean))

