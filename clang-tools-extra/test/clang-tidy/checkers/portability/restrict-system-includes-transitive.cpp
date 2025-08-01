// RUN: rm -rf %t.dir/Headers
// RUN: mkdir -p %t.dir/Headers
// RUN: cp -r %S/Inputs/restrict-system-includes %t.dir/Headers/portability-restrict-system-includes
// RUN: %check_clang_tidy -std=c++11 %s portability-restrict-system-includes %t \
// RUN:   -- -config="{CheckOptions: {portability-restrict-system-includes.Includes: 'transitive.h,s.h'}}" \
// RUN:   -system-headers -header-filter=.* \
// RUN:   -- -I %t.dir/Headers/portability-restrict-system-includes -isystem %t.dir/Headers/portability-restrict-system-includes/system
// RUN: FileCheck -input-file=%t.dir/Headers/portability-restrict-system-includes/transitive2.h %s -check-prefix=CHECK-FIXES
// RUN: rm -rf %t.dir/Headers
// FIXME: Make the test work in all language modes.

// transitive.h includes <r.h> and <t.h>
#include <transitive.h>
// CHECK-MESSAGES: :1:1: warning: system include r.h not allowed, transitively included from {{.*}}
// CHECK-MESSAGES: :2:1: warning: system include t.h not allowed, transitively included from {{.*}}

// transitive.h includes <s.h> and <t.h>
#include "transitive2.h"
// CHECK-MESSAGES: :2:1: warning: system include t.h not allowed, transitively included from {{.*}}
// CHECK-FIXES-NOT: #include <t.h>

int main() {
  // f() is declared in r.h
}
