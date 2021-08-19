import libbf.big.decimal as bd
import rand
import math
import math.mathutil

fn test_new() {
	assert bd.new().str() == '0'
}

fn test_from_u64() {
	assert bd.from_u64(0).str() == '0'
	d_ctx := bd.get_def_print_ctx()
	p_ctx := bd.PrintContext { 
		...d_ctx
		prec: 0 // after decimal
		flags: bd.ftoa_format_frac
	}
	assert bd.from_u64(u64(-1)).str_ctx(p_ctx) == '18446744073709551615'
	assert bd.from_u64(83948571620).str() == '83948571620'
	assert bd.from_u64(u64(-1)).str() == '1.8446744073709552e19' // default 17 digist
}

fn test_from_i64() {
	assert bd.from_i64(0).str() == '0'
	assert bd.from_i64(-1).str() == '-1'
	d_ctx := bd.get_def_print_ctx()
	p_ctx := bd.PrintContext { 
		...d_ctx
		prec: 19 // digits in fixe precision
	}
	assert bd.from_i64(i64((u64(1) << 63) - 1)).str_ctx(p_ctx) == '9223372036854775807'
	assert bd.from_i64(i64(u64(1) << 63)).str_ctx(p_ctx) == '-9223372036854775808'
}

fn test_set_zero () {
	mut a := bd.new()
	bd.set_zero(mut a, false)  // is_neg false
	assert a.str() == '0'
	bd.set_zero(mut a, true)  // is_neg true == -0
	assert a.str() == '-0'
}

fn test_set () {
	a := bd.from_u64(4859)
	assert a.str() == '4859'
	mut b := bd.new()
	bd.set(mut b, a)
	assert b.str() == '4859'
}

fn test_set_nan () {
	mut a := bd.new()
	bd.set_nan(mut a)
	assert a.str() == 'NaN'
}

fn test_set_inf () {
	mut a := bd.new()
	bd.set_inf(mut a, false) // is_neg false
	assert a.str() == 'Inf'
	bd.set_inf(mut a, true) // is_neg true
	assert a.str() == '-Inf'
}

fn test_int () {
	assert bd.from_u64(243948).int() == 243948
}

fn test_from_str() ? {
	if a := bd.from_str('not number...') {
		println('${a}')
		assert false
	} else {
		assert true
	}
	if a := bd.from_str('NaN') {
		println('${a}')
		assert false
	} else {
		assert true
	}
	if a := bd.from_str('Inf') {
		println('${a}')
		assert false
	} else {
		assert true
	}
	d_ctx := bd.get_def_atof_ctx()
	a_ctx := bd.AtofContext {
		...d_ctx
		accept_nan: true
		accept_inf: true
	}
	b := bd.from_str_ctx('NaN', a_ctx) or {panic('')}
	assert b.str() == 'NaN'
	c := bd.from_str_ctx('Inf', a_ctx) or {panic('')}
	assert c.str() == 'Inf'
	a := bd.from_str('4857.93') or {panic('')}
	assert a.str() == '4857.93'
}

fn test_str () {
	a := bd.from_str('85743833330126475869724') or {panic('')}
	assert a.str() == '8.5743833330126476e22' // def. precision
	d_ctx := bd.get_def_print_ctx()
	p_ctx := bd.PrintContext {
		...d_ctx
		prec: 25 // default flags: fixed
	}
	assert a.str_ctx(p_ctx) == '85743833330126475869724' // full precision

}

const nb_test = 20 // can be longer...

fn test_plus() {
	for _ in 0..nb_test { 
		r1 := rand.f64()
		r2 := rand.f64()
		b1 := bd.from_str('$r1') or { panic('b1 from $r1') }
		b2 := bd.from_str('$r2') or { panic('b2 from $r2') }
		assert first_diff_rune('${b1 + b2}', '${r1 + r2}') >= 14 // prec def is 17 but f64 is not so precise
								// this value is necessary for long test but the prec. is usually much better
	}
}

fn test_add_i64() {
	a := bd.from_i64(8437)
	assert a.add_i64(45).str() == '8482'
}

fn test_minus () {
	for _ in 0..nb_test { 
		r1 := rand.f64()
		r2 := rand.f64()
		b1 := bd.from_str('$r1') or { panic('b1 from $r1') }
		b2 := bd.from_str('$r2') or { panic('b2 from $r2') }
		assert first_diff_rune('${b1 - b2}', '${r1 - r2}') >= 14 // prec def is 17 but f64 is not so precise
								// this value is necessary for long test but the prec. is usually much better
	}
}

fn test_mul() {
	for _ in 0..nb_test { 
		r1 := rand.f64()
		r2 := rand.f64()
		b1 := bd.from_str('$r1') or { panic('b1 from $r1') }
		b2 := bd.from_str('$r2') or { panic('b2 from $r2') }
		assert first_diff_rune('${b1 * b2}', '${r1 * r2}') >= 14 // prec def is 17 but f64 is not so precise
								// this value is necessary for long test but the prec. is usually much better
	}
}

fn test_mul_i64() {
	a := bd.from_str('847362.8474') or { panic('mul_i64') }
	assert a.mul_i64(-74).str() == '-62704850.7076'
}

