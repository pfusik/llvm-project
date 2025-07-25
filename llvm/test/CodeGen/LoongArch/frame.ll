; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 5
; RUN: llc --mtriple=loongarch64 -mattr=+d,-lsx < %s | FileCheck %s --check-prefixes=CHECK,NOLSX
; RUN: llc --mtriple=loongarch64 -mattr=+d,+lsx < %s | FileCheck %s --check-prefixes=CHECK,LSX

%struct.key_t = type { i32, [16 x i8] }

declare void @llvm.memset.p0.i64(ptr, i8, i64, i1)
declare void @test1(ptr)

define i32 @test() nounwind {
; NOLSX-LABEL: test:
; NOLSX:       # %bb.0:
; NOLSX-NEXT:    addi.d $sp, $sp, -32
; NOLSX-NEXT:    st.d $ra, $sp, 24 # 8-byte Folded Spill
; NOLSX-NEXT:    st.w $zero, $sp, 16
; NOLSX-NEXT:    st.d $zero, $sp, 8
; NOLSX-NEXT:    st.d $zero, $sp, 0
; NOLSX-NEXT:    addi.d $a0, $sp, 4
; NOLSX-NEXT:    pcaddu18i $ra, %call36(test1)
; NOLSX-NEXT:    jirl $ra, $ra, 0
; NOLSX-NEXT:    move $a0, $zero
; NOLSX-NEXT:    ld.d $ra, $sp, 24 # 8-byte Folded Reload
; NOLSX-NEXT:    addi.d $sp, $sp, 32
; NOLSX-NEXT:    ret
;
; LSX-LABEL: test:
; LSX:       # %bb.0:
; LSX-NEXT:    addi.d $sp, $sp, -32
; LSX-NEXT:    st.d $ra, $sp, 24 # 8-byte Folded Spill
; LSX-NEXT:    st.w $zero, $sp, 16
; LSX-NEXT:    vrepli.b $vr0, 0
; LSX-NEXT:    vst $vr0, $sp, 0
; LSX-NEXT:    addi.d $a0, $sp, 4
; LSX-NEXT:    pcaddu18i $ra, %call36(test1)
; LSX-NEXT:    jirl $ra, $ra, 0
; LSX-NEXT:    move $a0, $zero
; LSX-NEXT:    ld.d $ra, $sp, 24 # 8-byte Folded Reload
; LSX-NEXT:    addi.d $sp, $sp, 32
; LSX-NEXT:    ret
  %key = alloca %struct.key_t, align 4
  call void @llvm.memset.p0.i64(ptr %key, i8 0, i64 20, i1 false)
  %1 = getelementptr inbounds %struct.key_t, ptr %key, i64 0, i32 1, i64 0
  call void @test1(ptr %1)
  ret i32 0
}

;; Note: will create an emergency spill slot, if (!isInt<11>(StackSize)).
;; Should involve only one SP-adjusting addi per adjustment.
define void @test_large_frame_size_2032() {
; CHECK-LABEL: test_large_frame_size_2032:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addi.d $sp, $sp, -2032
; CHECK-NEXT:    .cfi_def_cfa_offset 2032
; CHECK-NEXT:    addi.d $sp, $sp, 2032
; CHECK-NEXT:    ret
  %1 = alloca i8, i32 2016 ; + 16(emergency slot) = 2032
  ret void
}

;; Should involve two SP-adjusting addi's when adjusting SP up, but only one
;; when adjusting down.
define void @test_large_frame_size_2048() {
; CHECK-LABEL: test_large_frame_size_2048:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addi.d $sp, $sp, -2048
; CHECK-NEXT:    .cfi_def_cfa_offset 2048
; CHECK-NEXT:    addi.d $sp, $sp, 2032
; CHECK-NEXT:    addi.d $sp, $sp, 16
; CHECK-NEXT:    ret
  %1 = alloca i8, i32 2032 ; + 16(emergency slot) = 2048
  ret void
}

;; Should involve two SP-adjusting addi's per adjustment.
define void @test_large_frame_size_2064() {
; CHECK-LABEL: test_large_frame_size_2064:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addi.d $sp, $sp, -2048
; CHECK-NEXT:    addi.d $sp, $sp, -16
; CHECK-NEXT:    .cfi_def_cfa_offset 2064
; CHECK-NEXT:    addi.d $sp, $sp, 2032
; CHECK-NEXT:    addi.d $sp, $sp, 32
; CHECK-NEXT:    ret
  %1 = alloca i8, i32 2048 ; + 16(emergency slot) = 2064
  ret void
}

