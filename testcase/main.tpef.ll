; ModuleID = 'main.tpef'
source_filename = "llvm-link"
target datalayout = "e-p:32:32:32-i1:8:8-i8:8:32-i16:16:32-i32:32:32-i64:32:32-f32:32:32-f64:32:32-v64:64:64-v128:128:128-v256:256:256-v512:512:512-v1024:1024:1024-v2048:2048:2048-v4096:4096:4096-a0:0:32-n32"
target triple = "tcele-tut-llvm"

@__dummy__ = internal global i32 0, align 4
@MMAP = internal global [67 x i32] zeroinitializer, align 4

; Function Attrs: noinline noreturn nounwind
define dso_local void @_start() local_unnamed_addr #0 {
entry:
  tail call void asm sideeffect ".call_global_ctors", ""() #5, !srcloc !3
  tail call fastcc void @main() #6
  tail call void asm sideeffect ".call_global_dtors", ""() #5, !srcloc !4
  tail call fastcc void @_exit() #7
  unreachable
}

; Function Attrs: noinline norecurse noreturn nounwind
define internal fastcc void @_exit() unnamed_addr #1 {
entry:
  br label %while.body

while.body:                                       ; preds = %entry, %while.body
  store volatile i32 0, i32* @__dummy__, align 4, !tbaa !5
  br label %while.body
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #2

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #2

