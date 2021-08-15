// MIT License

// Copyright (c) 2021 Vincent Laisney

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

module integer

// wrapper for libbf https://bellard.org/libbf/
#flag @VMODROOT/big/libbf.o
#flag @VMODROOT/big/cutils.o
#flag @VMODROOT/big/bf_utils.o
#flag -I @VMODROOT/big
#include "libbf.h"
#include "bf_utils.h"
// #include <stdlib.h>

/* +/-zero is represented with expn = BF_EXP_ZERO and len = 0,
   +/-infinity is represented with expn = BF_EXP_INF and len = 0,
   NaN is represented with expn = BF_EXP_NAN and len = 0 (sign is ignored)
 */
struct C.bf_t {
    ctx &C.bf_context_t
    sign int
    expn i64
    len u64
    tab &u64
}

pub type Bigint = C.bf_t

pub fn (a &Bigint) free() {
    delete(a)
}

// struct C.bfdec_t {
//     // /* must be kept identical to bf_t */
//     // struct bf_context_t *ctx;
//     // int sign;
//     // i64 expn;
//     // u64 len;
//     // u64 *tab;
// }

// pub type Bigdec = C.bfdec_t

pub enum Round {
    rndn /* round to nearest, ties to even */
    rndz /* round to zero */
    rndd /* round to -inf (the code relies on (BF_RNDD xor BF_RNDU) = 1) */
    rndu /* round to +inf */
    rndna /* round to nearest, ties away from zero */
    rnda /* round away from zero */
    rndf /* faithful rounding (nondeterministic, either RNDD or RNDU,
                inexact flag is always set)  */
}

/* returned status */
const bf_st_invalid_op = (1 << 0)
const bf_st_divide_zero = (1 << 1)
const bf_st_overflow = (1 << 2)
const bf_st_underflow = (1 << 3)
const bf_st_inexact = (1 << 4)
/* indicate that a memory allocation error occured. NaN is returned */
const bf_st_mem_error = (1 << 5) 

const bf_radix_max = 36 /* maximum radix for bf_atof() and bf_ftoa() */


const limb_bits = 64
const bf_prec_min = 2
pub const prec_max = ((u64(1) << (limb_bits - 2)) - 2)
pub const prec_inf = (prec_max + 1) /* infinite precision */
// /* allow subnormal numbers. Only available if the number of exponent
//    bits is <= BF_EXP_BITS_USER_MAX and prec != BF_PREC_INF. */
pub const flag_subnormal =  (1 << 3)
// /* 'prec' is the precision after the radix point instead of the whole
//    mantissa. Can only be used with bf_round() and
//    bfdec_[add|sub|mul|div|sqrt|round](). */
pub const flag_radpnt_prec =  (1 << 4)

const rnd_mask =  0x7
const exp_bits_shift =  5
const exp_bits_mask =  0x3f

// /* shortcut for bf_set_exp_bits(BF_EXT_EXP_BITS_MAX) */
const flag_ext_exp =  (exp_bits_mask << exp_bits_shift)

// /* contains the rounding mode and number of exponents bits */
// typedef uint32_t u32;

// typedef void *bf_realloc_func_t(*opaque void, *ptr void, size size_t)
type Realloc_func = fn (opaque voidptr, ptr voidptr, size u64) voidptr

// typedef struct {
//     bf_t val;
//     u64 prec;
// } BFConstCache;

struct C.bf_context_t {
    // void *realloc_opaque;
    // bf_realloc_func_t *realloc_func;
    // BFConstCache log2_cache;
    // BFConstCache pi_cache;
    // struct BFNTTState *ntt_state;
} 

type Context = C.bf_context_t

pub fn (a Context) free () {
    C.bf_clear_cache(&a)
}

pub struct MathContext {
pub mut:
    prec    u64
    rnd     Round
    flags   u32
}

pub fn get_def_ctx () MathContext {
    return MathContext {
        prec: prec_inf
        rnd:  .rndn
        flags: 0
    }
}

