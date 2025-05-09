// RUN: mlir-opt %s -split-input-file -pass-pipeline="builtin.module(func.func(test-affine-loop-unswitch))" | FileCheck %s

// CHECK-DAG: #[[$SET:.*]] = affine_set<(d0) : (d0 - 2 >= 0)>

// CHECK-LABEL: func @if_else_imperfect
func.func @if_else_imperfect(%A : memref<100xi32>, %B : memref<100xi32>, %v : i32) {
// CHECK: %[[A:.*]]: memref<100xi32>, %[[B:.*]]: memref
  affine.for %i = 0 to 100 {
    affine.store %v, %A[%i] : memref<100xi32>
    affine.for %j = 0 to 100 {
      affine.store %v, %A[%j] : memref<100xi32>
      affine.if affine_set<(d0) : (d0 - 2 >= 0)>(%i) {
        affine.store %v, %B[%j] : memref<100xi32>
      }
      func.call @external() : () -> ()
    }
    affine.store %v, %A[%i] : memref<100xi32>
  }
  return
}
func.func private @external()

// CHECK:       affine.for %[[I:.*]] = 0 to 100 {
// CHECK-NEXT:    affine.store %{{.*}}, %[[A]][%[[I]]]
// CHECK-NEXT:    affine.if #[[$SET]](%[[I]]) {
// CHECK-NEXT:      affine.for %[[J:.*]] = 0 to 100 {
// CHECK-NEXT:        affine.store %{{.*}}, %[[A]][%[[J]]]
// CHECK-NEXT:        affine.store %{{.*}}, %[[B]][%[[J]]]
// CHECK-NEXT:        call
// CHECK-NEXT:      }
// CHECK-NEXT:    } else {
// CHECK-NEXT:      affine.for %[[JJ:.*]] = 0 to 100 {
// CHECK-NEXT:        affine.store %{{.*}}, %[[A]][%[[J]]]
// CHECK-NEXT:        call
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    affine.store %{{.*}}, %[[A]][%[[I]]]
// CHECK-NEXT:  }
// CHECK-NEXT:  return

// -----

func.func private @foo()
func.func private @bar()
func.func private @abc()
func.func private @xyz()

// CHECK-LABEL: func @if_then_perfect
func.func @if_then_perfect(%A : memref<100xi32>, %v : i32) {
  affine.for %i = 0 to 100 {
    affine.for %j = 0 to 100 {
      affine.for %k = 0 to 100 {
        affine.if affine_set<(d0) : (d0 - 2 >= 0)>(%i) {
          affine.store %v, %A[%i] : memref<100xi32>
        }
      }
    }
  }
  return
}
// CHECK:      affine.for
// CHECK-NEXT:   affine.if
// CHECK-NEXT:     affine.for
// CHECK-NEXT:       affine.for
// CHECK-NOT:    else


// CHECK-LABEL: func @if_else_perfect
func.func @if_else_perfect(%A : memref<100xi32>, %v : i32) {
  affine.for %i = 0 to 99 {
    affine.for %j = 0 to 100 {
      affine.for %k = 0 to 100 {
        func.call @foo() : () -> ()
        affine.if affine_set<(d0, d1) : (d0 - 2 >= 0, -d1 + 80 >= 0)>(%i, %j) {
          affine.store %v, %A[%i] : memref<100xi32>
          func.call @abc() : () -> ()
        } else {
          affine.store %v, %A[%i + 1] : memref<100xi32>
          func.call @xyz() : () -> ()
        }
        func.call @bar() : () -> ()
      }
    }
  }
  return
}
// CHECK:      affine.for
// CHECK-NEXT:   affine.for
// CHECK-NEXT:     affine.if
// CHECK-NEXT:       affine.for
// CHECK-NEXT:         call @foo
// CHECK-NEXT:         affine.store %{{.*}}, %{{.*}}[%{{.*}}]
// CHECK-NEXT:         call @abc
// CHECK-NEXT:         call @bar
// CHECK-NEXT:       }
// CHECK-NEXT:     else
// CHECK-NEXT:       affine.for
// CHECK-NEXT:         call @foo
// CHECK-NEXT:         affine.store %{{.*}}, %{{.*}}[%{{.*}} + 1]
// CHECK-NEXT:         call @xyz
// CHECK-NEXT:         call @bar
// CHECK-NEXT:       }
// CHECK-NEXT:     }
// CHECK-NEXT:   }
// CHECK-NEXT: }

// CHECK-LABEL: func @if_then_imperfect
func.func @if_then_imperfect(%A : memref<100xi32>, %N : index, %v: i32) {
  affine.for %i = 0 to 100 {
    affine.store %v, %A[0] : memref<100xi32>
    affine.if affine_set<(d0) : (d0 - 2 >= 0)>(%N) {
      affine.store %v, %A[%i] : memref<100xi32>
    }
  }
  return
}
// CHECK:       affine.if
// CHECK-NEXT:    affine.for
// CHECK-NEXT:      affine.store
// CHECK-NEXT:      affine.store
// CHECK-NEXT:    }
// CHECK-NEXT:  } else {
// CHECK-NEXT:    affine.for
// CHECK-NEXT:      affine.store
// CHECK-NEXT:    }
// CHECK-NEXT:  }
// CHECK-NEXT:  return

// Check if unused operands are dropped: hence, hoisting is possible.
// CHECK-LABEL: func @hoist_after_canonicalize
func.func @hoist_after_canonicalize() {
  affine.for %i = 0 to 100 {
    affine.for %j = 0 to 100 {
      affine.if affine_set<(d0) : (d0 - 2 >= 0)>(%j)  {
        affine.if affine_set<(d0, d1) : (d0 - 1 >= 0, -d0 + 99 >= 0)>(%i, %j)  {
          // The call to external is to avoid DCE on affine.if.
          func.call @foo() : () -> ()
        }
      }
    }
  }
  return
}
// CHECK:      affine.for
// CHECK-NEXT:   affine.if
// CHECK-NEXT:     affine.for
// CHECK-NEXT:       affine.if
// CHECK-NEXT:         call
// CHECK-NEXT:       }
// CHECK-NEXT:     }
// CHECK-NEXT:   }
// CHECK-NEXT: }
// CHECK-NEXT: return