;; NOTE: Due to the problem with the emegency spill slot, the scratch register
;; will not be used when the fp is eliminated. To make this test valid, add the
;; attribute "frame-pointer=all".

;; SP should be adjusted with help of a scratch register.
define void @test_large_frame_size_1234576() "frame-pointer"="all" {
; CHECK-LABEL: test_large_frame_size_1234576:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addi.d $sp, $sp, -2032
; CHECK-NEXT:    .cfi_def_cfa_offset 2032
; CHECK-NEXT:    st.d $ra, $sp, 2024 # 8-byte Folded Spill
; CHECK-NEXT:    st.d $fp, $sp, 2016 # 8-byte Folded Spill
; CHECK-NEXT:    .cfi_offset 1, -8
; CHECK-NEXT:    .cfi_offset 22, -16
; CHECK-NEXT:    addi.d $fp, $sp, 2032
; CHECK-NEXT:    .cfi_def_cfa 22, 0
; CHECK-NEXT:    lu12i.w $a0, 300
; CHECK-NEXT:    ori $a0, $a0, 3760
; CHECK-NEXT:    sub.d $sp, $sp, $a0
; CHECK-NEXT:    lu12i.w $a0, 300
; CHECK-NEXT:    ori $a0, $a0, 3760
; CHECK-NEXT:    add.d $sp, $sp, $a0
; CHECK-NEXT:    ld.d $fp, $sp, 2016 # 8-byte Folded Reload
; CHECK-NEXT:    ld.d $ra, $sp, 2024 # 8-byte Folded Reload
; CHECK-NEXT:    addi.d $sp, $sp, 2032
; CHECK-NEXT:    ret
  %1 = alloca i8, i32 1234567
  ret void
}

;; Note: will create an emergency spill slot, if (!isInt<7>(StackSize)).
;; Should involve only one SP-adjusting addi per adjustment.
;; LSX 112 + 16(emergency solt) = 128
define void @test_frame_size_112() {
; NOLSX-LABEL: test_frame_size_112:
; NOLSX:       # %bb.0:
; NOLSX-NEXT:    addi.d $sp, $sp, -112
; NOLSX-NEXT:    .cfi_def_cfa_offset 112
; NOLSX-NEXT:    addi.d $sp, $sp, 112
; NOLSX-NEXT:    ret
;
; LSX-LABEL: test_frame_size_112:
; LSX:       # %bb.0:
; LSX-NEXT:    addi.d $sp, $sp, -128
; LSX-NEXT:    .cfi_def_cfa_offset 128
; LSX-NEXT:    addi.d $sp, $sp, 128
; LSX-NEXT:    ret
  %1 = alloca i8, i32 112
  ret void
}

;; LSX 128 + 16(emergency solt) = 144
define void @test_frame_size_128() {
; NOLSX-LABEL: test_frame_size_128:
; NOLSX:       # %bb.0:
; NOLSX-NEXT:    addi.d $sp, $sp, -128
; NOLSX-NEXT:    .cfi_def_cfa_offset 128
; NOLSX-NEXT:    addi.d $sp, $sp, 128
; NOLSX-NEXT:    ret
;
; LSX-LABEL: test_frame_size_128:
; LSX:       # %bb.0:
; LSX-NEXT:    addi.d $sp, $sp, -144
; LSX-NEXT:    .cfi_def_cfa_offset 144
; LSX-NEXT:    addi.d $sp, $sp, 144
; LSX-NEXT:    ret
  %1 = alloca i8, i32 128
  ret void
}

;; LSX 144 + 16(emergency solt) = 160
define void @test_frame_size_144() {
; NOLSX-LABEL: test_frame_size_144:
; NOLSX:       # %bb.0:
; NOLSX-NEXT:    addi.d $sp, $sp, -144
; NOLSX-NEXT:    .cfi_def_cfa_offset 144
; NOLSX-NEXT:    addi.d $sp, $sp, 144
; NOLSX-NEXT:    ret
;
; LSX-LABEL: test_frame_size_144:
; LSX:       # %bb.0:
; LSX-NEXT:    addi.d $sp, $sp, -160
; LSX-NEXT:    .cfi_def_cfa_offset 160
; LSX-NEXT:    addi.d $sp, $sp, 160
; LSX-NEXT:    ret
  %1 = alloca i8, i32 144
  ret void
}