// fn C.bf_get_exp_bits(flags u32) int
// // {
// //     int e;
// //     e = (flags >> BF_EXP_BITS_SHIFT) & BF_EXP_BITS_MASK;
// //     if (e == BF_EXP_BITS_MASK)
// //         return BF_EXP_BITS_MAX + 1;
// //     else
// //         return BF_EXP_BITS_MAX - e;
// // }

// fn C.bf_set_exp_bits(n int) u32
// // {
//     // return ((BF_EXP_BITS_MAX - n) & BF_EXP_BITS_MASK) << BF_EXP_BITS_SHIFT;
// // }

// // /* returned status */
pub const st_invalid_op =   (1 << 0)
pub const st_divide_zero =  (1 << 1)
pub const st_overflow =     (1 << 2)
pub const st_underflow =    (1 << 3)
pub const st_inexact =      (1 << 4)
/* indicate that a memory allocation error occured. NaN is returned */
pub const st_mem_error =    (1 << 5) 

const radix_max =  36 /* maximum radix for bf_atof() and bf_ftoa() */

// fn C.bf_max(a i64, b i64) i64
// // {
// //     if (a > b)
// //         return a;
// //     else
// //         return b;
// // }

// fn C.bf_min(a i64, b i64) i64
// // {
// //     if (a < b)
// //         return a;
// //     else
// //         return b;
// // }

// import from bf_utils
fn C.get_bf_context() &Context
fn C.get_bf_retval () int
fn C.set_bf_retval (retval int)

[inline]
fn get_bf_context() &Context {
    return C.get_bf_context()
}
[inline]
fn set_bf_retval (retval int) {
    C.set_bf_retval (retval)
}
[inline]
pub fn get_bf_retval () int {
    return C.get_bf_retval ()
}

fn init () {
    context_init(get_bf_context(), def_realloc, voidptr(0))
}

fn def_realloc(opaque voidptr, ptr &byte, size u32) &byte {
	unsafe {
		if ptr == 0 {
			return malloc(int(size))
		} else {
			if size != 0 {
				return v_realloc(ptr, int(size))
			} else {
				free(ptr)
				return 0
			}
		}
	}
}

fn C.bf_context_init(s &C.bf_context_t, realloc_func Realloc_func, realloc_opaque voidptr)

pub fn context_init(s &Context, realloc_func Realloc_func, realloc_opaque voidptr) {
	C.bf_context_init(s, realloc_func, realloc_opaque)
}

fn C.bf_context_end(s &C.bf_context_t)

pub fn context_end(s Context) {
	C.bf_context_end(&s)
}

/* free memory allocated for the bf cache data */
fn C.bf_clear_cache(s &C.bf_context_t)

pub fn clear_cache(s &Context) {
	C.bf_clear_cache(s)
}

// // fn C.*bf_realloc(*s bf_context_t, ptr voidptr, size size_t)
// // {
// //     return s->realloc_func(s->realloc_opaque, ptr, size)
// // }

// /* 'size' must be != 0 */
// // fn C.*bf_malloc(*s bf_context_t, size size_t)
// // {
// //     return bf_realloc(s, NULL, size)
// // }

fn C.bf_free(s &C.bf_context_t, ptr voidptr)

pub fn bf_free(s Context, ptr voidptr) {
	C.bf_free(&s, ptr)
}

// // {
// //     /* must test ptr otherwise equivalent to malloc(0) */
// //     if (ptr)
// //         bf_realloc(s, ptr, 0)
// // }

fn C.bf_init(s &C.bf_context_t, r &C.bf_t)

// fn init(s &C.bf_context_t, mut r C.bf_t) {
//     C.bf_init(s, &r)
// }

pub fn new() Bigint {
    r := Bigint{ ctx: 0 tab: 0 }
	C.bf_init(get_bf_context(), &r)
    return r
}


fn C.bf_delete(r &C.bf_t)

pub fn delete(r Bigint) {
    C.bf_delete(&r)
}

fn C.bf_neg(r &C.bf_t)

pub fn (mut r Bigint) neg() {
	C.bf_neg(&r)
}

fn C.bf_is_finite(a &C.bf_t) int

pub fn (a Bigint) is_finite() bool {
	return C.bf_is_finite(&a) != 0
}

fn C.bf_is_nan(a &C.bf_t) int

