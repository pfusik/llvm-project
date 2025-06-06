// RUN: %clang_cc1 -triple aarch64 -mbranch-target-enforce -msign-return-address=all \
// RUN:            -fcxx-exceptions -fexceptions -emit-llvm %s -o - \
// RUN:   | FileCheck --check-prefixes=CHECK,BTE-SIGNRA %s
// RUN: %clang_cc1 -triple aarch64 -fptrauth-calls -fptrauth-returns -fptrauth-auth-traps -fptrauth-indirect-gotos \
// RUN:            -fcxx-exceptions -fexceptions -emit-llvm %s -o - \
// RUN:   | FileCheck --check-prefixes=CHECK,PAUTHTEST %s

// Check that functions generated by clang have the correct attributes

class Example {
public:
  Example();
  int fn();
};

// Initialization of var1 causes __cxx_global_var_init and __tls_init to be generated
thread_local Example var1;
extern thread_local Example var2;
extern void fn();

int testfn() noexcept {
  // Calling fn in a noexcept function causes __clang_call_terminate to be generated
  fn();
  // Use of var1 and var2 causes TLS wrapper functions to be generated
  return var1.fn() + var2.fn();
}

// CHECK: define {{.*}} @__cxx_global_var_init() [[ATTR1:#[0-9]+]]
// CHECK: define {{.*}} @__clang_call_terminate({{.*}}) [[ATTR2:#[0-9]+]]
// CHECK: define {{.*}} @_ZTW4var1() [[ATTR1]]
// CHECK: define {{.*}} @_ZTW4var2() [[ATTR1]]
// CHECK: define {{.*}} @__tls_init() [[ATTR1]]

// BTE-SIGNRA: attributes [[ATTR1]] = { {{.*}}"branch-target-enforcement" {{.*}}"sign-return-address"="all" "sign-return-address-key"="a_key"
// BTE-SIGNRA: attributes [[ATTR2]] = { {{.*}}"branch-target-enforcement" {{.*}}"sign-return-address"="all" "sign-return-address-key"="a_key"
// PAUTHTEST: attributes [[ATTR1]] = { {{.*}}"ptrauth-auth-traps" "ptrauth-calls" "ptrauth-indirect-gotos" "ptrauth-returns"
// PAUTHTEST: attributes [[ATTR2]] = { {{.*}}"ptrauth-auth-traps" "ptrauth-calls" "ptrauth-indirect-gotos" "ptrauth-returns"
