; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 5
; RUN: opt -S --passes=slp-vectorizer -mtriple=x86_64-unknown-linux-gnu < %s | FileCheck %s

@g = global [128 x i8] zeroinitializer, align 16

define i64 @test() {
; CHECK-LABEL: define i64 @test() {
; CHECK-NEXT:  [[ENTRY:.*:]]
; CHECK-NEXT:    [[TMP0:%.*]] = load i64, ptr @g, align 8
; CHECK-NEXT:    br label %[[FUNC_154_EXIT_FUNC_146_EXIT_CRIT_EDGE_I:.*]]
; CHECK:       [[FUNC_154_EXIT_FUNC_146_EXIT_CRIT_EDGE_I]]:
; CHECK-NEXT:    [[TMP1:%.*]] = load i64, ptr getelementptr inbounds nuw (i8, ptr @g, i64 80), align 16
; CHECK-NEXT:    [[TMP2:%.*]] = load i64, ptr getelementptr inbounds nuw (i8, ptr @g, i64 88), align 8
; CHECK-NEXT:    [[TMP3:%.*]] = load i64, ptr getelementptr inbounds nuw (i8, ptr @g, i64 32), align 16
; CHECK-NEXT:    [[TMP4:%.*]] = load i64, ptr @g, align 16
; CHECK-NEXT:    [[TMP5:%.*]] = load i64, ptr getelementptr inbounds nuw (i8, ptr @g, i64 8), align 8
; CHECK-NEXT:    [[TMP6:%.*]] = load i64, ptr @g, align 16
; CHECK-NEXT:    [[TMP7:%.*]] = load i64, ptr getelementptr inbounds nuw (i8, ptr @g, i64 24), align 8
; CHECK-NEXT:    [[TMP8:%.*]] = xor i64 [[TMP1]], [[TMP2]]
; CHECK-NEXT:    [[TMP9:%.*]] = xor i64 [[TMP8]], [[TMP3]]
; CHECK-NEXT:    [[TMP10:%.*]] = xor i64 [[TMP9]], [[TMP4]]
; CHECK-NEXT:    [[TMP11:%.*]] = xor i64 [[TMP10]], [[TMP5]]
; CHECK-NEXT:    [[TMP12:%.*]] = xor i64 [[TMP11]], [[TMP6]]
; CHECK-NEXT:    [[TMP13:%.*]] = xor i64 [[TMP12]], [[TMP7]]
; CHECK-NEXT:    [[TMP14:%.*]] = xor i64 [[TMP13]], [[TMP0]]
; CHECK-NEXT:    ret i64 [[TMP14]]
;
entry:
  %0 = load i64, ptr @g, align 8
  br label %func_154.exit.func_146.exit_crit_edge.i

func_154.exit.func_146.exit_crit_edge.i:
  %1 = load i64, ptr getelementptr inbounds nuw (i8, ptr @g, i64 80), align 16
  %2 = load i64, ptr getelementptr inbounds nuw (i8, ptr @g, i64 88), align 8
  %3 = load i64, ptr getelementptr inbounds nuw (i8, ptr @g, i64 32), align 16
  %4 = load i64, ptr @g, align 16
  %5 = load i64, ptr getelementptr inbounds nuw (i8, ptr @g, i64 8), align 8
  %6 = load i64, ptr @g, align 16
  %7 = load i64, ptr getelementptr inbounds nuw (i8, ptr @g, i64 24), align 8
  %8 = xor i64 %1, %2
  %9 = xor i64 %8, %3
  %10 = xor i64 %9, %4
  %11 = xor i64 %10, %5
  %12 = xor i64 %11, %6
  %13 = xor i64 %12, %7
  %14 = xor i64 %13, %0
  ret i64 %14
}