; Function Attrs: nounwind
define internal fastcc void @main() unnamed_addr #3 {
entry:
  %status.i355.i = alloca i32, align 4
  %status.i346.i = alloca i32, align 4
  %status.i.i = alloca i32, align 4
  %B_in.i = alloca [1 x [6 x [6 x [2 x i32]]]], align 4
  %B_w.i = alloca [3 x [3 x [2 x [1 x <32 x i32>]]]], align 128
  %B_out.i = alloca [1 x [4 x [4 x [1 x <32 x i16>]]]], align 64
  %0 = load volatile i32, i32* getelementptr inbounds ([67 x i32], [67 x i32]* @MMAP, i32 0, i32 5), align 4, !tbaa !5
  %1 = load volatile i32, i32* getelementptr inbounds ([67 x i32], [67 x i32]* @MMAP, i32 0, i32 3), align 4, !tbaa !5
  %2 = load volatile i32, i32* getelementptr inbounds ([67 x i32], [67 x i32]* @MMAP, i32 0, i32 4), align 4, !tbaa !5
  %3 = bitcast [1 x [6 x [6 x [2 x i32]]]]* %B_in.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 288, i8* nonnull %3) #5
  %4 = bitcast [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 2304, i8* nonnull %4) #5
  %5 = bitcast [1 x [4 x [4 x [1 x <32 x i16>]]]]* %B_out.i to i8*
  %6 = ptrtoint [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i to i32
  %add27.i = add i32 %6, 1136918528
  %arrayidx26.1.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 0, i32 0, i32 1, i32 0
  %7 = ptrtoint <32 x i32>* %arrayidx26.1.i to i32
  %add27.1.i = add i32 %7, 1136918528
  %arrayidx26.1424.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 0, i32 1, i32 0, i32 0
  %8 = ptrtoint <32 x i32>* %arrayidx26.1424.i to i32
  %add27.1425.i = add i32 %8, 1136918528
  %arrayidx26.1.1.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 0, i32 1, i32 1, i32 0
  %9 = ptrtoint <32 x i32>* %arrayidx26.1.1.i to i32
  %add27.1.1.i = add i32 %9, 1136918528
  %arrayidx26.2.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 0, i32 2, i32 0, i32 0
  %10 = ptrtoint <32 x i32>* %arrayidx26.2.i to i32
  %add27.2.i = add i32 %10, 1136918528
  %arrayidx26.1.2.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 0, i32 2, i32 1, i32 0
  %11 = ptrtoint <32 x i32>* %arrayidx26.1.2.i to i32
  %add27.1.2.i = add i32 %11, 1136918528
  %arrayidx26.1432.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 1, i32 0, i32 0, i32 0
  %12 = ptrtoint <32 x i32>* %arrayidx26.1432.i to i32
  %add27.1433.i = add i32 %12, 1136918528
  %arrayidx26.1.1439.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 1, i32 0, i32 1, i32 0
  %13 = ptrtoint <32 x i32>* %arrayidx26.1.1439.i to i32
  %add27.1.1440.i = add i32 %13, 1136918528
  %arrayidx26.1424.1.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 1, i32 1, i32 0, i32 0
  %14 = ptrtoint <32 x i32>* %arrayidx26.1424.1.i to i32
  %add27.1425.1.i = add i32 %14, 1136918528
  %arrayidx26.1.1.1.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 1, i32 1, i32 1, i32 0
  %15 = ptrtoint <32 x i32>* %arrayidx26.1.1.1.i to i32
  %add27.1.1.1.i = add i32 %15, 1136918528
  %arrayidx26.2.1.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 1, i32 2, i32 0, i32 0
  %16 = ptrtoint <32 x i32>* %arrayidx26.2.1.i to i32
  %add27.2.1.i = add i32 %16, 1136918528
  %arrayidx26.1.2.1.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 1, i32 2, i32 1, i32 0
  %17 = ptrtoint <32 x i32>* %arrayidx26.1.2.1.i to i32
  %add27.1.2.1.i = add i32 %17, 1136918528
  %arrayidx26.2448.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 2, i32 0, i32 0, i32 0
  %18 = ptrtoint <32 x i32>* %arrayidx26.2448.i to i32
  %add27.2449.i = add i32 %18, 1136918528
  %arrayidx26.1.2455.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 2, i32 0, i32 1, i32 0
  %19 = ptrtoint <32 x i32>* %arrayidx26.1.2455.i to i32
  %add27.1.2456.i = add i32 %19, 1136918528
  %arrayidx26.1424.2.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 2, i32 1, i32 0, i32 0
  %20 = ptrtoint <32 x i32>* %arrayidx26.1424.2.i to i32
  %add27.1425.2.i = add i32 %20, 1136918528
  %arrayidx26.1.1.2.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 2, i32 1, i32 1, i32 0
  %21 = ptrtoint <32 x i32>* %arrayidx26.1.1.2.i to i32
  %add27.1.1.2.i = add i32 %21, 1136918528
  %arrayidx26.2.2.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 2, i32 2, i32 0, i32 0
  %22 = ptrtoint <32 x i32>* %arrayidx26.2.2.i to i32
  %add27.2.2.i = add i32 %22, 1136918528
  %arrayidx26.1.2.2.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 2, i32 2, i32 1, i32 0
  %23 = ptrtoint <32 x i32>* %arrayidx26.1.2.2.i to i32
  %add27.1.2.2.i = add i32 %23, 1136918528
  %24 = ptrtoint [1 x [6 x [6 x [2 x i32]]]]* %B_in.i to i32
  %add73.i = add i32 %24, 1136918528
  %arrayidx72.1.i = getelementptr inbounds [1 x [6 x [6 x [2 x i32]]]], [1 x [6 x [6 x [2 x i32]]]]* %B_in.i, i32 0, i32 0, i32 1, i32 0, i32 0
  %25 = ptrtoint i32* %arrayidx72.1.i to i32
  %add73.1.i = add i32 %25, 1136918528
  %arrayidx72.2.i = getelementptr inbounds [1 x [6 x [6 x [2 x i32]]]], [1 x [6 x [6 x [2 x i32]]]]* %B_in.i, i32 0, i32 0, i32 2, i32 0, i32 0
  %26 = ptrtoint i32* %arrayidx72.2.i to i32
  %add73.2.i = add i32 %26, 1136918528
  %arrayidx72.3.i = getelementptr inbounds [1 x [6 x [6 x [2 x i32]]]], [1 x [6 x [6 x [2 x i32]]]]* %B_in.i, i32 0, i32 0, i32 3, i32 0, i32 0
  %27 = ptrtoint i32* %arrayidx72.3.i to i32
  %add73.3.i = add i32 %27, 1136918528
  %arrayidx72.4.i = getelementptr inbounds [1 x [6 x [6 x [2 x i32]]]], [1 x [6 x [6 x [2 x i32]]]]* %B_in.i, i32 0, i32 0, i32 4, i32 0, i32 0
  %28 = ptrtoint i32* %arrayidx72.4.i to i32
  %add73.4.i = add i32 %28, 1136918528
  %arrayidx72.5.i = getelementptr inbounds [1 x [6 x [6 x [2 x i32]]]], [1 x [6 x [6 x [2 x i32]]]]* %B_in.i, i32 0, i32 0, i32 5, i32 0, i32 0
  %29 = ptrtoint i32* %arrayidx72.5.i to i32
  %add73.5.i = add i32 %29, 1136918528
  %30 = bitcast [1 x [4 x [4 x [1 x <32 x i16>]]]]* %B_out.i to i32*
  %status.i.i.0.status.i.0.status.i.0.status.i.0.status.0.status.0..sroa_cast = bitcast i32* %status.i.i to i8*
  %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0..sroa_cast = bitcast i32* %status.i355.i to i8*
  %status.i346.i.0.status.i346.0.status.i346.0.status.i346.0.status.0.status.0..sroa_cast = bitcast i32* %status.i346.i to i8*
  br label %for.cond38.preheader.i

for.cond.cleanup3.i:                              ; preds = %for.cond.cleanup44.i
  %add229.i = add nuw nsw i32 %o_c.0417.i, 32
  %cmp.i = icmp ult i32 %add229.i, 64
  br i1 %cmp.i, label %for.cond38.preheader.i, label %conv1.exit

for.cond38.preheader.i:                           ; preds = %for.cond.cleanup3.i, %entry
  %o_c.0417.i = phi i32 [ 0, %entry ], [ %add229.i, %for.cond.cleanup3.i ]
  %mul22.i = shl i32 %o_c.0417.i, 2
  %add23.i = add i32 %mul22.i, %2
  call fastcc void @dma_queue_bursts(i32 %add23.i, i32 %add27.i, i32 32, i32 4) #5
  %add23.1.i = add i32 %add23.i, 256
  call fastcc void @dma_queue_bursts(i32 %add23.1.i, i32 %add27.1.i, i32 32, i32 4) #5
  %add23.1423.i = add i32 %add23.i, 512
  call fastcc void @dma_queue_bursts(i32 %add23.1423.i, i32 %add27.1425.i, i32 32, i32 4) #5
  %add23.1.1.i = add i32 %add23.i, 768
  call fastcc void @dma_queue_bursts(i32 %add23.1.1.i, i32 %add27.1.1.i, i32 32, i32 4) #5
  %add23.2.i = add i32 %add23.i, 1024
  call fastcc void @dma_queue_bursts(i32 %add23.2.i, i32 %add27.2.i, i32 32, i32 4) #5
  %add23.1.2.i = add i32 %add23.i, 1280
  call fastcc void @dma_queue_bursts(i32 %add23.1.2.i, i32 %add27.1.2.i, i32 32, i32 4) #5
  %add23.1431.i = add i32 %add23.i, 1536
  call fastcc void @dma_queue_bursts(i32 %add23.1431.i, i32 %add27.1433.i, i32 32, i32 4) #5
  %add23.1.1438.i = add i32 %add23.i, 1792
  call fastcc void @dma_queue_bursts(i32 %add23.1.1438.i, i32 %add27.1.1440.i, i32 32, i32 4) #5
  %add23.1423.1.i = add i32 %add23.i, 2048
  call fastcc void @dma_queue_bursts(i32 %add23.1423.1.i, i32 %add27.1425.1.i, i32 32, i32 4) #5
  %add23.1.1.1.i = add i32 %add23.i, 2304
  call fastcc void @dma_queue_bursts(i32 %add23.1.1.1.i, i32 %add27.1.1.1.i, i32 32, i32 4) #5
  %add23.2.1.i = add i32 %add23.i, 2560
  call fastcc void @dma_queue_bursts(i32 %add23.2.1.i, i32 %add27.2.1.i, i32 32, i32 4) #5
  %add23.1.2.1.i = add i32 %add23.i, 2816
  call fastcc void @dma_queue_bursts(i32 %add23.1.2.1.i, i32 %add27.1.2.1.i, i32 32, i32 4) #5
  %add23.2447.i = add i32 %add23.i, 3072
  call fastcc void @dma_queue_bursts(i32 %add23.2447.i, i32 %add27.2449.i, i32 32, i32 4) #5
  %add23.1.2454.i = add i32 %add23.i, 3328
  call fastcc void @dma_queue_bursts(i32 %add23.1.2454.i, i32 %add27.1.2456.i, i32 32, i32 4) #5
  %add23.1423.2.i = add i32 %add23.i, 3584
  call fastcc void @dma_queue_bursts(i32 %add23.1423.2.i, i32 %add27.1425.2.i, i32 32, i32 4) #5
  %add23.1.1.2.i = add i32 %add23.i, 3840
  call fastcc void @dma_queue_bursts(i32 %add23.1.1.2.i, i32 %add27.1.1.2.i, i32 32, i32 4) #5
  %add23.2.2.i = add i32 %add23.i, 4096
  call fastcc void @dma_queue_bursts(i32 %add23.2.2.i, i32 %add27.2.2.i, i32 32, i32 4) #5
  %add23.1.2.2.i = add i32 %add23.i, 4352
  call fastcc void @dma_queue_bursts(i32 %add23.1.2.2.i, i32 %add27.1.2.2.i, i32 32, i32 4) #5
  br label %for.cond42.preheader.i

for.cond42.preheader.i:                           ; preds = %for.cond.cleanup44.i, %for.cond38.preheader.i
  %o_y.0414.i = phi i32 [ 0, %for.cond38.preheader.i ], [ %add220.i, %for.cond.cleanup44.i ]
  %add59.i = shl i32 %o_y.0414.i, 5
  %mul61.2.i = or i32 %add59.i, 32
  %mul61.3.i = or i32 %add59.i, 64
  %mul61.4.i = or i32 %add59.i, 96
  br label %for.body45.i

for.cond.cleanup44.i:                             ; preds = %dma_wait.exit354.i
  %add220.i = add nuw nsw i32 %o_y.0414.i, 4
  %cmp39.i = icmp ult i32 %add220.i, 48
  br i1 %cmp39.i, label %for.cond42.preheader.i, label %for.cond.cleanup3.i

for.body45.i:                                     ; preds = %dma_wait.exit354.i, %for.cond42.preheader.i
  %o_x.0413.i = phi i32 [ 0, %for.cond42.preheader.i ], [ %add217.i, %dma_wait.exit354.i ]
  call void @llvm.lifetime.start.p0i8(i64 1024, i8* nonnull %5) #5
  br label %while.body15.i.i

while.body15.i.i:                                 ; preds = %while.body15.i.i, %for.body45.i
  %aligned_addr.085.i.i = phi i32* [ %30, %for.body45.i ], [ %incdec.ptr19.i.i.15, %while.body15.i.i ]
  %n.addr.184.i.i = phi i32 [ 1024, %for.body45.i ], [ %sub.i.i.15, %while.body15.i.i ]
  %incdec.ptr16.i.i = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 1
  store i32 0, i32* %aligned_addr.085.i.i, align 4, !tbaa !9
  %incdec.ptr17.i.i = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 2
  store i32 0, i32* %incdec.ptr16.i.i, align 4, !tbaa !9
  %incdec.ptr18.i.i = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 3
  store i32 0, i32* %incdec.ptr17.i.i, align 4, !tbaa !9
  %incdec.ptr19.i.i = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 4
  store i32 0, i32* %incdec.ptr18.i.i, align 4, !tbaa !9
  %incdec.ptr16.i.i.1 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 5
  store i32 0, i32* %incdec.ptr19.i.i, align 4, !tbaa !9
  %incdec.ptr17.i.i.1 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 6
  store i32 0, i32* %incdec.ptr16.i.i.1, align 4, !tbaa !9
  %incdec.ptr18.i.i.1 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 7
  store i32 0, i32* %incdec.ptr17.i.i.1, align 4, !tbaa !9
  %incdec.ptr19.i.i.1 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 8
  store i32 0, i32* %incdec.ptr18.i.i.1, align 4, !tbaa !9
  %incdec.ptr16.i.i.2 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 9
  store i32 0, i32* %incdec.ptr19.i.i.1, align 4, !tbaa !9
  %incdec.ptr17.i.i.2 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 10
  store i32 0, i32* %incdec.ptr16.i.i.2, align 4, !tbaa !9
  %incdec.ptr18.i.i.2 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 11
  store i32 0, i32* %incdec.ptr17.i.i.2, align 4, !tbaa !9
  %incdec.ptr19.i.i.2 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 12
  store i32 0, i32* %incdec.ptr18.i.i.2, align 4, !tbaa !9
  %incdec.ptr16.i.i.3 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 13
  store i32 0, i32* %incdec.ptr19.i.i.2, align 4, !tbaa !9
  %incdec.ptr17.i.i.3 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 14
  store i32 0, i32* %incdec.ptr16.i.i.3, align 4, !tbaa !9
  %incdec.ptr18.i.i.3 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 15
  store i32 0, i32* %incdec.ptr17.i.i.3, align 4, !tbaa !9
  %incdec.ptr19.i.i.3 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 16
  store i32 0, i32* %incdec.ptr18.i.i.3, align 4, !tbaa !9
  %incdec.ptr16.i.i.4 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 17
  store i32 0, i32* %incdec.ptr19.i.i.3, align 4, !tbaa !9
  %incdec.ptr17.i.i.4 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 18
  store i32 0, i32* %incdec.ptr16.i.i.4, align 4, !tbaa !9
  %incdec.ptr18.i.i.4 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 19
  store i32 0, i32* %incdec.ptr17.i.i.4, align 4, !tbaa !9
  %incdec.ptr19.i.i.4 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 20
  store i32 0, i32* %incdec.ptr18.i.i.4, align 4, !tbaa !9
  %incdec.ptr16.i.i.5 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 21
  store i32 0, i32* %incdec.ptr19.i.i.4, align 4, !tbaa !9
  %incdec.ptr17.i.i.5 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 22
  store i32 0, i32* %incdec.ptr16.i.i.5, align 4, !tbaa !9
  %incdec.ptr18.i.i.5 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 23
  store i32 0, i32* %incdec.ptr17.i.i.5, align 4, !tbaa !9
  %incdec.ptr19.i.i.5 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 24
  store i32 0, i32* %incdec.ptr18.i.i.5, align 4, !tbaa !9
  %incdec.ptr16.i.i.6 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 25
  store i32 0, i32* %incdec.ptr19.i.i.5, align 4, !tbaa !9
  %incdec.ptr17.i.i.6 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 26
  store i32 0, i32* %incdec.ptr16.i.i.6, align 4, !tbaa !9
  %incdec.ptr18.i.i.6 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 27
  store i32 0, i32* %incdec.ptr17.i.i.6, align 4, !tbaa !9
  %incdec.ptr19.i.i.6 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 28
  store i32 0, i32* %incdec.ptr18.i.i.6, align 4, !tbaa !9
  %incdec.ptr16.i.i.7 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 29
  store i32 0, i32* %incdec.ptr19.i.i.6, align 4, !tbaa !9
  %incdec.ptr17.i.i.7 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 30
  store i32 0, i32* %incdec.ptr16.i.i.7, align 4, !tbaa !9
  %incdec.ptr18.i.i.7 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 31
  store i32 0, i32* %incdec.ptr17.i.i.7, align 4, !tbaa !9
  %incdec.ptr19.i.i.7 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 32
  store i32 0, i32* %incdec.ptr18.i.i.7, align 4, !tbaa !9
  %incdec.ptr16.i.i.8 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 33
  store i32 0, i32* %incdec.ptr19.i.i.7, align 4, !tbaa !9
  %incdec.ptr17.i.i.8 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 34
  store i32 0, i32* %incdec.ptr16.i.i.8, align 4, !tbaa !9
  %incdec.ptr18.i.i.8 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 35
  store i32 0, i32* %incdec.ptr17.i.i.8, align 4, !tbaa !9
  %incdec.ptr19.i.i.8 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 36
  store i32 0, i32* %incdec.ptr18.i.i.8, align 4, !tbaa !9
  %incdec.ptr16.i.i.9 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 37
  store i32 0, i32* %incdec.ptr19.i.i.8, align 4, !tbaa !9
  %incdec.ptr17.i.i.9 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 38
  store i32 0, i32* %incdec.ptr16.i.i.9, align 4, !tbaa !9
  %incdec.ptr18.i.i.9 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 39
  store i32 0, i32* %incdec.ptr17.i.i.9, align 4, !tbaa !9
  %incdec.ptr19.i.i.9 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 40
  store i32 0, i32* %incdec.ptr18.i.i.9, align 4, !tbaa !9
  %incdec.ptr16.i.i.10 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 41
  store i32 0, i32* %incdec.ptr19.i.i.9, align 4, !tbaa !9
  %incdec.ptr17.i.i.10 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 42
  store i32 0, i32* %incdec.ptr16.i.i.10, align 4, !tbaa !9
  %incdec.ptr18.i.i.10 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 43
  store i32 0, i32* %incdec.ptr17.i.i.10, align 4, !tbaa !9
  %incdec.ptr19.i.i.10 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 44
  store i32 0, i32* %incdec.ptr18.i.i.10, align 4, !tbaa !9
  %incdec.ptr16.i.i.11 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 45
  store i32 0, i32* %incdec.ptr19.i.i.10, align 4, !tbaa !9
  %incdec.ptr17.i.i.11 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 46
  store i32 0, i32* %incdec.ptr16.i.i.11, align 4, !tbaa !9
  %incdec.ptr18.i.i.11 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 47
  store i32 0, i32* %incdec.ptr17.i.i.11, align 4, !tbaa !9
  %incdec.ptr19.i.i.11 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 48
  store i32 0, i32* %incdec.ptr18.i.i.11, align 4, !tbaa !9
  %incdec.ptr16.i.i.12 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 49
  store i32 0, i32* %incdec.ptr19.i.i.11, align 4, !tbaa !9
  %incdec.ptr17.i.i.12 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 50
  store i32 0, i32* %incdec.ptr16.i.i.12, align 4, !tbaa !9
  %incdec.ptr18.i.i.12 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 51
  store i32 0, i32* %incdec.ptr17.i.i.12, align 4, !tbaa !9
  %incdec.ptr19.i.i.12 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 52
  store i32 0, i32* %incdec.ptr18.i.i.12, align 4, !tbaa !9
  %incdec.ptr16.i.i.13 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 53
  store i32 0, i32* %incdec.ptr19.i.i.12, align 4, !tbaa !9
  %incdec.ptr17.i.i.13 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 54
  store i32 0, i32* %incdec.ptr16.i.i.13, align 4, !tbaa !9
  %incdec.ptr18.i.i.13 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 55
  store i32 0, i32* %incdec.ptr17.i.i.13, align 4, !tbaa !9
  %incdec.ptr19.i.i.13 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 56
  store i32 0, i32* %incdec.ptr18.i.i.13, align 4, !tbaa !9
  %incdec.ptr16.i.i.14 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 57
  store i32 0, i32* %incdec.ptr19.i.i.13, align 4, !tbaa !9
  %incdec.ptr17.i.i.14 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 58
  store i32 0, i32* %incdec.ptr16.i.i.14, align 4, !tbaa !9
  %incdec.ptr18.i.i.14 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 59
  store i32 0, i32* %incdec.ptr17.i.i.14, align 4, !tbaa !9
  %incdec.ptr19.i.i.14 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 60
  store i32 0, i32* %incdec.ptr18.i.i.14, align 4, !tbaa !9
  %incdec.ptr16.i.i.15 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 61
  store i32 0, i32* %incdec.ptr19.i.i.14, align 4, !tbaa !9
  %incdec.ptr17.i.i.15 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 62
  store i32 0, i32* %incdec.ptr16.i.i.15, align 4, !tbaa !9
  %incdec.ptr18.i.i.15 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 63
  store i32 0, i32* %incdec.ptr17.i.i.15, align 4, !tbaa !9
  %incdec.ptr19.i.i.15 = getelementptr inbounds i32, i32* %aligned_addr.085.i.i, i32 64
  store i32 0, i32* %incdec.ptr18.i.i.15, align 4, !tbaa !9
  %sub.i.i.15 = add nsw i32 %n.addr.184.i.i, -256
  %cmp13.i.i.15 = icmp eq i32 %sub.i.i.15, 0
  br i1 %cmp13.i.i.15, label %memset.exit.i, label %while.body15.i.i

memset.exit.i:                                    ; preds = %while.body15.i.i
  %sub63.i = add nuw nsw i32 %o_x.0413.i, 536870911
  %mul61.i = add nuw nsw i32 %sub63.i, %add59.i
  %add64.i = shl i32 %mul61.i, 3
  %mul65.i = add i32 %add64.i, %1
  %add68.i = add i32 %mul65.i, -256
  call fastcc void @dma_queue_bursts(i32 %add68.i, i32 %add73.i, i32 12, i32 4) #5
  call fastcc void @dma_queue_bursts(i32 %mul65.i, i32 %add73.1.i, i32 12, i32 4) #5
  %add64.2.i = add nuw nsw i32 %sub63.i, %mul61.2.i
  %mul65.2.i = shl i32 %add64.2.i, 3
  %add68.2.i = add i32 %mul65.2.i, %1
  call fastcc void @dma_queue_bursts(i32 %add68.2.i, i32 %add73.2.i, i32 12, i32 4) #5
  %add64.3.i = add nuw nsw i32 %sub63.i, %mul61.3.i
  %mul65.3.i = shl i32 %add64.3.i, 3
  %add68.3.i = add i32 %mul65.3.i, %1
  call fastcc void @dma_queue_bursts(i32 %add68.3.i, i32 %add73.3.i, i32 12, i32 4) #5
  %add64.4.i = add nuw nsw i32 %sub63.i, %mul61.4.i
  %mul65.4.i = shl i32 %add64.4.i, 3
  %add68.4.i = add i32 %mul65.4.i, %1
  call fastcc void @dma_queue_bursts(i32 %add68.4.i, i32 %add73.4.i, i32 12, i32 4) #5
  %add68.5.i = add i32 %mul65.i, 1024
  call fastcc void @dma_queue_bursts(i32 %add68.5.i, i32 %add73.5.i, i32 12, i32 4) #5
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %status.i.i.0.status.i.0.status.i.0.status.i.0.status.0.status.0..sroa_cast)
  store volatile i32 0, i32* %status.i.i, align 4, !tbaa !5
  %status.i.i.0.status.i.0.status.i.0.status.i.0.status.0.status.0.5.i.i = load volatile i32, i32* %status.i.i, align 4, !tbaa !5
  %cmp6.i.i = icmp eq i32 %status.i.i.0.status.i.0.status.i.0.status.i.0.status.0.status.0.5.i.i, 0
  br i1 %cmp6.i.i, label %do.body.i.i, label %dma_wait.exit.i