// division:
// if (prec == BF_PREC_INF) {
// 	/* infinite precision: return BF_ST_INVALID_OP if not an exact
// 		result */
// for this reason the precision of division is set by default to 1024
// for another precision (with integer or otherwise) use div_ctxJ()

fn test_div() {
	for _ in 0..nb_test { 
		r1 := rand.f64()
		r2 := rand.f64()
		b1 := bd.from_str('$r1') or { panic('b1 from $r1') }
		b2 := bd.from_str('$r2') or { panic('b2 from $r2') }
		// println('$r1 / $r2 = ${r1 / r2}; b1 / b2 = ${b1 / b2}')
		assert first_diff_rune('${b1 / b2}', '${r1 / r2}') >= 14 // prec def is 17 but f64 is not so precise
								// this value is necessary for long test but the prec. is usually much better
	}
}

fn test_div_by_zero() {
		n1 := rand.f64()
		n := bd.from_str('$n1') or { panic('n from $n1') }
		d := bd.from_u64(0)
		r := '${n / d}'
		assert bd.get_bf_retval() == bd.bf_st_divide_zero
		assert (r == 'Inf') || (r == '-Inf')
}

// divrem
//    'q' is an integer. 'r' is rounded with prec and flags (prec can be
//    BF_PREC_INF).

fn test_rem() {
	for _ in 0..nb_test { 
		r1 := rand.f64()
		r2 := rand.f64()
		b1 := bd.from_str('$r1') or { panic('b1 from $r1') }
		b2 := bd.from_str('$r2') or { panic('b2 from $r2') }
		assert first_diff_rune('${b1 % b2}', '${math.fmod(r1, r2)}') >= 14 // prec def is 17 but f64 is not so precise
								// this value is necessary for long test but the prec. is usually much better
	}
}

fn test_divrem () {
	n := bd.from_u64(748)
	d := bd.from_u64(86)
	q, r := bd.divrem(n, d)
	assert bd.get_bf_retval() == 0
	// ADD ROUNDING versus zero
	assert q.str() == '8'
	assert r.str() == '60'
}

fn test_rint() {
	mut a := bd.from_i64(844736) / bd.from_u64(7)
	d := a.clone()
	a.rint()
	// println('$d -> $a') // resulta exact: '120676.57142857143'
	assert '$a' == '120677' // with rouding to nearest
	mut e := d.clone()
	d_ctx := bd.get_def_math_ctx()
	m_ctx := bd.MathContext {
		...d_ctx
		rnd: .rndz
	}
	e.rint_ctx(m_ctx)
	assert '$e' == '120676' // with rouding toward zero
}

fn test_sqrt() {
	a := bd.from_u64(64)
	b := bd.sqrt(a)
	assert '${b}' == '8'
	c := bd.from_i64(-64)
	assert '${bd.sqrt(c)}' == 'NaN'

	d_ctx := bd.get_def_math_ctx()
	m_ctx := bd.MathContext {
		...d_ctx
		prec: bd.prec_inf
	}
	// decimal.sqrt() does not accept infinite precision
	e := bd.sqrt_ctx(a, m_ctx)
	assert '${e}' == 'NaN' // sqrt(64)

	d := bd.from_str('483268.948') or {panic('sqrt')}
	f := bd.sqrt(d) // '695.17548000486898646' 
	assert '$f' == '695.17548000486899'
}

fn test_round() {
	mut s := bd.from_str('594837.5') or {panic('test_round1')}
	mut t := bd.from_str('38492.2') or {panic('test_round2')}
	mut u := bd.from_str('927.7') or {panic('test_round3')}

	// use context to fix the number of decimals
	mut m_ctx := bd.get_def_math_ctx()
	// default: nearest
	m_ctx.prec = 3 // digits
	assert '${bd.round_ctx(s, m_ctx)}' == '595000'
	assert '${bd.round_ctx(t, m_ctx)}' == '38500'
	assert '${bd.round_ctx(u, m_ctx)}' == '928'
	m_ctx.prec = 4 // digits
	assert '${bd.round_ctx(s, m_ctx)}' == '594800'
	assert '${bd.round_ctx(t, m_ctx)}' == '38490'
	assert '${bd.round_ctx(u, m_ctx)}' == '927.7'
	m_ctx.prec = 5 // digits
	assert '${bd.round_ctx(s, m_ctx)}' == '594840'
	assert '${bd.round_ctx(t, m_ctx)}' == '38492'
	m_ctx.prec = 6 // digits
	assert '${bd.round_ctx(s, m_ctx)}' == '594838'
	assert '${bd.round_ctx(t, m_ctx)}' == '38492.2'
}

fn test_pow_u64() {
	mut p_ctx := bd.get_def_print_ctx()
	p_ctx.prec = 50
	assert bd.pow_u64(bd.from_u64(4), 4).str() == '256'
	assert bd.pow_u64(bd.from_u64(7362), 5).str_ctx(p_ctx) == '21626142759723596832'
	assert bd.pow_u64(bd.from_u64(29904), 11).str_ctx(p_ctx) == '17101024310861730534051510526514269521344100040704'
}

fn first_diff_rune(s1 string, s2 string) int {
	len := mathutil.min(s1.len, s2.len)
	for i in 0..len {
		if s1[i] != s2[i] { return i}
	}
	return 2 * len
}