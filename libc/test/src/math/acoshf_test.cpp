//===-- Unittests for acoshf ----------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "hdr/math_macros.h"
#include "hdr/stdint_proxy.h"
#include "src/__support/FPUtil/FPBits.h"
#include "src/__support/libc_errno.h"
#include "src/math/acoshf.h"
#include "test/UnitTest/FPMatcher.h"
#include "test/UnitTest/Test.h"
#include "utils/MPFRWrapper/MPFRUtils.h"

using LlvmLibcAcoshfTest = LIBC_NAMESPACE::testing::FPTest<float>;

namespace mpfr = LIBC_NAMESPACE::testing::mpfr;

TEST_F(LlvmLibcAcoshfTest, SpecialNumbers) {
  libc_errno = 0;

  EXPECT_FP_EQ_ALL_ROUNDING(aNaN, LIBC_NAMESPACE::acoshf(aNaN));
  EXPECT_MATH_ERRNO(0);

  EXPECT_FP_EQ_ALL_ROUNDING(aNaN, LIBC_NAMESPACE::acoshf(0.0f));
  EXPECT_MATH_ERRNO(EDOM);

  EXPECT_FP_EQ_ALL_ROUNDING(0.0f, LIBC_NAMESPACE::acoshf(1.0f));
  EXPECT_MATH_ERRNO(0);

  EXPECT_FP_EQ_ALL_ROUNDING(inf, LIBC_NAMESPACE::acoshf(inf));
  EXPECT_MATH_ERRNO(0);

  EXPECT_FP_EQ_ALL_ROUNDING(aNaN, LIBC_NAMESPACE::acoshf(neg_inf));
  EXPECT_MATH_ERRNO(EDOM);
}

TEST_F(LlvmLibcAcoshfTest, InFloatRange) {
  constexpr uint32_t COUNT = 100'000;
  constexpr uint32_t STEP = UINT32_MAX / COUNT;
  for (uint32_t i = 0, v = 0; i <= COUNT; ++i, v += STEP) {
    float x = FPBits(v).get_val();
    if (FPBits(v).is_nan() || FPBits(v).is_inf())
      continue;
    ASSERT_MPFR_MATCH_ALL_ROUNDING(mpfr::Operation::Acosh, x,
                                   LIBC_NAMESPACE::acoshf(x), 0.5);
  }
}

TEST_F(LlvmLibcAcoshfTest, SpecificBitPatterns) {
  constexpr int N = 12;
  constexpr uint32_t INPUTS[N] = {
      0x3f800000, // x = 1.0f
      0x45abaf26, // x = 0x1.575e4cp12f
      0x49d29048, // x = 0x1.a5209p20f
      0x4bdd65a5, // x = 0x1.bacb4ap24f
      0x4c803f2c, // x = 0x1.007e58p26f
      0x4f8ffb03, // x = 0x1.1ff606p32f
      0x5c569e88, // x = 0x1.ad3d1p57f
      0x5e68984e, // x = 0x1.d1309cp61f
      0x655890d3, // x = 0x1.b121a6p75f
      0x65de7ca6, // x = 0x1.bcf94cp76f
      0x6eb1a8ec, // x = 0x1.6351d8p94f
      0x7997f30a, // x = 0x1.2fe614p116f
  };

  for (int i = 0; i < N; ++i) {
    float x = FPBits(INPUTS[i]).get_val();
    EXPECT_MPFR_MATCH_ALL_ROUNDING(mpfr::Operation::Acosh, x,
                                   LIBC_NAMESPACE::acoshf(x), 0.5);
  }
}
