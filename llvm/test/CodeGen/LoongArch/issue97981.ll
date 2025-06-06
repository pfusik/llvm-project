; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc --mtriple=loongarch32 --verify-machineinstrs < %s | FileCheck %s --check-prefix=LA32S
; RUN: llc --mtriple=loongarch32 --mattr=+f -target-abi=ilp32s --verify-machineinstrs < %s | FileCheck %s --check-prefix=LA32F-ILP32S
; RUN: llc --mtriple=loongarch32 --mattr=+f -target-abi=ilp32d --verify-machineinstrs < %s | FileCheck %s --check-prefix=LA32F-ILP32D
; RUN: llc --mtriple=loongarch32 --mattr=+d -target-abi=ilp32s --verify-machineinstrs < %s | FileCheck %s --check-prefix=LA32D-ILP32S
; RUN: llc --mtriple=loongarch32 --mattr=+d -target-abi=ilp32d --verify-machineinstrs < %s | FileCheck %s --check-prefix=LA32D-ILP32D
; RUN: llc --mtriple=loongarch64 --verify-machineinstrs < %s | FileCheck %s --check-prefix=LA64S
; RUN: llc --mtriple=loongarch64 --mattr=+f -target-abi=lp64s --verify-machineinstrs < %s | FileCheck %s --check-prefix=LA64F-LP64S
; RUN: llc --mtriple=loongarch64 --mattr=+f -target-abi=lp64d --verify-machineinstrs < %s | FileCheck %s --check-prefix=LA64F-LP64D
; RUN: llc --mtriple=loongarch64 --mattr=+d -target-abi=lp64s --verify-machineinstrs < %s | FileCheck %s --check-prefix=LA64D-LP64S
; RUN: llc --mtriple=loongarch64 --mattr=+d -target-abi=lp64d --verify-machineinstrs < %s | FileCheck %s --check-prefix=LA64D-LP64D

define half @to_half(i16 %bits) {
; LA32S-LABEL: to_half:
; LA32S:       # %bb.0:
; LA32S-NEXT:    ret
;
; LA32F-ILP32S-LABEL: to_half:
; LA32F-ILP32S:       # %bb.0:
; LA32F-ILP32S-NEXT:    lu12i.w $a1, -16
; LA32F-ILP32S-NEXT:    or $a0, $a0, $a1
; LA32F-ILP32S-NEXT:    ret
;
; LA32F-ILP32D-LABEL: to_half:
; LA32F-ILP32D:       # %bb.0:
; LA32F-ILP32D-NEXT:    lu12i.w $a1, -16
; LA32F-ILP32D-NEXT:    or $a0, $a0, $a1
; LA32F-ILP32D-NEXT:    movgr2fr.w $fa0, $a0
; LA32F-ILP32D-NEXT:    ret
;
; LA32D-ILP32S-LABEL: to_half:
; LA32D-ILP32S:       # %bb.0:
; LA32D-ILP32S-NEXT:    lu12i.w $a1, -16
; LA32D-ILP32S-NEXT:    or $a0, $a0, $a1
; LA32D-ILP32S-NEXT:    ret
;
; LA32D-ILP32D-LABEL: to_half:
; LA32D-ILP32D:       # %bb.0:
; LA32D-ILP32D-NEXT:    lu12i.w $a1, -16
; LA32D-ILP32D-NEXT:    or $a0, $a0, $a1
; LA32D-ILP32D-NEXT:    movgr2fr.w $fa0, $a0
; LA32D-ILP32D-NEXT:    ret
;
; LA64S-LABEL: to_half:
; LA64S:       # %bb.0:
; LA64S-NEXT:    lu12i.w $a1, -16
; LA64S-NEXT:    or $a0, $a0, $a1
; LA64S-NEXT:    movgr2fr.w $fa0, $a0
; LA64S-NEXT:    ret
;
; LA64F-LP64S-LABEL: to_half:
; LA64F-LP64S:       # %bb.0:
; LA64F-LP64S-NEXT:    lu12i.w $a1, -16
; LA64F-LP64S-NEXT:    or $a0, $a0, $a1
; LA64F-LP64S-NEXT:    ret
;
; LA64F-LP64D-LABEL: to_half:
; LA64F-LP64D:       # %bb.0:
; LA64F-LP64D-NEXT:    lu12i.w $a1, -16
; LA64F-LP64D-NEXT:    or $a0, $a0, $a1
; LA64F-LP64D-NEXT:    movgr2fr.w $fa0, $a0
; LA64F-LP64D-NEXT:    ret
;
; LA64D-LP64S-LABEL: to_half:
; LA64D-LP64S:       # %bb.0:
; LA64D-LP64S-NEXT:    lu12i.w $a1, -16
; LA64D-LP64S-NEXT:    or $a0, $a0, $a1
; LA64D-LP64S-NEXT:    ret
;
; LA64D-LP64D-LABEL: to_half:
; LA64D-LP64D:       # %bb.0:
; LA64D-LP64D-NEXT:    lu12i.w $a1, -16
; LA64D-LP64D-NEXT:    or $a0, $a0, $a1
; LA64D-LP64D-NEXT:    movgr2fr.w $fa0, $a0
; LA64D-LP64D-NEXT:    ret
    %f = bitcast i16 %bits to half
    ret half %f
}

define i16 @from_half(half %f) {
; LA32S-LABEL: from_half:
; LA32S:       # %bb.0:
; LA32S-NEXT:    ret
;
; LA32F-ILP32S-LABEL: from_half:
; LA32F-ILP32S:       # %bb.0:
; LA32F-ILP32S-NEXT:    ret
;
; LA32F-ILP32D-LABEL: from_half:
; LA32F-ILP32D:       # %bb.0:
; LA32F-ILP32D-NEXT:    movfr2gr.s $a0, $fa0
; LA32F-ILP32D-NEXT:    ret
;
; LA32D-ILP32S-LABEL: from_half:
; LA32D-ILP32S:       # %bb.0:
; LA32D-ILP32S-NEXT:    ret
;
; LA32D-ILP32D-LABEL: from_half:
; LA32D-ILP32D:       # %bb.0:
; LA32D-ILP32D-NEXT:    movfr2gr.s $a0, $fa0
; LA32D-ILP32D-NEXT:    ret
;
; LA64S-LABEL: from_half:
; LA64S:       # %bb.0:
; LA64S-NEXT:    movfr2gr.s $a0, $fa0
; LA64S-NEXT:    ret
;
; LA64F-LP64S-LABEL: from_half:
; LA64F-LP64S:       # %bb.0:
; LA64F-LP64S-NEXT:    ret
;
; LA64F-LP64D-LABEL: from_half:
; LA64F-LP64D:       # %bb.0:
; LA64F-LP64D-NEXT:    movfr2gr.s $a0, $fa0
; LA64F-LP64D-NEXT:    ret
;
; LA64D-LP64S-LABEL: from_half:
; LA64D-LP64S:       # %bb.0:
; LA64D-LP64S-NEXT:    ret
;
; LA64D-LP64D-LABEL: from_half:
; LA64D-LP64D:       # %bb.0:
; LA64D-LP64D-NEXT:    movfr2gr.s $a0, $fa0
; LA64D-LP64D-NEXT:    ret
    %bits = bitcast half %f to i16
    ret i16 %bits
}
