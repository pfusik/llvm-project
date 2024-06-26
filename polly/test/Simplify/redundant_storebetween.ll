; RUN: opt %loadNPMPolly "-passes=scop(print<polly-simplify>)" -disable-output -aa-pipeline=basic-aa < %s | FileCheck %s -match-full-lines
;
; Don't remove store where there is another store to the same target
; in-between them.
;
; for (int j = 0; j < n; j += 1)
;   A[0] = A[0];
;
define void @func(i32 %n, ptr noalias nonnull %A) {
entry:
  br label %for

for:
  %j = phi i32 [0, %entry], [%j.inc, %inc]
  %j.cmp = icmp slt i32 %j, %n
  br i1 %j.cmp, label %body, label %exit

    body:
      %A_idx = getelementptr inbounds double, ptr %A, i32 %j
      %val = load double, ptr %A_idx
      store double 0.0, ptr %A
      store double %val, ptr %A_idx
      br label %inc

inc:
  %j.inc = add nuw nsw i32 %j, 1
  br label %for

exit:
  br label %return

return:
  ret void
}


; CHECK: SCoP could not be simplified