do.body.i.i:                                      ; preds = %memset.exit.i, %do.body.i.i
  %status.i.i.0.status.i.0.status.i.0.status.i.0.status.0.status.0.2.i.i = load volatile i32, i32* %status.i.i, align 4, !tbaa !5
  %31 = call i32 asm sideeffect "STATUS_BC", "=r,ir"(i32 %status.i.i.0.status.i.0.status.i.0.status.i.0.status.0.status.0.2.i.i) #5, !srcloc !11
  store volatile i32 %31, i32* %status.i.i, align 4, !tbaa !5
  %status.i.i.0.status.i.0.status.i.0.status.i.0.status.0.status.0..i.i = load volatile i32, i32* %status.i.i, align 4, !tbaa !5
  %cmp.i.i = icmp eq i32 %status.i.i.0.status.i.0.status.i.0.status.i.0.status.0.status.0..i.i, 0
  br i1 %cmp.i.i, label %do.body.i.i, label %dma_wait.exit.i

dma_wait.exit.i:                                  ; preds = %do.body.i.i, %memset.exit.i
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %status.i.i.0.status.i.0.status.i.0.status.i.0.status.0.status.0..sroa_cast)
  %cmp109.us.i = icmp eq i32 %o_x.0413.i, 0
  %spec.select345.us.i = zext i1 %cmp109.us.i to i32
  %add108.us.3.i = or i32 %o_x.0413.i, 3
  %cmp117.us.3.i = icmp ugt i32 %add108.us.3.i, 30
  %sub120.us.3.i = sub nuw nsw i32 33, %add108.us.3.i
  %cond123.us.3.i = select i1 %cmp117.us.3.i, i32 %sub120.us.3.i, i32 3
  br label %for.cond88.preheader.i

