//===-- Single-precision general inverse trigonometric functions ----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIBC_SRC___SUPPORT_MATH_INV_TRIGF_UTILS_H
#define LLVM_LIBC_SRC___SUPPORT_MATH_INV_TRIGF_UTILS_H

#include "src/__support/FPUtil/PolyEval.h"
#include "src/__support/FPUtil/multiply_add.h"
#include "src/__support/common.h"
#include "src/__support/macros/config.h"

namespace LIBC_NAMESPACE_DECL {

// PI and PI / 2
static constexpr double M_MATH_PI = 0x1.921fb54442d18p+1;
static constexpr double M_MATH_PI_2 = 0x1.921fb54442d18p+0;

// Polynomial approximation for 0 <= x <= 1:
//   atan(x) ~ atan((i/16) + (x - (i/16)) * Q(x - i/16)
//           = P(x - i/16)
// Generated by Sollya with:
// > for i from 1 to 16 do {
//     mid_point = i/16;
//     P = fpminimax(atan(mid_point + x), 8, [|D...|], [-1/32, 1/32]);
//     print("{", coeff(P, 0), ",", coeff(P, 1), ",", coeff(P, 2), ",",
//           coeff(P, 3), ",", coeff(P, 4), ",", coeff(P, 5), ",", coeff(P, 6),
//           ",", coeff(P, 7), ",", coeff(P, 8), "},");
//   };
// For i = 0, the polynomial is generated by:
// > P = fpminimax(atan(x)/x, 7, [|1, D...|], [0, 1/32]);
// > dirtyinfnorm((atan(x) - x*P)/x, [0, 1/32]);
//   0x1.feb2fcdba66447ccbe28a1a0f935b51678a718fb1p-59
// Notice that degree-7 is good enough for atanf, but degree-8 helps reduce the
// error bounds for atan2f's fast pass 16 times, and it does not affect the
// performance of atanf much.
static constexpr double ATAN_COEFFS[17][9] = {
    {0.0, 1.0, 0x1.3f8d76d26d61bp-47, -0x1.5555555574cd8p-2,
     0x1.0dde5d06878eap-29, 0x1.99997738acc77p-3, 0x1.2c43eac9797cap-16,
     -0x1.25fb020007dbdp-3, 0x1.c1b6c31d7b0aep-7},
    {0x1.ff55bb72cfde9p-5, 0x1.fe01fe01fe007p-1, -0x1.fc05f809ed8dap-5,
     -0x1.4d69303afe04ep-2, 0x1.f61bc3e8349cp-5, 0x1.820839278756bp-3,
     -0x1.eda4de1c6bf3fp-5, -0x1.0514d42d64a63p-3, 0x1.db3746a442dcbp-5},
    {0x1.fd5ba9aac2f6ep-4, 0x1.f81f81f81f813p-1, -0x1.f05e09d0dc378p-4,
     -0x1.368c3aa719215p-2, 0x1.d9b16b33ff9c9p-4, 0x1.40488f9c6262ap-3,
     -0x1.ba55933e62ea5p-4, -0x1.64c6a15cd9116p-4, 0x1.9273d5939a75ap-4},
    {0x1.7b97b4bce5b02p-3, 0x1.ee9c7f8458e05p-1, -0x1.665c226d6961p-3,
     -0x1.1344bb7391703p-2, 0x1.42aca8b0081b9p-3, 0x1.c32d9381d7c03p-4,
     -0x1.13e970672e246p-3, -0x1.181ed934dd733p-5, 0x1.bad81ea190c08p-4},
    {0x1.f5b75f92c80ddp-3, 0x1.e1e1e1e1e1e2cp-1, -0x1.c5894d10d363dp-3,
     -0x1.ce6de025f9f5ep-3, 0x1.78a3a07c8dd7fp-3, 0x1.dd5f5180f386ep-5,
     -0x1.1b1f513c4536bp-3, 0x1.0df852e58c43cp-6, 0x1.722e7a7e42505p-4},
    {0x1.362773707ebccp-2, 0x1.d272ca3fc5b2ep-1, -0x1.0997e8aeca8fbp-2,
     -0x1.6cf6666e5e693p-3, 0x1.8dd1e907e88adp-3, 0x1.24849ac0caa5dp-7,
     -0x1.f496be486229dp-4, 0x1.b7d54b8e759ecp-5, 0x1.d39c0d39c3922p-5},
    {0x1.6f61941e4def1p-2, 0x1.c0e070381c0f2p-1, -0x1.2726dd135d9eep-2,
     -0x1.09f37b39b70e4p-3, 0x1.85eacdaadd712p-3, -0x1.04d66340d5b9p-5,
     -0x1.8056b15a22b98p-4, 0x1.29baf494ad3ddp-4, 0x1.52d5881322a7ap-6},
    {0x1.a64eec3cc23fdp-2, 0x1.adbe87f94906ap-1, -0x1.3b9d8eab55addp-2,
     -0x1.57c09646eb7p-4, 0x1.6795319e3b8dfp-3, -0x1.f2d89b5ef31bep-5,
     -0x1.f38aac26203cap-5, 0x1.3262802235e3fp-4, -0x1.2afd6b9a57d66p-7},
    {0x1.dac670561bb4fp-2, 0x1.99999999999ap-1, -0x1.47ae147adff11p-2,
     -0x1.5d867c40188b7p-5, 0x1.3a92a2df85e7ap-3, -0x1.3ec457c46e851p-4,
     -0x1.ec1b9777e2e5bp-6, 0x1.0a542992a821ep-4, -0x1.ccffbe2f0d945p-6},
    {0x1.0657e94db30dp-1, 0x1.84f00c2780615p-1, -0x1.4c62cb562defap-2,
     -0x1.e6495b3c14e03p-8, 0x1.063c2fa617bfcp-3, -0x1.58b782d9907aap-4,
     -0x1.41e6ff524b7fp-8, 0x1.937dfff3205a7p-5, -0x1.0fb1fd1c729dp-5},
    {0x1.1e00babdefeb4p-1, 0x1.702e05c0b816ep-1, -0x1.4af2b78215fbep-2,
     0x1.5d0b7e9f36997p-6, 0x1.a1247cb978debp-4, -0x1.519e1457734cap-4,
     0x1.a755cf86b5bfbp-7, 0x1.096d174284564p-5, -0x1.081adf539ad58p-5},
    {0x1.345f01cce37bbp-1, 0x1.5babcc647fa8ep-1, -0x1.449db09426a6dp-2,
     0x1.655caac5896dap-5, 0x1.3bbbd22d05a61p-4, -0x1.34a2febee042fp-4,
     0x1.84df9c8269e34p-6, 0x1.200e8176c899ap-6, -0x1.c00b23c3ce222p-6},
    {0x1.4978fa3269ee1p-1, 0x1.47ae147ae1477p-1, -0x1.3a92a3055231ap-2,
     0x1.ec21b515a4a2p-5, 0x1.c2f8b81f9a0d2p-5, -0x1.0ba9964125453p-4,
     0x1.d7b5614777a05p-6, 0x1.971e91ed73595p-8, -0x1.3fc375a78dc74p-6},
    {0x1.5d58987169b18p-1, 0x1.34679ace01343p-1, -0x1.2ddfb039136e5p-2,
     0x1.2491307b9fb73p-4, 0x1.29c7e4886dc22p-5, -0x1.bca78bcca83ap-5,
     0x1.e63efd7cbe1ddp-6, -0x1.8ea6c4f03b42dp-10, -0x1.9385b5c3a6997p-7},
    {0x1.700a7c5784634p-1, 0x1.21fb78121fb76p-1, -0x1.1f6a8499e5d1ap-2,
     0x1.41b15e5e29423p-4, 0x1.59bc953163345p-6, -0x1.63b54b13184ddp-5,
     0x1.c9086666d213p-6, -0x1.90c3b4ad8d4bcp-8, -0x1.80f08ed9f6f57p-8},
    {0x1.819d0b7158a4dp-1, 0x1.107fbbe01107ep-1, -0x1.0feeb4089670ep-2,
     0x1.50e5afb93f5cbp-4, 0x1.2a7c2adffeffbp-7, -0x1.12bd29b4f1b43p-5,
     0x1.93f71f0eb00eap-6, -0x1.10ece5ad30e28p-7, -0x1.db1a76bcd2b9cp-10},
    {0x1.921fb54442d18p-1, 0x1.ffffffffffffep-2, -0x1.fffffffffc51cp-3,
     0x1.555555557002ep-4, -0x1.a88260c338e75p-30, -0x1.99999f9a7614fp-6,
     0x1.555e31a1e15e9p-6, -0x1.245240d65e629p-7, -0x1.fa9ba66478903p-11},
};

// Look-up table for atan(k/16) with k = 0..16.
static constexpr double ATAN_K_OVER_16[17] = {
    0.0,
    0x1.ff55bb72cfdeap-5,
    0x1.fd5ba9aac2f6ep-4,
    0x1.7b97b4bce5b02p-3,
    0x1.f5b75f92c80ddp-3,
    0x1.362773707ebccp-2,
    0x1.6f61941e4def1p-2,
    0x1.a64eec3cc23fdp-2,
    0x1.dac670561bb4fp-2,
    0x1.0657e94db30dp-1,
    0x1.1e00babdefeb4p-1,
    0x1.345f01cce37bbp-1,
    0x1.4978fa3269ee1p-1,
    0x1.5d58987169b18p-1,
    0x1.700a7c5784634p-1,
    0x1.819d0b7158a4dp-1,
    0x1.921fb54442d18p-1,
};

// For |x| <= 1/32 and 0 <= i <= 16, return Q(x) such that:
//   Q(x) ~ (atan(x + i/16) - atan(i/16)) / x.
LIBC_INLINE static double atan_eval(double x, unsigned i) {
  double x2 = x * x;

  double c0 = fputil::multiply_add(x, ATAN_COEFFS[i][2], ATAN_COEFFS[i][1]);
  double c1 = fputil::multiply_add(x, ATAN_COEFFS[i][4], ATAN_COEFFS[i][3]);
  double c2 = fputil::multiply_add(x, ATAN_COEFFS[i][6], ATAN_COEFFS[i][5]);
  double c3 = fputil::multiply_add(x, ATAN_COEFFS[i][8], ATAN_COEFFS[i][7]);

  double x4 = x2 * x2;
  double d1 = fputil::multiply_add(x2, c1, c0);
  double d2 = fputil::multiply_add(x2, c3, c2);
  double p = fputil::multiply_add(x4, d2, d1);
  return p;
}

// Evaluate atan without big lookup table.
//   atan(n/d) - atan(k/16) = atan((n/d - k/16) / (1 + (n/d) * (k/16)))
//                          = atan((n - d * k/16)) / (d + n * k/16))
// So we let q = (n - d * k/16) / (d + n * k/16),
// and approximate with Taylor polynomial:
//   atan(q) ~ q - q^3/3 + q^5/5 - q^7/7 + q^9/9
LIBC_INLINE static double atan_eval_no_table(double num, double den,
                                             double k_over_16) {
  double num_r = fputil::multiply_add(den, -k_over_16, num);
  double den_r = fputil::multiply_add(num, k_over_16, den);
  double q = num_r / den_r;

  constexpr double ATAN_TAYLOR[] = {
      -0x1.5555555555555p-2,
      0x1.999999999999ap-3,
      -0x1.2492492492492p-3,
      0x1.c71c71c71c71cp-4,
  };
  double q2 = q * q;
  double q3 = q2 * q;
  double q4 = q2 * q2;
  double c0 = fputil::multiply_add(q2, ATAN_TAYLOR[1], ATAN_TAYLOR[0]);
  double c1 = fputil::multiply_add(q2, ATAN_TAYLOR[3], ATAN_TAYLOR[2]);
  double d = fputil::multiply_add(q4, c1, c0);
  return fputil::multiply_add(q3, d, q);
}

// > Q = fpminimax(asin(x)/x, [|0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20|],
//                 [|1, D...|], [0, 0.5]);
static constexpr double ASIN_COEFFS[10] = {
    0x1.5555555540fa1p-3, 0x1.333333512edc2p-4, 0x1.6db6cc1541b31p-5,
    0x1.f1caff324770ep-6, 0x1.6e43899f5f4f4p-6, 0x1.1f847cf652577p-6,
    0x1.9b60f47f87146p-7, 0x1.259e2634c494fp-6, -0x1.df946fa875ddp-8,
    0x1.02311ecf99c28p-5};

// Evaluate P(x^2) - 1, where P(x^2) ~ asin(x)/x
LIBC_INLINE static double asin_eval(double xsq) {
  double x4 = xsq * xsq;
  double r1 = fputil::polyeval(x4, ASIN_COEFFS[0], ASIN_COEFFS[2],
                               ASIN_COEFFS[4], ASIN_COEFFS[6], ASIN_COEFFS[8]);
  double r2 = fputil::polyeval(x4, ASIN_COEFFS[1], ASIN_COEFFS[3],
                               ASIN_COEFFS[5], ASIN_COEFFS[7], ASIN_COEFFS[9]);
  return fputil::multiply_add(xsq, r2, r1);
}

} // namespace LIBC_NAMESPACE_DECL

#endif // LLVM_LIBC_SRC___SUPPORT_MATH_INV_TRIGF_UTILS_H