// CHECK-LABEL: func @handle_dead_if
func.func @handle_dead_if(%N : index) {
  affine.for %i = 0 to 100 {
      affine.if affine_set<(d0) : (d0 - 1 >= 0, -d0 + 99 >= 0)>(%N)  {
      }
  }
  return
}
// CHECK-NEXT: affine.for
// CHECK-NEXT: }
// CHECK-NEXT: return

// -----

// A test case with affine.parallel.

#flb1 = affine_map<(d0) -> (d0 * 3)>
#fub1 = affine_map<(d0) -> (d0 * 3 + 3)>
#flb0 = affine_map<(d0) -> (d0 * 16)>
#fub0 = affine_map<(d0) -> (d0 * 16 + 16)>
#pub1 = affine_map<(d0)[s0] -> (s0, d0 * 3 + 3)>
#pub0 = affine_map<(d0)[s0] -> (s0, d0 * 16 + 16)>
#lb1 = affine_map<(d0) -> (d0 * 480)>
#ub1 = affine_map<(d0)[s0] -> (s0, d0 * 480 + 480)>
#lb0 = affine_map<(d0) -> (d0 * 110)>
#ub0 = affine_map<(d0)[s0] -> (d0 * 110 + 110, s0 floordiv 3)>

#set0 = affine_set<(d0, d1)[s0, s1] : (d0 * -16 + s0 - 16 >= 0, d1 * -3 + s1 - 3 >= 0)>

// CHECK-LABEL: func @perfect_if_else
func.func @perfect_if_else(%arg0 : memref<?x?xf64>, %arg1 : memref<?x?xf64>, %v : f64,
            %arg4 : index, %arg5 : index, %arg6 : index, %sym : index) {
  affine.for %arg7 = #lb0(%arg5) to min #ub0(%arg5)[%sym] {
    affine.parallel (%i0, %j0) = (0, 0) to (symbol(%sym), 100) step (10, 10) {
      affine.for %arg8 = #lb1(%arg4) to min #ub1(%arg4)[%sym] {
        affine.if #set0(%arg6, %arg7)[%sym, %sym] {
          affine.for %arg9 = #flb0(%arg6) to #fub0(%arg6) {
            affine.for %arg10 = #flb1(%arg7) to #fub1(%arg7) {
              affine.store %v, %arg0[0, 0] : memref<?x?xf64>
            }
          }
        } else {
          affine.for %arg9 = #lb0(%arg6) to min #pub0(%arg6)[%sym] {
            affine.for %arg10 = #lb1(%arg7) to min #pub1(%arg7)[%sym] {
              affine.store %v, %arg0[0, 0] : memref<?x?xf64>
            }
          }
        }
      }
    }
  }
  return
}

// CHECK:       affine.for
// CHECK-NEXT:    affine.if
// CHECK-NEXT:      affine.parallel
// CHECK-NEXT:        affine.for
// CHECK-NEXT:          affine.for
// CHECK-NEXT:            affine.for
// CHECK-NEXT:              affine.store
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    } else {
// CHECK-NEXT:      affine.parallel
// CHECK-NEXT:        affine.for
// CHECK-NEXT:          affine.for
// CHECK-NEXT:            affine.for
// CHECK-NEXT:              affine.store
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }

// With multiple if ops in a function, the test pass just looks for the first if
// op that it is able to successfully hoist.

// CHECK-LABEL: func @multiple_if
func.func @multiple_if(%N : index) {
  affine.if affine_set<() : (0 == 0)>() {
    func.call @external() : () -> ()
  }
  affine.for %i = 0 to 100 {
    affine.if affine_set<()[s0] : (s0 >= 0)>()[%N] {
      func.call @external() : () -> ()
    }
  }
  return
}
// CHECK:      call
// CHECK-NEXT: affine.if
// CHECK-NEXT:   affine.for
// CHECK-NEXT:     call
// CHECK-NEXT:   }
// CHECK-NEXT: }
// CHECK-NEXT: return

func.func private @external()

// Check to ensure affine.parallel ops are handled as well.

#set = affine_set<(d0) : (-d0 + 3 >= 0)>
// CHECK-LABEL: affine_parallel
func.func @affine_parallel(%arg0: memref<35xf32>) -> memref<35xf32> {
  %0 = llvm.mlir.constant(1.000000e+00 : f32) : f32
  %alloc = memref.alloc() {alignment = 64 : i64} : memref<35xf32>
  // CHECK: affine.parallel
  affine.parallel (%arg1) = (0) to (35) step (32) {
    // This can't be hoisted further.
    // CHECK-NEXT: affine.if
    affine.if #set(%arg1) {
      affine.parallel (%arg2) = (%arg1) to (%arg1 + 32) {
        %1 = affine.load %arg0[%arg2] : memref<35xf32>
        %2 = llvm.fdiv %0, %1 : f32
        affine.store %2, %alloc[%arg2] : memref<35xf32>
      }
    } else {
      affine.parallel (%arg2) = (%arg1) to (min(%arg1 + 32, 35)) {
        %1 = affine.load %arg0[%arg2] : memref<35xf32>
        %2 = llvm.fdiv %0, %1 : f32
        affine.store %2, %alloc[%arg2] : memref<35xf32>
      }
    }
  }
  return %alloc : memref<35xf32>
}