for.cond88.preheader.i:                           ; preds = %for.cond.cleanup90.i, %dma_wait.exit.i
  %to_y.0407.i = phi i32 [ 0, %dma_wait.exit.i ], [ %inc170.i, %for.cond.cleanup90.i ]
  %add92.i = add nuw nsw i32 %to_y.0407.i, %o_y.0414.i
  %cmp93.i = icmp eq i32 %add92.i, 0
  %spec.select.i = zext i1 %cmp93.i to i32
  %cmp97.i = icmp ugt i32 %add92.i, 46
  %sub100.i = sub nuw nsw i32 49, %add92.i
  %cond103.i = select i1 %cmp97.i, i32 %sub100.i, i32 3
  %cmp105376.i = icmp ugt i32 %cond103.i, %spec.select.i
  br i1 %cmp105376.i, label %for.body107.us.us.preheader.i, label %for.cond.cleanup90.i

for.body107.us.us.preheader.i:                    ; preds = %for.cond88.preheader.i
  %.phi.trans.insert.phi.trans.insert.i = getelementptr inbounds [1 x [4 x [4 x [1 x <32 x i16>]]]], [1 x [4 x [4 x [1 x <32 x i16>]]]]* %B_out.i, i32 0, i32 0, i32 %to_y.0407.i, i32 0, i32 0
  %.pre.pre.i = load <32 x i16>, <32 x i16>* %.phi.trans.insert.phi.trans.insert.i, align 64, !tbaa !12
  br label %for.body107.us.us.i

for.body107.us.us.i:                              ; preds = %for.cond124.for.cond.cleanup126_crit_edge.us.us.i, %for.body107.us.us.preheader.i
  %.pre.i = phi <32 x i16> [ %40, %for.cond124.for.cond.cleanup126_crit_edge.us.us.i ], [ %.pre.pre.i, %for.body107.us.us.preheader.i ]
  %k_y.0377.us.us.i = phi i32 [ %inc164.us.us.i, %for.cond124.for.cond.cleanup126_crit_edge.us.us.i ], [ %spec.select.i, %for.body107.us.us.preheader.i ]
  %add141.us.us.i = add nuw nsw i32 %k_y.0377.us.us.i, %to_y.0407.i
  br label %for.cond128.preheader.us.us.i

for.cond124.for.cond.cleanup126_crit_edge.us.us.i: ; preds = %for.cond128.preheader.us.us.i
  %inc164.us.us.i = add nuw nsw i32 %k_y.0377.us.us.i, 1
  %cmp105.us.us.i = icmp ult i32 %inc164.us.us.i, %cond103.i
  br i1 %cmp105.us.us.i, label %for.body107.us.us.i, label %for.body107.us.us.preheader.1.i

for.cond128.preheader.us.us.i:                    ; preds = %for.cond128.preheader.us.us.i, %for.body107.us.us.i
  %32 = phi <32 x i16> [ %.pre.i, %for.body107.us.us.i ], [ %40, %for.cond128.preheader.us.us.i ]
  %k_x.0375.us.us.i = phi i32 [ %spec.select345.us.i, %for.body107.us.us.i ], [ %inc161.us.us.i, %for.cond128.preheader.us.us.i ]
  %33 = getelementptr inbounds [1 x [6 x [6 x [2 x i32]]]], [1 x [6 x [6 x [2 x i32]]]]* %B_in.i, i32 0, i32 0, i32 %add141.us.us.i, i32 %k_x.0375.us.us.i, i32 0
  %34 = load i32, i32* %33, align 4, !tbaa !9
  %arrayidx149.us.us.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 %k_y.0377.us.us.i, i32 %k_x.0375.us.us.i, i32 0, i32 0
  %35 = load <32 x i32>, <32 x i32>* %arrayidx149.us.us.i, align 128, !tbaa !12
  %36 = call <32 x i16> asm "XNORPOPCOUNTACC32X32", "=r,ir,r,r"(i32 %34, <32 x i32> %35, <32 x i16> %32) #8
  %37 = getelementptr inbounds [1 x [6 x [6 x [2 x i32]]]], [1 x [6 x [6 x [2 x i32]]]]* %B_in.i, i32 0, i32 0, i32 %add141.us.us.i, i32 %k_x.0375.us.us.i, i32 1
  %38 = load i32, i32* %37, align 4, !tbaa !9
  %arrayidx149.us.us.1.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 %k_y.0377.us.us.i, i32 %k_x.0375.us.us.i, i32 1, i32 0
  %39 = load <32 x i32>, <32 x i32>* %arrayidx149.us.us.1.i, align 128, !tbaa !12
  %40 = call <32 x i16> asm "XNORPOPCOUNTACC32X32", "=r,ir,r,r"(i32 %38, <32 x i32> %39, <32 x i16> %36) #8, !srcloc !13
  %inc161.us.us.i = add nuw nsw i32 %k_x.0375.us.us.i, 1
  %exitcond25.i = icmp eq i32 %inc161.us.us.i, 3
  br i1 %exitcond25.i, label %for.cond124.for.cond.cleanup126_crit_edge.us.us.i, label %for.cond128.preheader.us.us.i

