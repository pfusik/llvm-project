//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef __CLC_MISC_CLC_SHUFFLE_H__
#define __CLC_MISC_CLC_SHUFFLE_H__

#define FUNCTION __clc_shuffle

// Integer-type decls
#define __CLC_BODY <clc/misc/shuffle_decl.inc>
#include <clc/integer/gentype.inc>

// Floating-point decls
#define __CLC_BODY <clc/misc/shuffle_decl.inc>
#include <clc/math/gentype.inc>

#undef FUNCTION

#endif // __CLC_MISC_CLC_SHUFFLE_H__