pub fn (a Bigint) is_nan() bool {
	return C.bf_is_nan(&a) != 0
}

fn C.bf_is_zero(a &C.bf_t) int

pub fn (a Bigint) is_zero() bool {
	return C.bf_is_zero(&a) != 0
}

// fn C.bf_memcpy(r &C.bf_t, a &C.bf_t)
// // {
// //     *r = *a;
// // }

fn C.bf_set_ui(r &C.bf_t, a u64) int

pub fn from_u64(a u64) Bigint {
    r := new()
	retval := C.bf_set_ui(&r, a)
    set_bf_retval(retval)
    return r
}

fn C.bf_set_si(r &C.bf_t, a i64) int

pub fn from_i64(a i64) Bigint {
    r := new() 
	retval := C.bf_set_si(&r, a)
    set_bf_retval(retval)
    return r
}

fn C.bf_set_nan(r &C.bf_t)

pub fn set_nan(mut r Bigint) {
	C.bf_set_nan(&r)
}

fn C.bf_set_zero(r &C.bf_t, is_neg int)

pub fn set_zero(mut r Bigint, is_neg int) {
	C.bf_set_zero(&r, is_neg)
}

fn C.bf_set_inf(r &C.bf_t, is_inf int)

pub fn set_inf(mut r Bigint, is_inf int) {
	C.bf_set_inf(&r, is_inf)
}

fn C.bf_set(r &C.bf_t, a &C.bf_t) int

pub fn set(mut r Bigint, a Bigint) int {
	return C.bf_set(&r, &a)
}

// fn C.bf_move(r &C.bf_t, a &C.bf_t)
fn C.bf_get_float64(a &C.bf_t, pres &f64, rnd_mode Round) int

pub fn (a Bigint) f64() f64 {
    ctx := get_def_ctx()
    pres := f64(0.0)
	retval := C.bf_get_float64(&a, &pres, ctx.rnd)
    set_bf_retval(retval)
    return pres
}

fn C.bf_set_float64(a &C.bf_t, d f64) int

pub fn from_f64(d f64) Bigint {
    mut r := new() 
	retval := C.bf_set_float64(&r, d)
    set_bf_retval(retval)
    r.rint() // for Bigint
return r
}


// fn C.bf_cmpu(a &bf_t, b &bf_t) int
// fn C.bf_cmp_full(a &bf_t, b &bf_t) int
fn C.bf_cmp(a &C.bf_t, b &C.bf_t) int

pub fn cmp(a Bigint, b Bigint) int {
    return C.bf_cmp(&a, &b)
}
// fn C.bf_cmp_eq(a &bf_t, b &bf_t) int
// // {
// //     return bf_cmp(a, b) == 0;
// // }

// fn C.bf_cmp_le(a &bf_t, b &bf_t) int
// // {
// //     return bf_cmp(a, b) <= 0;
// // }

// fn C.bf_cmp_lt(a &bf_t, b &bf_t) int
// // {
// //     return bf_cmp(a, b) < 0;
// // }

fn C.bf_add(r &C.bf_t, a &C.bf_t, b &C.bf_t, prec u64, flags u32) int

pub fn (a Bigint) + (b Bigint) Bigint {
    r := new()
    ctx := get_def_ctx ()
	retval := C.bf_add(&r, &a, &b, ctx.prec, ctx.flags)
    set_bf_retval(retval)
    return r
}

pub fn (a Bigint) add(b Bigint, ctx MathContext) Bigint {
    r := new()
	retval := C.bf_add(&r, &a, &b, ctx.prec, ctx.flags)
    set_bf_retval(retval)
    return r
}

fn C.bf_sub(r &C.bf_t, a &C.bf_t, b &C.bf_t, prec u64, flags u32) int

pub fn (a Bigint) - (b Bigint) Bigint {
    r := new()
    ctx := get_def_ctx ()
	retval := C.bf_sub(&r, &a, &b, ctx.prec, ctx.flags)
    set_bf_retval(retval)
    return r
}

pub fn (a Bigint) sub(b Bigint, ctx MathContext) Bigint {
    r := new()
	retval := C.bf_sub(&r, &a, &b, ctx.prec, ctx.flags)
    set_bf_retval(retval)
    return r
}