for.cond.cleanup90.loopexit.i:                    ; preds = %for.cond124.for.cond.cleanup126_crit_edge.us.us.3.i
  store <32 x i16> %101, <32 x i16>* %.phi.trans.insert465.phi.trans.insert.i, align 64, !tbaa !12
  br label %for.cond.cleanup90.i

for.cond.cleanup90.i:                             ; preds = %for.cond.cleanup90.loopexit.i, %for.cond88.preheader.i
  %inc170.i = add nuw nsw i32 %to_y.0407.i, 1
  %exitcond.i = icmp eq i32 %inc170.i, 4
  br i1 %exitcond.i, label %for.cond186.preheader.i, label %for.cond88.preheader.i

do.body.i353.i:                                   ; preds = %for.cond.cleanup183.i, %do.body.i353.i
  %status.i346.i.0.status.i346.0.status.i346.0.status.i346.0.status.0.status.0.2.i350.i = load volatile i32, i32* %status.i346.i, align 4, !tbaa !5
  %41 = call i32 asm sideeffect "STATUS_BC", "=r,ir"(i32 %status.i346.i.0.status.i346.0.status.i346.0.status.i346.0.status.0.status.0.2.i350.i) #5, !srcloc !11
  store volatile i32 %41, i32* %status.i346.i, align 4, !tbaa !5
  %status.i346.i.0.status.i346.0.status.i346.0.status.i346.0.status.0.status.0..i351.i = load volatile i32, i32* %status.i346.i, align 4, !tbaa !5
  %cmp.i352.i = icmp eq i32 %status.i346.i.0.status.i346.0.status.i346.0.status.i346.0.status.0.status.0..i351.i, 0
  br i1 %cmp.i352.i, label %do.body.i353.i, label %dma_wait.exit354.i

dma_wait.exit354.i:                               ; preds = %do.body.i353.i, %for.cond.cleanup183.i
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %status.i346.i.0.status.i346.0.status.i346.0.status.i346.0.status.0.status.0..sroa_cast)
  call void @llvm.lifetime.end.p0i8(i64 1024, i8* nonnull %5) #5
  %add217.i = add nuw nsw i32 %o_x.0413.i, 4
  %cmp43.i = icmp ult i32 %add217.i, 32
  br i1 %cmp43.i, label %for.body45.i, label %for.cond.cleanup44.i

for.cond186.preheader.i:                          ; preds = %for.cond.cleanup90.i, %dma_wait.exit363.3.i
  %j180.0411.i = phi i32 [ %inc211.i, %dma_wait.exit363.3.i ], [ 0, %for.cond.cleanup90.i ]
  %add194.i = add nuw nsw i32 %j180.0411.i, %o_y.0414.i
  %mul195.i = shl i32 %add194.i, 5
  %add196.i = add nuw nsw i32 %mul195.i, %o_x.0413.i
  %mul198.i = shl i32 %add196.i, 6
  %add199.i = add nuw nsw i32 %mul198.i, %o_c.0417.i
  %mul200.i = shl i32 %add199.i, 1
  %arrayidx204.i = getelementptr inbounds [1 x [4 x [4 x [1 x <32 x i16>]]]], [1 x [4 x [4 x [1 x <32 x i16>]]]]* %B_out.i, i32 0, i32 0, i32 %j180.0411.i, i32 0, i32 0
  %42 = ptrtoint <32 x i16>* %arrayidx204.i to i32
  %add205.i = add i32 %42, 1136918528
  %add206.i = add i32 %mul200.i, %0
  call fastcc void @dma_queue_bursts(i32 %add205.i, i32 %add206.i, i32 32, i32 2) #5
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0..sroa_cast)
  store volatile i32 0, i32* %status.i355.i, align 4, !tbaa !5
  %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0.5.i357.i = load volatile i32, i32* %status.i355.i, align 4, !tbaa !5
  %cmp6.i358.i = icmp eq i32 %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0.5.i357.i, 0
  br i1 %cmp6.i358.i, label %do.body.i362.i, label %dma_wait.exit363.i

for.cond.cleanup183.i:                            ; preds = %dma_wait.exit363.3.i
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %status.i346.i.0.status.i346.0.status.i346.0.status.i346.0.status.0.status.0..sroa_cast)
  store volatile i32 0, i32* %status.i346.i, align 4, !tbaa !5
  %status.i346.i.0.status.i346.0.status.i346.0.status.i346.0.status.0.status.0.5.i348.i = load volatile i32, i32* %status.i346.i, align 4, !tbaa !5
  %cmp6.i349.i = icmp eq i32 %status.i346.i.0.status.i346.0.status.i346.0.status.i346.0.status.0.status.0.5.i348.i, 0
  br i1 %cmp6.i349.i, label %do.body.i353.i, label %dma_wait.exit354.i

do.body.i362.i:                                   ; preds = %for.cond186.preheader.i, %do.body.i362.i
  %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0.2.i359.i = load volatile i32, i32* %status.i355.i, align 4, !tbaa !5
  %43 = call i32 asm sideeffect "STATUS_BC", "=r,ir"(i32 %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0.2.i359.i) #5, !srcloc !11
  store volatile i32 %43, i32* %status.i355.i, align 4, !tbaa !5
  %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0..i360.i = load volatile i32, i32* %status.i355.i, align 4, !tbaa !5
  %cmp.i361.i = icmp eq i32 %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0..i360.i, 0
  br i1 %cmp.i361.i, label %do.body.i362.i, label %dma_wait.exit363.i

dma_wait.exit363.i:                               ; preds = %do.body.i362.i, %for.cond186.preheader.i
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0..sroa_cast)
  %mul198.1.i = or i32 %mul198.i, 64
  %add199.1.i = add nuw nsw i32 %mul198.1.i, %o_c.0417.i
  %mul200.1.i = shl i32 %add199.1.i, 1
  %arrayidx204.1.i = getelementptr inbounds [1 x [4 x [4 x [1 x <32 x i16>]]]], [1 x [4 x [4 x [1 x <32 x i16>]]]]* %B_out.i, i32 0, i32 0, i32 %j180.0411.i, i32 1, i32 0
  %44 = ptrtoint <32 x i16>* %arrayidx204.1.i to i32
  %add205.1.i = add i32 %44, 1136918528
  %add206.1.i = add i32 %mul200.1.i, %0
  call fastcc void @dma_queue_bursts(i32 %add205.1.i, i32 %add206.1.i, i32 32, i32 2) #5
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0..sroa_cast)
  store volatile i32 0, i32* %status.i355.i, align 4, !tbaa !5
  %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0.5.i357.1.i = load volatile i32, i32* %status.i355.i, align 4, !tbaa !5
  %cmp6.i358.1.i = icmp eq i32 %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0.5.i357.1.i, 0
  br i1 %cmp6.i358.1.i, label %do.body.i362.1.i, label %dma_wait.exit363.1.i

for.body107.us.us.preheader.1.i:                  ; preds = %for.cond124.for.cond.cleanup126_crit_edge.us.us.i
  store <32 x i16> %40, <32 x i16>* %.phi.trans.insert.phi.trans.insert.i, align 64, !tbaa !12
  %.phi.trans.insert461.phi.trans.insert.i = getelementptr inbounds [1 x [4 x [4 x [1 x <32 x i16>]]]], [1 x [4 x [4 x [1 x <32 x i16>]]]]* %B_out.i, i32 0, i32 0, i32 %to_y.0407.i, i32 1, i32 0
  %.pre462.pre.i = load <32 x i16>, <32 x i16>* %.phi.trans.insert461.phi.trans.insert.i, align 64, !tbaa !12
  br label %for.body107.us.us.1.i

