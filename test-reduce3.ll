; ModuleID = 'test-reduce3.c'
source_filename = "test-reduce3.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.ompi_predefined_communicator_t = type opaque
%struct.ompi_predefined_datatype_t = type opaque
%struct.ompi_predefined_op_t = type opaque

@ompi_mpi_comm_world = external global %struct.ompi_predefined_communicator_t, align 1
@ompi_mpi_double = external global %struct.ompi_predefined_datatype_t, align 1
@ompi_mpi_op_sum = external global %struct.ompi_predefined_op_t, align 1
@.str = private unnamed_addr constant [20 x i8] c"Reduced value = %f\0A\00", align 1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main(i32 noundef %0, ptr noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca ptr, align 8
  %6 = alloca i32, align 4
  %7 = alloca double, align 8
  %8 = alloca double, align 8
  store i32 0, ptr %3, align 4
  store i32 %0, ptr %4, align 4
  store ptr %1, ptr %5, align 8
  %9 = call i32 @MPI_Init(ptr noundef %4, ptr noundef %5)
  %10 = call i32 @MPI_Comm_rank(ptr noundef @ompi_mpi_comm_world, ptr noundef %6)
  %11 = load i32, ptr %6, align 4
  %12 = add nsw i32 %11, 1
  %13 = sitofp i32 %12 to double
  %14 = fmul double %13, 1.500000e+00
  store double %14, ptr %7, align 8
  %15 = call i32 @MPI_Reduce(ptr noundef %7, ptr noundef %8, i32 noundef 1, ptr noundef @ompi_mpi_double, ptr noundef @ompi_mpi_op_sum, i32 noundef 0, ptr noundef @ompi_mpi_comm_world)
  %16 = load i32, ptr %6, align 4
  %17 = icmp eq i32 %16, 0
  br i1 %17, label %18, label %21

18:                                               ; preds = %2
  %19 = load double, ptr %8, align 8
  %20 = call i32 (ptr, ...) @printf(ptr noundef @.str, double noundef %19)
  br label %21

21:                                               ; preds = %18, %2
  %22 = call i32 @MPI_Finalize()
  ret i32 0
}

declare i32 @MPI_Init(ptr noundef, ptr noundef) #1

declare i32 @MPI_Comm_rank(ptr noundef, ptr noundef) #1

declare i32 @MPI_Reduce(ptr noundef, ptr noundef, i32 noundef, ptr noundef, ptr noundef, i32 noundef, ptr noundef) #1

declare i32 @printf(ptr noundef, ...) #1

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