fn C.bf_add_si(r &C.bf_t, a &C.bf_t, b1 i64, prec u64, flags u32) int

pub fn (a Bigint) add_i64_ctx(b1 i64, ctx MathContext) Bigint {
    r := new()
	retval := C.bf_add_si(&r, &a, b1, ctx.prec, ctx.flags)
    set_bf_retval(retval)
    return r
}

pub fn (a Bigint) add_i64(b1 i64) Bigint {
    ctx := get_def_ctx()
    return a.add_i64_ctx(b1, ctx)
}

[inline]
pub fn (mut a Bigint) inc() {
    r := a.add_i64(1)
    set (mut a, r)
}

[inline]
pub fn (mut a Bigint) dec() {
    r := a.add_i64(-1)
    set (mut a, r)
}

fn C.bf_mul(r &C.bf_t, a &C.bf_t, b &C.bf_t, prec u64, flags u32) int

pub fn (a Bigint) * (b Bigint) Bigint {
	mut r := new()
    ctx := get_def_ctx()
    retval := C.bf_mul(&r, &a, &b, ctx.prec, ctx.flags)
    set_bf_retval(retval)
    return r
}

fn C.bf_mul_ui(r &C.bf_t, a &C.bf_t, b1 u64, prec u64, flags u32) int

pub fn mul_u64(mut r Bigint, a Bigint, b1 u64, prec u64, flags u32) int {
	return C.bf_mul_ui(&r, &a, b1, prec, flags)
}

fn C.bf_mul_si(r &C.bf_t, a &C.bf_t, b1 i64, prec u64, flags u32) int

pub fn mul_i64(mut r Bigint, a Bigint, b1 i64, prec u64, flags u32) int {
	return C.bf_mul_si(&r, &a, b1, prec, flags)
}

fn C.bf_mul_2exp(r &C.bf_t, e i64, prec u64, flags u32) int

pub fn (mut r Bigint) mul_2exp(e i64) {
    ctx := get_def_ctx()
	retval := C.bf_mul_2exp(&r, e , ctx.prec , ctx.flags | u32(ctx.rnd))
    set_bf_retval(retval)
    r.rint() // for Bigint
}

pub fn (mut r Bigint) mul_2exp_ctx(e i64, ctx MathContext) {
	retval := C.bf_mul_2exp(&r, e , ctx.prec , ctx.flags | u32(ctx.rnd))
    set_bf_retval(retval)
    r.rint_ctx(ctx) // for Bigint
}

// fn C.bf_div(r &C.bf_t, a &C.bf_t, b &C.bf_t, prec u64, flags u32) int

// pub fn divfloat(mut r Bigint, a Bigint, b Bigint, prec u64, flags u32) int {
// 	return C.bf_div(&r, &a, &b, prec, flags)
// }

pub const divrem_euclidian =  Round.rndf
fn C.bf_divrem(q &C.bf_t, r &C.bf_t, a &C.bf_t, b &C.bf_t, prec u64, flags u32, rnd_mode Round) int

pub fn divrem(a Bigint, b Bigint) (Bigint, Bigint) {
    q := new()
    r := new()
    ctx := get_def_ctx()
	retval := C.bf_divrem(&q, &r, &a, &b, ctx.prec, ctx.flags, ctx.rnd)
    set_bf_retval(retval)
    return q, r
}

pub fn divrem_ctx(a Bigint, b Bigint, ctx MathContext) (Bigint, Bigint) {
    q := new()
    r := new()
	retval := C.bf_divrem(&q, &r, &a, &b, ctx.prec, ctx.flags, ctx.rnd)
    set_bf_retval(retval)
    return q, r
}

pub fn (a Bigint) div_ctx(b Bigint, ctx MathContext) Bigint {
    q, _ := divrem_ctx(a, b, ctx)
    return q
}

pub fn (a Bigint) / (b Bigint) Bigint {
    mut ctx := get_def_ctx()
    ctx.rnd = .rndz // rnd toward zero for standard integer division
    q, _ := divrem_ctx(a, b, ctx)
    return q
}