for.body107.us.us.1.i:                            ; preds = %for.body107.us.us.1.i, %for.body107.us.us.preheader.1.i
  %.pre462.i = phi <32 x i16> [ %68, %for.body107.us.us.1.i ], [ %.pre462.pre.i, %for.body107.us.us.preheader.1.i ]
  %k_y.0377.us.us.1.i = phi i32 [ %inc164.us.us.1.i, %for.body107.us.us.1.i ], [ %spec.select.i, %for.body107.us.us.preheader.1.i ]
  %add141.us.us.1.i = add nuw nsw i32 %k_y.0377.us.us.1.i, %to_y.0407.i
  %45 = getelementptr inbounds [1 x [6 x [6 x [2 x i32]]]], [1 x [6 x [6 x [2 x i32]]]]* %B_in.i, i32 0, i32 0, i32 %add141.us.us.1.i, i32 1, i32 0
  %46 = load i32, i32* %45, align 4, !tbaa !9
  %arrayidx149.us.us.1458.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 %k_y.0377.us.us.1.i, i32 0, i32 0, i32 0
  %47 = load <32 x i32>, <32 x i32>* %arrayidx149.us.us.1458.i, align 128, !tbaa !12
  %48 = call <32 x i16> asm "XNORPOPCOUNTACC32X32", "=r,ir,r,r"(i32 %46, <32 x i32> %47, <32 x i16> %.pre462.i) #8
  %49 = getelementptr inbounds [1 x [6 x [6 x [2 x i32]]]], [1 x [6 x [6 x [2 x i32]]]]* %B_in.i, i32 0, i32 0, i32 %add141.us.us.1.i, i32 1, i32 1
  %50 = load i32, i32* %49, align 4, !tbaa !9
  %arrayidx149.us.us.1.1.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 %k_y.0377.us.us.1.i, i32 0, i32 1, i32 0
  %51 = load <32 x i32>, <32 x i32>* %arrayidx149.us.us.1.1.i, align 128, !tbaa !12
  %52 = call <32 x i16> asm "XNORPOPCOUNTACC32X32", "=r,ir,r,r"(i32 %50, <32 x i32> %51, <32 x i16> %48) #8, !srcloc !13
  %53 = getelementptr inbounds [1 x [6 x [6 x [2 x i32]]]], [1 x [6 x [6 x [2 x i32]]]]* %B_in.i, i32 0, i32 0, i32 %add141.us.us.1.i, i32 2, i32 0
  %54 = load i32, i32* %53, align 4, !tbaa !9
  %arrayidx149.us.us.1458.1.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 %k_y.0377.us.us.1.i, i32 1, i32 0, i32 0
  %55 = load <32 x i32>, <32 x i32>* %arrayidx149.us.us.1458.1.i, align 128, !tbaa !12
  %56 = call <32 x i16> asm "XNORPOPCOUNTACC32X32", "=r,ir,r,r"(i32 %54, <32 x i32> %55, <32 x i16> %52) #8
  %57 = getelementptr inbounds [1 x [6 x [6 x [2 x i32]]]], [1 x [6 x [6 x [2 x i32]]]]* %B_in.i, i32 0, i32 0, i32 %add141.us.us.1.i, i32 2, i32 1
  %58 = load i32, i32* %57, align 4, !tbaa !9
  %arrayidx149.us.us.1.1.1.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 %k_y.0377.us.us.1.i, i32 1, i32 1, i32 0
  %59 = load <32 x i32>, <32 x i32>* %arrayidx149.us.us.1.1.1.i, align 128, !tbaa !12
  %60 = call <32 x i16> asm "XNORPOPCOUNTACC32X32", "=r,ir,r,r"(i32 %58, <32 x i32> %59, <32 x i16> %56) #8, !srcloc !13
  %61 = getelementptr inbounds [1 x [6 x [6 x [2 x i32]]]], [1 x [6 x [6 x [2 x i32]]]]* %B_in.i, i32 0, i32 0, i32 %add141.us.us.1.i, i32 3, i32 0
  %62 = load i32, i32* %61, align 4, !tbaa !9
  %arrayidx149.us.us.1458.2.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 %k_y.0377.us.us.1.i, i32 2, i32 0, i32 0
  %63 = load <32 x i32>, <32 x i32>* %arrayidx149.us.us.1458.2.i, align 128, !tbaa !12
  %64 = call <32 x i16> asm "XNORPOPCOUNTACC32X32", "=r,ir,r,r"(i32 %62, <32 x i32> %63, <32 x i16> %60) #8
  %65 = getelementptr inbounds [1 x [6 x [6 x [2 x i32]]]], [1 x [6 x [6 x [2 x i32]]]]* %B_in.i, i32 0, i32 0, i32 %add141.us.us.1.i, i32 3, i32 1
  %66 = load i32, i32* %65, align 4, !tbaa !9
  %arrayidx149.us.us.1.1.2.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 %k_y.0377.us.us.1.i, i32 2, i32 1, i32 0
  %67 = load <32 x i32>, <32 x i32>* %arrayidx149.us.us.1.1.2.i, align 128, !tbaa !12
  %68 = call <32 x i16> asm "XNORPOPCOUNTACC32X32", "=r,ir,r,r"(i32 %66, <32 x i32> %67, <32 x i16> %64) #8, !srcloc !13
  %inc164.us.us.1.i = add nuw nsw i32 %k_y.0377.us.us.1.i, 1
  %cmp105.us.us.1.i = icmp ult i32 %inc164.us.us.1.i, %cond103.i
  br i1 %cmp105.us.us.1.i, label %for.body107.us.us.1.i, label %for.body107.us.us.preheader.2.i

for.body107.us.us.preheader.2.i:                  ; preds = %for.body107.us.us.1.i
  store <32 x i16> %68, <32 x i16>* %.phi.trans.insert461.phi.trans.insert.i, align 64, !tbaa !12
  %.phi.trans.insert463.phi.trans.insert.i = getelementptr inbounds [1 x [4 x [4 x [1 x <32 x i16>]]]], [1 x [4 x [4 x [1 x <32 x i16>]]]]* %B_out.i, i32 0, i32 0, i32 %to_y.0407.i, i32 2, i32 0
  %.pre464.pre.i = load <32 x i16>, <32 x i16>* %.phi.trans.insert463.phi.trans.insert.i, align 64, !tbaa !12
  br label %for.body107.us.us.2.i

