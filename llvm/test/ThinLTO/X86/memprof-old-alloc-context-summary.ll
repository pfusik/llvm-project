;; Check that we can read the old *_ALLOC_INFO summary format that placed the
;; stack id indexes directly in the alloc info summary, rather than encoding as
;; a separate radix tree.
;;
;; The old bitcode was generated by the older compiler from `opt -thinlto-bc`
;; on the following LLVM assembly:
;;
;; target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
;; target triple = "x86_64-unknown-linux-gnu"
;;
;; define internal ptr @_Z3barv() #0 {
;; entry:
;;   %call = call ptr @_Znam(i64 0), !memprof !1, !callsite !6
;;   ret ptr null
;; }
;;
;; declare ptr @_Znam(i64)
;;
;; !1 = !{!2, !4}
;; !2 = !{!3, !"notcold"}
;; !3 = !{i64 9086428284934609951, i64 8632435727821051414}
;; !4 = !{!5, !"cold"}
;; !5 = !{i64 9086428284934609951, i64 2732490490862098848}
;; !6 = !{i64 9086428284934609951}

; RUN: llvm-dis %S/Inputs/memprof-old-alloc-context-summary.bc -o - | FileCheck %s
; CHECK: stackIds: (8632435727821051414)
; CHECK-SAME: stackIds: (2732490490862098848)