fn C.bf_rem(r &C.bf_t, a &C.bf_t, b &C.bf_t, prec u64, flags u32, rnd_mode Round) int

pub fn (a Bigint) rem_ctx(b Bigint, ctx MathContext) Bigint {
    r := new()
	retval := C.bf_rem(&r, &a, &b, ctx.prec, ctx.flags, .rndz)
    set_bf_retval(retval)
    return r
}

pub fn (a Bigint) % (b Bigint) Bigint {
    ctx := get_def_ctx()
    return a.rem_ctx(b, ctx)
}

fn C.bf_remquo(pq &i64, r &C.bf_t, a &C.bf_t, b &C.bf_t, prec u64, flags u32, rnd_mode int) int

pub fn remquo(pq &i64, mut r Bigint, a Bigint, b Bigint, prec u64, flags u32, rnd_mode int) int {
	return C.bf_remquo(pq, &r, &a, &b, prec, flags, rnd_mode)
}

/* round to integer with infinite precision */
fn C.bf_rint(r &C.bf_t, rnd_mode Round) int

pub fn (mut r Bigint) rint() {
    ctx := get_def_ctx()
	retval := C.bf_rint(&r, ctx.rnd)
    set_bf_retval(retval)
}

pub fn (mut r Bigint) rint_ctx(ctx MathContext) {
	retval := C.bf_rint(&r, ctx.rnd)
    set_bf_retval(retval)
}

fn C.bf_round(r &C.bf_t, prec u64, flags u32) int

pub fn round(mut r Bigint, prec u64, flags u32) int {
	return C.bf_round(&r, prec, flags)
}

fn C.bf_sqrtrem(r &C.bf_t, rem1 &C.bf_t, a &C.bf_t) int

pub fn sqrtrem(a Bigint) (Bigint, Bigint) {
    r := new()
    rem1 := new()
	retval := C.bf_sqrtrem(&r, &rem1, &a)
    set_bf_retval(retval)
    return r, rem1
}

pub fn isqrt(a Bigint) Bigint {
    r, _ := sqrtrem(a)
    return r
}

// fn C.bf_sqrt(r &C.bf_t, a &C.bf_t, prec u64, flags u32) int

// pub fn sqrt(a Bigint) Bigint {
// 	r := new()
//     ctx := get_def_ctx()
//     retval := C.bf_sqrt(&r, &a, ctx.prec, ctx.flags)
//     set_bf_retval(retval)
//     return r
// }

fn C.bf_get_exp_min(a &C.bf_t) i64

pub fn get_exp_min(a Bigint) i64 {
	return C.bf_get_exp_min(&a)
}

fn C.bf_logic_or(r &C.bf_t, a &C.bf_t, b &C.bf_t) int

pub fn logic_or(mut r Bigint, a Bigint, b Bigint) int {
	return C.bf_logic_or(&r, &a, &b)
}

fn C.bf_logic_xor(r &C.bf_t, a &C.bf_t, b &C.bf_t) int

pub fn logic_xor(mut r Bigint, a Bigint, b Bigint) int {
	return C.bf_logic_xor(&r, &a, &b)
}

fn C.bf_logic_and(r &C.bf_t, a &C.bf_t, b &C.bf_t) int

pub fn logic_and(mut r Bigint, a Bigint, b Bigint) int {
	return C.bf_logic_and(&r, &a, &b)
}


/* additional flags for bf_atof */
/* do not accept hex radix prefix (0x or 0X) if radix = 0 or radix = 16 */
pub const atof_no_hex =        (1 << 16)
/* accept binary (0b or 0B) or octal (0o or 0O) radix prefix if radix = 0 */
pub const atof_bin_oct =       (1 << 17)
/* Do not parse NaN or Inf */
pub const atof_no_nan_inf =    (1 << 18)
/* return the exponent separately */
pub const atof_exponent =        (1 << 19)

// fn C.bf_atof(a &C.bf_t, str &char, pnext &&char, radix int, prec u64, flags u32) int 

// pub fn atof(mut a Bigint, str &char, pnext &&char, radix int, prec u64, flags u32) int {
//     return C.bf_atof(&a, str, pnext, radix, prec, flags)
// }