for.body107.us.us.2.i:                            ; preds = %for.body107.us.us.2.i, %for.body107.us.us.preheader.2.i
  %.pre464.i = phi <32 x i16> [ %92, %for.body107.us.us.2.i ], [ %.pre464.pre.i, %for.body107.us.us.preheader.2.i ]
  %k_y.0377.us.us.2.i = phi i32 [ %inc164.us.us.2.i, %for.body107.us.us.2.i ], [ %spec.select.i, %for.body107.us.us.preheader.2.i ]
  %add141.us.us.2.i = add nuw nsw i32 %k_y.0377.us.us.2.i, %to_y.0407.i
  %69 = getelementptr inbounds [1 x [6 x [6 x [2 x i32]]]], [1 x [6 x [6 x [2 x i32]]]]* %B_in.i, i32 0, i32 0, i32 %add141.us.us.2.i, i32 2, i32 0
  %70 = load i32, i32* %69, align 4, !tbaa !9
  %arrayidx149.us.us.2.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 %k_y.0377.us.us.2.i, i32 0, i32 0, i32 0
  %71 = load <32 x i32>, <32 x i32>* %arrayidx149.us.us.2.i, align 128, !tbaa !12
  %72 = call <32 x i16> asm "XNORPOPCOUNTACC32X32", "=r,ir,r,r"(i32 %70, <32 x i32> %71, <32 x i16> %.pre464.i) #8
  %73 = getelementptr inbounds [1 x [6 x [6 x [2 x i32]]]], [1 x [6 x [6 x [2 x i32]]]]* %B_in.i, i32 0, i32 0, i32 %add141.us.us.2.i, i32 2, i32 1
  %74 = load i32, i32* %73, align 4, !tbaa !9
  %arrayidx149.us.us.1.2.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 %k_y.0377.us.us.2.i, i32 0, i32 1, i32 0
  %75 = load <32 x i32>, <32 x i32>* %arrayidx149.us.us.1.2.i, align 128, !tbaa !12
  %76 = call <32 x i16> asm "XNORPOPCOUNTACC32X32", "=r,ir,r,r"(i32 %74, <32 x i32> %75, <32 x i16> %72) #8, !srcloc !13
  %77 = getelementptr inbounds [1 x [6 x [6 x [2 x i32]]]], [1 x [6 x [6 x [2 x i32]]]]* %B_in.i, i32 0, i32 0, i32 %add141.us.us.2.i, i32 3, i32 0
  %78 = load i32, i32* %77, align 4, !tbaa !9
  %arrayidx149.us.us.2.1.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 %k_y.0377.us.us.2.i, i32 1, i32 0, i32 0
  %79 = load <32 x i32>, <32 x i32>* %arrayidx149.us.us.2.1.i, align 128, !tbaa !12
  %80 = call <32 x i16> asm "XNORPOPCOUNTACC32X32", "=r,ir,r,r"(i32 %78, <32 x i32> %79, <32 x i16> %76) #8
  %81 = getelementptr inbounds [1 x [6 x [6 x [2 x i32]]]], [1 x [6 x [6 x [2 x i32]]]]* %B_in.i, i32 0, i32 0, i32 %add141.us.us.2.i, i32 3, i32 1
  %82 = load i32, i32* %81, align 4, !tbaa !9
  %arrayidx149.us.us.1.2.1.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 %k_y.0377.us.us.2.i, i32 1, i32 1, i32 0
  %83 = load <32 x i32>, <32 x i32>* %arrayidx149.us.us.1.2.1.i, align 128, !tbaa !12
  %84 = call <32 x i16> asm "XNORPOPCOUNTACC32X32", "=r,ir,r,r"(i32 %82, <32 x i32> %83, <32 x i16> %80) #8, !srcloc !13
  %85 = getelementptr inbounds [1 x [6 x [6 x [2 x i32]]]], [1 x [6 x [6 x [2 x i32]]]]* %B_in.i, i32 0, i32 0, i32 %add141.us.us.2.i, i32 4, i32 0
  %86 = load i32, i32* %85, align 4, !tbaa !9
  %arrayidx149.us.us.2.2.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 %k_y.0377.us.us.2.i, i32 2, i32 0, i32 0
  %87 = load <32 x i32>, <32 x i32>* %arrayidx149.us.us.2.2.i, align 128, !tbaa !12
  %88 = call <32 x i16> asm "XNORPOPCOUNTACC32X32", "=r,ir,r,r"(i32 %86, <32 x i32> %87, <32 x i16> %84) #8
  %89 = getelementptr inbounds [1 x [6 x [6 x [2 x i32]]]], [1 x [6 x [6 x [2 x i32]]]]* %B_in.i, i32 0, i32 0, i32 %add141.us.us.2.i, i32 4, i32 1
  %90 = load i32, i32* %89, align 4, !tbaa !9
  %arrayidx149.us.us.1.2.2.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 %k_y.0377.us.us.2.i, i32 2, i32 1, i32 0
  %91 = load <32 x i32>, <32 x i32>* %arrayidx149.us.us.1.2.2.i, align 128, !tbaa !12
  %92 = call <32 x i16> asm "XNORPOPCOUNTACC32X32", "=r,ir,r,r"(i32 %90, <32 x i32> %91, <32 x i16> %88) #8, !srcloc !13
  %inc164.us.us.2.i = add nuw nsw i32 %k_y.0377.us.us.2.i, 1
  %cmp105.us.us.2.i = icmp ult i32 %inc164.us.us.2.i, %cond103.i
  br i1 %cmp105.us.us.2.i, label %for.body107.us.us.2.i, label %for.body107.us.us.preheader.3.i

for.body107.us.us.preheader.3.i:                  ; preds = %for.body107.us.us.2.i
  store <32 x i16> %92, <32 x i16>* %.phi.trans.insert463.phi.trans.insert.i, align 64, !tbaa !12
  %.phi.trans.insert465.phi.trans.insert.i = getelementptr inbounds [1 x [4 x [4 x [1 x <32 x i16>]]]], [1 x [4 x [4 x [1 x <32 x i16>]]]]* %B_out.i, i32 0, i32 0, i32 %to_y.0407.i, i32 3, i32 0
  %.pre466.pre.i = load <32 x i16>, <32 x i16>* %.phi.trans.insert465.phi.trans.insert.i, align 64, !tbaa !12
  br label %for.body107.us.us.3.i

for.body107.us.us.3.i:                            ; preds = %for.cond124.for.cond.cleanup126_crit_edge.us.us.3.i, %for.body107.us.us.preheader.3.i
  %.pre466.i = phi <32 x i16> [ %101, %for.cond124.for.cond.cleanup126_crit_edge.us.us.3.i ], [ %.pre466.pre.i, %for.body107.us.us.preheader.3.i ]
  %k_y.0377.us.us.3.i = phi i32 [ %inc164.us.us.3.i, %for.cond124.for.cond.cleanup126_crit_edge.us.us.3.i ], [ %spec.select.i, %for.body107.us.us.preheader.3.i ]
  %add141.us.us.3.i = add nuw nsw i32 %k_y.0377.us.us.3.i, %to_y.0407.i
  br label %for.cond128.preheader.us.us.3.i

for.cond128.preheader.us.us.3.i:                  ; preds = %for.cond128.preheader.us.us.3.i, %for.body107.us.us.3.i
  %93 = phi <32 x i16> [ %.pre466.i, %for.body107.us.us.3.i ], [ %101, %for.cond128.preheader.us.us.3.i ]
  %k_x.0375.us.us.3.i = phi i32 [ 0, %for.body107.us.us.3.i ], [ %inc161.us.us.3.i, %for.cond128.preheader.us.us.3.i ]
  %add143.us.us.3.i = add nuw nsw i32 %k_x.0375.us.us.3.i, 3
  %94 = getelementptr inbounds [1 x [6 x [6 x [2 x i32]]]], [1 x [6 x [6 x [2 x i32]]]]* %B_in.i, i32 0, i32 0, i32 %add141.us.us.3.i, i32 %add143.us.us.3.i, i32 0
  %95 = load i32, i32* %94, align 4, !tbaa !9
  %arrayidx149.us.us.3.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 %k_y.0377.us.us.3.i, i32 %k_x.0375.us.us.3.i, i32 0, i32 0
  %96 = load <32 x i32>, <32 x i32>* %arrayidx149.us.us.3.i, align 128, !tbaa !12
  %97 = call <32 x i16> asm "XNORPOPCOUNTACC32X32", "=r,ir,r,r"(i32 %95, <32 x i32> %96, <32 x i16> %93) #8
  %98 = getelementptr inbounds [1 x [6 x [6 x [2 x i32]]]], [1 x [6 x [6 x [2 x i32]]]]* %B_in.i, i32 0, i32 0, i32 %add141.us.us.3.i, i32 %add143.us.us.3.i, i32 1
  %99 = load i32, i32* %98, align 4, !tbaa !9
  %arrayidx149.us.us.1.3.i = getelementptr inbounds [3 x [3 x [2 x [1 x <32 x i32>]]]], [3 x [3 x [2 x [1 x <32 x i32>]]]]* %B_w.i, i32 0, i32 %k_y.0377.us.us.3.i, i32 %k_x.0375.us.us.3.i, i32 1, i32 0
  %100 = load <32 x i32>, <32 x i32>* %arrayidx149.us.us.1.3.i, align 128, !tbaa !12
  %101 = call <32 x i16> asm "XNORPOPCOUNTACC32X32", "=r,ir,r,r"(i32 %99, <32 x i32> %100, <32 x i16> %97) #8, !srcloc !13
  %inc161.us.us.3.i = add nuw nsw i32 %k_x.0375.us.us.3.i, 1
  %cmp125.us.us.3.i = icmp ult i32 %inc161.us.us.3.i, %cond123.us.3.i
  br i1 %cmp125.us.us.3.i, label %for.cond128.preheader.us.us.3.i, label %for.cond124.for.cond.cleanup126_crit_edge.us.us.3.i

for.cond124.for.cond.cleanup126_crit_edge.us.us.3.i: ; preds = %for.cond128.preheader.us.us.3.i
  %inc164.us.us.3.i = add nuw nsw i32 %k_y.0377.us.us.3.i, 1
  %cmp105.us.us.3.i = icmp ult i32 %inc164.us.us.3.i, %cond103.i
  br i1 %cmp105.us.us.3.i, label %for.body107.us.us.3.i, label %for.cond.cleanup90.loopexit.i

do.body.i362.1.i:                                 ; preds = %dma_wait.exit363.i, %do.body.i362.1.i
  %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0.2.i359.1.i = load volatile i32, i32* %status.i355.i, align 4, !tbaa !5
  %102 = call i32 asm sideeffect "STATUS_BC", "=r,ir"(i32 %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0.2.i359.1.i) #5, !srcloc !11
  store volatile i32 %102, i32* %status.i355.i, align 4, !tbaa !5
  %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0..i360.1.i = load volatile i32, i32* %status.i355.i, align 4, !tbaa !5
  %cmp.i361.1.i = icmp eq i32 %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0..i360.1.i, 0
  br i1 %cmp.i361.1.i, label %do.body.i362.1.i, label %dma_wait.exit363.1.i

