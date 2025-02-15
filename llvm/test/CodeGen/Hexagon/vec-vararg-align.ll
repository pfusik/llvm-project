; RUN: llc -mtriple=hexagon < %s | FileCheck %s
;
; Check that the stack is aligned according to the outgoing function arguments.
; CHECK: r29 = and(r29,#-64)

target triple = "hexagon-unknown--elf"

@.str = private unnamed_addr constant [32 x i8] c"\0AMixed Vectors, Pairs, int flt\0A\00", align 1
@.str.1 = private unnamed_addr constant [11 x i8] c"\0AVar args\0A\00", align 1
@gVec0 = common global <16 x i32> zeroinitializer, align 64
@gVec10 = common global <32 x i32> zeroinitializer, align 128
@gi1 = common global i32 0, align 4
@gf1 = common global float 0.000000e+00, align 4

define i32 @main() #0 {
b0:
  %v1 = call i32 (ptr, ...) @printf(ptr @.str) #0
  %v2 = load <16 x i32>, ptr @gVec0, align 64
  %v3 = load <32 x i32>, ptr @gVec10, align 128
  %v4 = load i32, ptr @gi1, align 4
  %v5 = load float, ptr @gf1, align 4
  %v6 = fpext float %v5 to double
  call void (ptr, i32, ...) @VarVec1(ptr @.str.1, i32 4, <16 x i32> %v2, <32 x i32> %v3, i32 %v4, double %v6)
  ret i32 0
}

declare i32 @printf(ptr, ...) #0
declare void @VarVec1(ptr, i32, ...) #0

attributes #0 = { nounwind "target-cpu"="hexagonv60" "target-features"="+hvxv60,+hvx-length64b" }