/* this version accepts prec = BF_PREC_INF and returns the radix
   exponent */
fn C.bf_atof2(r &C.bf_t, pexponent &i64, str &char, pnext &&char, radix int, prec u64, flags u32) int

pub fn from_str_base(str string, radix int) ?Bigint {
    mut r := new()
    pexponent := i64(0) 
    retval := C.bf_atof2(&r, &pexponent, str.str, voidptr(0), radix, prec_inf, atof_bin_oct)
    set_bf_retval(retval)
    r.rint() // for Bigint
    if r.is_nan() || ! r.is_finite() {
        return error('Invalid string')
    } else {
        return r
    }
}

pub fn from_str(str string) ?Bigint {
    return from_str_base(str, 10)
}
// fn C.bf_mul_pow_radix(r &bf_t, T &bf_t, radix u64, expn i64, prec u64, flags u32) int


// // /* Conversion of floating point number to string. Return a null
// //    terminated string or NULL if memory error. *plen contains its
// //    length if plen != NULL.  The exponent letter is "e" for base 10,
// //    "p" for bases 2, 8, 16 with a binary exponent and "@" for the other
// //    bases. */

pub const ftoa_format_mask =  (3 << 16)

/* fixed format: prec significant digits rounded with (flags &
   BF_RND_MASK). Exponential notation is used if too many zeros are
   needed.*/
pub const ftoa_format_fixed =  (0 << 16)
/* fractional format: prec digits after the decimal point rounded with
   (flags & BF_RND_MASK) */
pub const ftoa_format_frac =   (1 << 16)
/* free format: 
   
   For binary radices with bf_ftoa() and for bfdec_ftoa(): use the minimum
   number of digits to represent 'a'. The precision and the rounding
   mode are ignored.
   
   For the non binary radices with bf_ftoa(): use as many digits as
   necessary so that bf_atof() return the same number when using
   precision 'prec', rounding to nearest and the subnormal
   configuration of 'flags'. The result is meaningful only if 'a' is
   already rounded to 'prec' bits. If the subnormal flag is set, the
   exponent in 'flags' must also be set to the desired exponent range.
*/
pub const ftoa_format_free =   (2 << 16)
/* same as BF_FTOA_FORMAT_FREE but uses the minimum number of digits
   (takes more computation time). Identical to BF_FTOA_FORMAT_FREE for
   binary radices with bf_ftoa() and for bfdec_ftoa(). */
pub const ftoa_format_free_min =  (3 << 16)

/* force exponential notation for fixed or free format */
pub const ftoa_force_exp =     (1 << 20)
/* add 0x prefix for base 16, 0o prefix for base 8 or 0b prefix for
   base 2 if non zero value */
pub const ftoa_add_prefix =    (1 << 21)
/* return "Infinity" instead of "Inf" and add a "+" for positive
   exponents */
pub const ftoa_js_quirks =     (1 << 22)

fn C.bf_ftoa(plen &u64, a &C.bf_t, radix int, prec u64,  flags u32) &char

pub fn (a Bigint) str_base(radix int) string {
    plen := u64(0)
    if a.len > 0 {
        c_str := C.bf_ftoa(&plen, &a, radix, 0,  ftoa_format_frac | int(Round.rndn))
        str := ''
        unsafe { str = c_str.vstring() }
        return str
    } else {
        return '0'
    }
}

pub fn (a Bigint) str() string {
    return a.str_base(10)
}

// /* modulo 2^n instead of saturation. NaN and infinity return 0 */
pub const get_int_mod =  (1 << 0) 
fn C.bf_get_int32(pres &int, a &C.bf_t, flags int) int

pub fn (a Bigint) int() int {
    pres := int(0)
    ctx := get_def_ctx()
	retval := C.bf_get_int32(&pres, &a, ctx.flags)
    set_bf_retval(retval)
    return pres
}

fn C.bf_get_int64(pres &i64, a &C.bf_t, flags int) int

pub fn (a Bigint) i64() i64 {
    pres := i64(0)
    ctx := get_def_ctx()
	retval := C.bf_get_int64(&pres, &a, ctx.flags)
    set_bf_retval(retval)
    return pres
}


