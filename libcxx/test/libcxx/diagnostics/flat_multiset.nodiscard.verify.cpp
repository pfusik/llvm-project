//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// UNSUPPORTED: c++03, c++11, c++14, c++17, c++20

// <flat_set>

// [[nodiscard]] bool empty() const noexcept;

#include <flat_set>

void f() {
  std::flat_multiset<int> c;
  c.empty(); // expected-warning {{ignoring return value of function declared with 'nodiscard' attribute}}
}
