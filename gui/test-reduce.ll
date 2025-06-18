; ModuleID = 'test-reduce.c'
source_filename = "test-reduce.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.ompi_predefined_datatype_t = type opaque
%struct.ompi_predefined_op_t = type opaque
%struct.ompi_predefined_communicator_t = type opaque

@ompi_mpi_int = external global %struct.ompi_predefined_datatype_t, align 1
@ompi_mpi_op_sum = external global %struct.ompi_predefined_op_t, align 1
@ompi_mpi_comm_world = external global %struct.ompi_predefined_communicator_t, align 1
@ompi_mpi_op_max = external global %struct.ompi_predefined_op_t, align 1
@ompi_mpi_op_min = external global %struct.ompi_predefined_op_t, align 1
@ompi_mpi_float = external global %struct.ompi_predefined_datatype_t, align 1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @my_sum(ptr noundef %0, ptr noundef %1, ptr noundef %2, ptr noundef %3) #0 {
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  %7 = alloca ptr, align 8
  %8 = alloca ptr, align 8
  %9 = alloca ptr, align 8
  %10 = alloca ptr, align 8
  %11 = alloca i32, align 4
  store ptr %0, ptr %5, align 8
  store ptr %1, ptr %6, align 8
  store ptr %2, ptr %7, align 8
  store ptr %3, ptr %8, align 8
  %12 = load ptr, ptr %5, align 8
  store ptr %12, ptr %9, align 8
  %13 = load ptr, ptr %6, align 8
  store ptr %13, ptr %10, align 8
  store i32 0, ptr %11, align 4
  br label %14

14:                                               ; preds = %31, %4
  %15 = load i32, ptr %11, align 4
  %16 = load ptr, ptr %7, align 8
  %17 = load i32, ptr %16, align 4
  %18 = icmp slt i32 %15, %17
  br i1 %18, label %19, label %34

19:                                               ; preds = %14
  %20 = load ptr, ptr %9, align 8
  %21 = load i32, ptr %11, align 4
  %22 = sext i32 %21 to i64
  %23 = getelementptr inbounds i32, ptr %20, i64 %22
  %24 = load i32, ptr %23, align 4
  %25 = load ptr, ptr %10, align 8
  %26 = load i32, ptr %11, align 4
  %27 = sext i32 %26 to i64
  %28 = getelementptr inbounds i32, ptr %25, i64 %27
  %29 = load i32, ptr %28, align 4
  %30 = add nsw i32 %29, %24
  store i32 %30, ptr %28, align 4
  br label %31

31:                                               ; preds = %19
  %32 = load i32, ptr %11, align 4
  %33 = add nsw i32 %32, 1
  store i32 %33, ptr %11, align 4
  br label %14, !llvm.loop !6

34:                                               ; preds = %14
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @explicit_reductions(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca ptr, align 8
  store i32 %0, ptr %2, align 4
  %8 = load i32, ptr %2, align 4
  %9 = add nsw i32 %8, 1
  store i32 %9, ptr %3, align 4
  %10 = call i32 @MPI_Reduce(ptr noundef %3, ptr noundef %4, i32 noundef 1, ptr noundef @ompi_mpi_int, ptr noundef @ompi_mpi_op_sum, i32 noundef 0, ptr noundef @ompi_mpi_comm_world)
  %11 = call i32 @MPI_Reduce(ptr noundef %3, ptr noundef %5, i32 noundef 1, ptr noundef @ompi_mpi_int, ptr noundef @ompi_mpi_op_max, i32 noundef 0, ptr noundef @ompi_mpi_comm_world)
  %12 = call i32 @MPI_Allreduce(ptr noundef %3, ptr noundef %6, i32 noundef 1, ptr noundef @ompi_mpi_int, ptr noundef @ompi_mpi_op_min, ptr noundef @ompi_mpi_comm_world)
  %13 = call i32 @MPI_Op_create(ptr noundef @my_sum, i32 noundef 1, ptr noundef %7)
  %14 = load ptr, ptr %7, align 8
  %15 = call i32 @MPI_Reduce(ptr noundef %3, ptr noundef %4, i32 noundef 1, ptr noundef @ompi_mpi_int, ptr noundef %14, i32 noundef 0, ptr noundef @ompi_mpi_comm_world)
  %16 = call i32 @MPI_Op_free(ptr noundef %7)
  ret void
}

declare i32 @MPI_Reduce(ptr noundef, ptr noundef, i32 noundef, ptr noundef, ptr noundef, i32 noundef, ptr noundef) #1