// // /* the following functions are exported for testing only. */
// // fn C.mp_print_str(str &char, tab &u64, n u64)
// // fn C.bf_print_str(str &char, a &bf_t)
// // fn C.bf_resize(r &bf_t, len u64) int
// // fn C.bf_get_fft_size(pdpl &int, pnb_mods &int, len u64) int
// // fn C.bf_normalize_and_round(r &bf_t, prec1 u64, flags u32) int
// // fn C.bf_can_round(a &bf_t, prec i64, rnd_mode Round, k i64) int
// // fn C.bf_mul_log2_radix(i64 a1, unsigned int radix, is_inv int, is_ceil1 int) i64
// // fn C.mp_mul(s &C.bf_context_t, result &u64, op1 &u64, op1_size u64, op2 &u64, op2_size u64) int
// // fn C.mp_add(res &u64, op1 &u64, op2 &u64, n u64, carry u64) u64
// // fn C.mp_add_ui(tab &u64, b u64, n size_t) u64
// fn C.mp_sqrtrem(s &C.bf_context_t, tabs &u64, taba &u64, n u64) int
// // fn C.mp_recip(s &C.bf_context_t, tabr &u64, taba &u64, n u64) int
// fn C.bf_isqrt(a u64) u64

// /* transcendental functions */
// fn C.bf_const_log2(T &bf_t, prec u64, flags u32) int
// fn C.bf_const_pi(T &bf_t, prec u64, flags u32) int
// fn C.bf_exp(r &bf_t, a &bf_t, prec u64, flags u32) int
// fn C.bf_log(r &bf_t, a &bf_t, prec u64, flags u32) int
// // #define BF_POW_JS_QUIRKS (1 << 16) /* (+/-1)^(+/-Inf) = NaN, 1^NaN = NaN */
fn C.bf_pow(r &C.bf_t, x &C.bf_t, y &C.bf_t, prec u64, flags u32) int

pub fn power_ctx(x Bigint, y Bigint, ctx MathContext) Bigint {
    r := new()
    if cmp(y, new()) < 0 { panic('the exponent of power must be >= 0') }
    retval := C.bf_pow(&r, &x, &y, ctx.prec, ctx.flags)
    set_bf_retval(retval)
    return r
}

pub fn power(x Bigint, y Bigint) Bigint {
    ctx := get_def_ctx()
    return power_ctx(x, y, ctx)
}

// fn C.bf_cos(r &bf_t, a &bf_t, prec u64, flags u32) int
// fn C.bf_sin(r &bf_t, a &bf_t, prec u64, flags u32) int
// fn C.bf_tan(r &bf_t, a &bf_t, prec u64, flags u32) int
// fn C.bf_atan(r &bf_t, a &bf_t, prec u64, flags u32) int
// fn C.bf_atan2(r &bf_t, y &bf_t, x &bf_t, prec u64, flags u32) int
// fn C.bf_asin(r &bf_t, a &bf_t, prec u64, flags u32) int
// fn C.bf_acos(r &bf_t, a &bf_t, prec u64, flags u32) int

// /* decimal floating point */

// fn C.bfdec_init(s &C.bf_context_t, r &bfdec_t)
// // {
// //     bf_init(s, (bf_t *)r)
// // }
// fn C.bfdec_delete(r &bfdec_t)
// // {
// //     bf_delete((bf_t *)r)
// // }

// fn C.bfdec_neg(r &bfdec_t)
// // {
// //     r->sign ^= 1;
// // }

// fn C.bfdec_is_finite(a &bfdec_t) int
// // {
// //     return (a->expn < BF_EXP_INF)
// // }

// fn C.bfdec_is_nan(a &bfdec_t) int
// // {
// //     return (a->expn == BF_EXP_NAN)
// // }

// fn C.bfdec_is_zero(a &bfdec_t) int
// // {
// //     return (a->expn == BF_EXP_ZERO)
// // }

// fn C.bfdec_memcpy(r &bfdec_t, a &bfdec_t)
// // {
// //     bf_memcpy((bf_t *)r, (bf_t *)a)
// // }