dma_wait.exit363.1.i:                             ; preds = %do.body.i362.1.i, %dma_wait.exit363.i
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0..sroa_cast)
  %mul198.2.i = or i32 %mul198.i, 128
  %add199.2.i = add nuw nsw i32 %mul198.2.i, %o_c.0417.i
  %mul200.2.i = shl i32 %add199.2.i, 1
  %arrayidx204.2.i = getelementptr inbounds [1 x [4 x [4 x [1 x <32 x i16>]]]], [1 x [4 x [4 x [1 x <32 x i16>]]]]* %B_out.i, i32 0, i32 0, i32 %j180.0411.i, i32 2, i32 0
  %103 = ptrtoint <32 x i16>* %arrayidx204.2.i to i32
  %add205.2.i = add i32 %103, 1136918528
  %add206.2.i = add i32 %mul200.2.i, %0
  call fastcc void @dma_queue_bursts(i32 %add205.2.i, i32 %add206.2.i, i32 32, i32 2) #5
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0..sroa_cast)
  store volatile i32 0, i32* %status.i355.i, align 4, !tbaa !5
  %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0.5.i357.2.i = load volatile i32, i32* %status.i355.i, align 4, !tbaa !5
  %cmp6.i358.2.i = icmp eq i32 %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0.5.i357.2.i, 0
  br i1 %cmp6.i358.2.i, label %do.body.i362.2.i, label %dma_wait.exit363.2.i

do.body.i362.2.i:                                 ; preds = %dma_wait.exit363.1.i, %do.body.i362.2.i
  %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0.2.i359.2.i = load volatile i32, i32* %status.i355.i, align 4, !tbaa !5
  %104 = call i32 asm sideeffect "STATUS_BC", "=r,ir"(i32 %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0.2.i359.2.i) #5, !srcloc !11
  store volatile i32 %104, i32* %status.i355.i, align 4, !tbaa !5
  %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0..i360.2.i = load volatile i32, i32* %status.i355.i, align 4, !tbaa !5
  %cmp.i361.2.i = icmp eq i32 %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0..i360.2.i, 0
  br i1 %cmp.i361.2.i, label %do.body.i362.2.i, label %dma_wait.exit363.2.i

dma_wait.exit363.2.i:                             ; preds = %do.body.i362.2.i, %dma_wait.exit363.1.i
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0..sroa_cast)
  %mul198.3.i = or i32 %mul198.i, 192
  %add199.3.i = add nuw nsw i32 %mul198.3.i, %o_c.0417.i
  %mul200.3.i = shl i32 %add199.3.i, 1
  %arrayidx204.3.i = getelementptr inbounds [1 x [4 x [4 x [1 x <32 x i16>]]]], [1 x [4 x [4 x [1 x <32 x i16>]]]]* %B_out.i, i32 0, i32 0, i32 %j180.0411.i, i32 3, i32 0
  %105 = ptrtoint <32 x i16>* %arrayidx204.3.i to i32
  %add205.3.i = add i32 %105, 1136918528
  %add206.3.i = add i32 %mul200.3.i, %0
  call fastcc void @dma_queue_bursts(i32 %add205.3.i, i32 %add206.3.i, i32 32, i32 2) #5
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0..sroa_cast)
  store volatile i32 0, i32* %status.i355.i, align 4, !tbaa !5
  %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0.5.i357.3.i = load volatile i32, i32* %status.i355.i, align 4, !tbaa !5
  %cmp6.i358.3.i = icmp eq i32 %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0.5.i357.3.i, 0
  br i1 %cmp6.i358.3.i, label %do.body.i362.3.i, label %dma_wait.exit363.3.i

do.body.i362.3.i:                                 ; preds = %dma_wait.exit363.2.i, %do.body.i362.3.i
  %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0.2.i359.3.i = load volatile i32, i32* %status.i355.i, align 4, !tbaa !5
  %106 = call i32 asm sideeffect "STATUS_BC", "=r,ir"(i32 %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0.2.i359.3.i) #5, !srcloc !11
  store volatile i32 %106, i32* %status.i355.i, align 4, !tbaa !5
  %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0..i360.3.i = load volatile i32, i32* %status.i355.i, align 4, !tbaa !5
  %cmp.i361.3.i = icmp eq i32 %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0..i360.3.i, 0
  br i1 %cmp.i361.3.i, label %do.body.i362.3.i, label %dma_wait.exit363.3.i

dma_wait.exit363.3.i:                             ; preds = %do.body.i362.3.i, %dma_wait.exit363.2.i
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %status.i355.i.0.status.i355.0.status.i355.0.status.i355.0.status.0.status.0..sroa_cast)
  %inc211.i = add nuw nsw i32 %j180.0411.i, 1
  %exitcond460.i = icmp eq i32 %inc211.i, 4
  br i1 %exitcond460.i, label %for.cond.cleanup183.i, label %for.cond186.preheader.i

conv1.exit:                                       ; preds = %for.cond.cleanup3.i
  call void @llvm.lifetime.end.p0i8(i64 2304, i8* nonnull %4) #5
  call void @llvm.lifetime.end.p0i8(i64 288, i8* nonnull %3) #5
  ret void
}

; Function Attrs: noinline nounwind
define internal fastcc void @dma_queue_bursts(i32 %from, i32 %to, i32 %elements, i32 %bytes) unnamed_addr #4 {
entry:
  %mul = mul i32 %bytes, %elements
  %cmp35 = icmp eq i32 %mul, 0
  br i1 %cmp35, label %while.end, label %while.body

while.body:                                       ; preds = %entry, %while.body
  %from.addr.038 = phi i32 [ %add, %while.body ], [ %from, %entry ]
  %to.addr.037 = phi i32 [ %add10, %while.body ], [ %to, %entry ]
  %length.036 = phi i32 [ %sub9, %while.body ], [ %mul, %entry ]
  %and = and i32 %to.addr.037, 4095
  %sub = sub nsw i32 4096, %and
  %and1 = and i32 %from.addr.038, 4095
  %sub2 = sub nsw i32 4096, %and1
  %cmp.i = icmp ult i32 %sub, %sub2
  %cond.i = select i1 %cmp.i, i32 %sub, i32 %sub2
  %or = or i32 %to.addr.037, %from.addr.038
  %and3 = and i32 %or, 3
  %cmp4 = icmp eq i32 %and3, 0
  %0 = icmp ult i32 %length.036, 1024
  %cond.i30 = select i1 %0, i32 %length.036, i32 1024
  %1 = icmp ult i32 %length.036, 1020
  %cond.i34 = select i1 %1, i32 %length.036, i32 1020
  %burst_len.0 = select i1 %cmp4, i32 %cond.i30, i32 %cond.i34
  %cmp.i31 = icmp ult i32 %cond.i, %burst_len.0
  %cond.i32 = select i1 %cmp.i31, i32 %cond.i, i32 %burst_len.0
  %sub8 = add nsw i32 %cond.i32, -1
  tail call void asm sideeffect "BURST_BC", "ir,ir,ir"(i32 %sub8, i32 %from.addr.038, i32 %to.addr.037) #5, !srcloc !14
  %sub9 = sub i32 %length.036, %cond.i32
  %add = add i32 %cond.i32, %from.addr.038
  %add10 = add i32 %cond.i32, %to.addr.037
  %cmp = icmp eq i32 %sub9, 0
  br i1 %cmp, label %while.end, label %while.body

while.end:                                        ; preds = %while.body, %entry
  ret void
}

attributes #0 = { noinline noreturn nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { noinline norecurse noreturn nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { argmemonly nounwind }
attributes #3 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="1024" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { noinline nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { nounwind }
attributes #6 = { nobuiltin nounwind }
attributes #7 = { nobuiltin noreturn }
attributes #8 = { nounwind readnone }

!llvm.ident = !{!0, !1, !1, !0, !0}
!llvm.module.flags = !{!2}

!0 = !{!"clang version 8.0.1 (branches/release_80 365760)"}
!1 = !{!"clang version 8.0.1 (branches/release_80 366197)"}
!2 = !{i32 1, !"wchar_size", i32 4}
!3 = !{i32 666}
!4 = !{i32 1035}
!5 = !{!6, !6, i64 0}
!6 = !{!"int", !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C/C++ TBAA"}
!9 = !{!10, !10, i64 0}
!10 = !{!"long", !7, i64 0}
!11 = !{i32 -2146779765}
!12 = !{!7, !7, i64 0}
!13 = !{i32 -2146779041}
!14 = !{i32 -2146808638}