declare i32 @MPI_Allreduce(ptr noundef, ptr noundef, i32 noundef, ptr noundef, ptr noundef, ptr noundef) #1

declare i32 @MPI_Op_create(ptr noundef, i32 noundef, ptr noundef) #1

declare i32 @MPI_Op_free(ptr noundef) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @manual_reduction(i32 noundef %0, i32 noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca float, align 4
  %6 = alloca float, align 4
  %7 = alloca i32, align 4
  %8 = alloca float, align 4
  store i32 %0, ptr %3, align 4
  store i32 %1, ptr %4, align 4
  %9 = load i32, ptr %3, align 4
  %10 = sitofp i32 %9 to float
  %11 = fmul float %10, 1.500000e+00
  store float %11, ptr %5, align 4
  store float 0.000000e+00, ptr %6, align 4
  store i32 1, ptr %7, align 4
  br label %12

12:                                               ; preds = %42, %2
  %13 = load i32, ptr %7, align 4
  %14 = load i32, ptr %4, align 4
  %15 = icmp slt i32 %13, %14
  br i1 %15, label %16, label %45

16:                                               ; preds = %12
  %17 = load i32, ptr %3, align 4
  %18 = load i32, ptr %7, align 4
  %19 = mul nsw i32 2, %18
  %20 = srem i32 %17, %19
  %21 = icmp eq i32 %20, 0
  br i1 %21, label %22, label %30

22:                                               ; preds = %16
  %23 = load i32, ptr %3, align 4
  %24 = load i32, ptr %7, align 4
  %25 = add nsw i32 %23, %24
  %26 = call i32 @MPI_Recv(ptr noundef %8, i32 noundef 1, ptr noundef @ompi_mpi_float, i32 noundef %25, i32 noundef 0, ptr noundef @ompi_mpi_comm_world, ptr noundef null)
  %27 = load float, ptr %8, align 4
  %28 = load float, ptr %5, align 4
  %29 = fadd float %28, %27
  store float %29, ptr %5, align 4
  br label %41

30:                                               ; preds = %16
  %31 = load i32, ptr %3, align 4
  %32 = load i32, ptr %7, align 4
  %33 = srem i32 %31, %32
  %34 = icmp eq i32 %33, 0
  br i1 %34, label %35, label %40

35:                                               ; preds = %30
  %36 = load i32, ptr %3, align 4
  %37 = load i32, ptr %7, align 4
  %38 = sub nsw i32 %36, %37
  %39 = call i32 @MPI_Send(ptr noundef %5, i32 noundef 1, ptr noundef @ompi_mpi_float, i32 noundef %38, i32 noundef 0, ptr noundef @ompi_mpi_comm_world)
  br label %40

40:                                               ; preds = %35, %30
  br label %41

41:                                               ; preds = %40, %22
  br label %42

42:                                               ; preds = %41
  %43 = load i32, ptr %7, align 4
  %44 = mul nsw i32 %43, 2
  store i32 %44, ptr %7, align 4
  br label %12, !llvm.loop !8

45:                                               ; preds = %12
  ret void
}

declare i32 @MPI_Recv(ptr noundef, i32 noundef, ptr noundef, i32 noundef, i32 noundef, ptr noundef, ptr noundef) #1

declare i32 @MPI_Send(ptr noundef, i32 noundef, ptr noundef, i32 noundef, i32 noundef, ptr noundef) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main(i32 noundef %0, ptr noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca ptr, align 8
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  store i32 0, ptr %3, align 4
  store i32 %0, ptr %4, align 4
  store ptr %1, ptr %5, align 8
  %8 = call i32 @MPI_Init(ptr noundef %4, ptr noundef %5)
  %9 = call i32 @MPI_Comm_rank(ptr noundef @ompi_mpi_comm_world, ptr noundef %6)
  %10 = call i32 @MPI_Comm_size(ptr noundef @ompi_mpi_comm_world, ptr noundef %7)
  %11 = load i32, ptr %6, align 4
  call void @explicit_reductions(i32 noundef %11)
  %12 = load i32, ptr %6, align 4
  %13 = load i32, ptr %7, align 4
  call void @manual_reduction(i32 noundef %12, i32 noundef %13)
  %14 = call i32 @MPI_Finalize()
  ret i32 0
}

declare i32 @MPI_Init(ptr noundef, ptr noundef) #1

declare i32 @MPI_Comm_rank(ptr noundef, ptr noundef) #1

declare i32 @MPI_Comm_size(ptr noundef, ptr noundef) #1

declare i32 @MPI_Finalize() #1

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"Ubuntu clang version 15.0.7"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
!8 = distinct !{!8, !7}