// fn C.bfdec_set_ui(r &bfdec_t, a u64) int
// fn C.bfdec_set_si(r &bfdec_t, a i64) int

// fn C.bfdec_set_nan(r &bfdec_t)
// // {
// //     bf_set_nan((bf_t *)r)
// // }
// fn C.bfdec_set_zero(r &bfdec_t, is_neg int)
// // {
// //     bf_set_zero((bf_t )r, &is_neg)
// // }
// fn C.bfdec_set_inf(r &bfdec_t, is_neg int)
// // {
// //     bf_set_inf((bf_t )r, &is_neg)
// // }
// fn C.bfdec_set(r &bfdec_t, a &bfdec_t) int
// // {
// //     return bf_set((bf_t *)r, (bf_t *)a)
// // }
// fn C.bfdec_move(r &bfdec_t, a &bfdec_t)
// // {
// //     bf_move((bf_t *)r, (bf_t *)a)
// // }
// fn C.bfdec_cmpu(a &bfdec_t, b &bfdec_t) int
// // {
// //     return bf_cmpu((bf_t *)a, (bf_t *)b)
// // }
// fn C.bfdec_cmp_full(a &bfdec_t, b &bfdec_t) int
// // {
// //     return bf_cmp_full((bf_t *)a, (bf_t *)b)
// // }
// fn C.bfdec_cmp(a &bfdec_t, b &bfdec_t) int
// // {
// //     return bf_cmp((bf_t *)a, (bf_t *)b)
// // }
// fn C.bfdec_cmp_eq(a &bfdec_t, b &bfdec_t) int
// // {
// //     return bfdec_cmp(a, b) == 0;
// // }
// fn C.bfdec_cmp_le(a &bfdec_t, b &bfdec_t) int
// // {
// //     return bfdec_cmp(a, b) <= 0;
// // }
// fn C.bfdec_cmp_lt(a &bfdec_t, b &bfdec_t) int
// // {
// //     return bfdec_cmp(a, b) < 0;
// // }

// fn C.bfdec_add(r &bfdec_t, a &bfdec_t, b &bfdec_t, prec u64, flags u32) int
// fn C.bfdec_sub(r &bfdec_t, a &bfdec_t, b &bfdec_t, prec u64, flags u32) int
// fn C.bfdec_add_si(r &bfdec_t, a &bfdec_t, b1 i64, prec u64, flags u32) int
// fn C.bfdec_mul(r &bfdec_t, a &bfdec_t, b &bfdec_t, prec u64, flags u32) int
// fn C.bfdec_mul_si(r &bfdec_t, a &bfdec_t, b1 i64, prec u64, flags u32) int
// fn C.bfdec_div(r &bfdec_t, a &bfdec_t, b &bfdec_t, prec u64, flags u32) int
// fn C.bfdec_divrem(q &bfdec_t, r &bfdec_t, a &bfdec_t, b &bfdec_t, prec u64, flags u32, rnd_mode int) int
// fn C.bfdec_rem(r &bfdec_t, a &bfdec_t, b &bfdec_t, prec u64, flags u32, rnd_mode int) int
// fn C.bfdec_rint(r &bfdec_t, rnd_mode int) int
// fn C.bfdec_sqrt(r &bfdec_t, a &bfdec_t, prec u64, flags u32) int
// fn C.bfdec_round(r &bfdec_t, prec u64, flags u32) int
// fn C.bfdec_get_int32(pres &int, a &bfdec_t) int
// fn C.bfdec_pow_ui(r &bfdec_t, a &bfdec_t, b u64) int

// fn C.bfdec_ftoa(plen &size_t, a &bfdec_t, prec u64, flags u32) &char
// fn C.bfdec_atof(r &bfdec_t, str &char, pnext &&char, prec u64, flags u32) int

// // /* the following functions are exported for testing only. */
// // mp_pow_dec[LIMB_DIGITS + 1]; u64
// // bfdec_print_str(str &char, a &bfdec_t)
// // bfdec_resize(r &bfdec_t, len u64) int
// // // {
// // //     return bf_resize((bf_t )r, &len)
// // // }
// // bfdec_normalize_and_round(r &bfdec_t, prec1 u64, flags u32) int

