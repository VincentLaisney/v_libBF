import libbf.big.decimal as bd

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
	a := bd.from_str('4857.93') or {panic('')}
	assert a.str() == '4857.93'
}

fn test_str () {

}

// division:
// if (prec == BF_PREC_INF) {
// 	/* infinite precision: return BF_ST_INVALID_OP if not an exact
// 		result */

// divrem
//    'q' is an integer. 'r' is rounded with prec and flags (prec can be
//    BF_PREC_INF).

fn test_pow_ui() {

}

fn test_divrem () {

}