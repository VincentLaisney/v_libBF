import libbf.big.float as bf

fn test_new() {
	a := bf.new()
	assert a.is_zero()
}

fn test_from_u64() {
	a := bf.from_u64(123456789012)
	assert a.str() == '123456789012'
	assert bf.from_u64(0).str() == '0'
}

fn test_from_i64() {
	assert bf.from_i64(-544439).str() == '-544439'
	assert bf.from_i64(3042394852).str() == '3042394852'
	assert bf.from_i64(-0).str() == '0'	
}

fn test_from_f64() {
	assert bf.from_f64(23).str() == '23'
	assert bf.from_f64(25e4).str() == '250000'
	assert bf.from_f64(12e-5).str() == '0.00012'
	// sometimes it is necessary to put a smallest precision
	ctx := bf.PrintContext {
		base: 10
		prec: 9 // with default (prec: 17) got '4830.2970999999998'
	}
	assert bf.from_f64(4830.2971).str_ctx(ctx) == '4830.2971'
	
}

fn test_from_str() {
	atof_ctx := bf.AtofContext {
		base: 16
		prec: bf.def_precision
	}
	print_ctx := bf.PrintContext {
		base: 16
		prec: 20
	}
	mut a := bf.from_str('0.000') or {panic('')}
	assert a.str() == '0'
	a = bf.from_str_ctx('a49f',atof_ctx) or {panic('')}
	assert a.str_ctx(print_ctx) == 'a49f'
	a = bf.from_str_ctx('27f383ce9b0694736a',atof_ctx) or {panic('')}
	assert a.str_ctx(print_ctx) == '27f383ce9b0694736a'
}

fn test_from_str_error() ? {
	bf.from_str('34') ?
		// invalid strings
	if x := bf.from_str('str') {
			println(x)
			assert false
	} else {
			assert true
	}
	if x := bf.from_str('string_longer_than_10_chars') {
			println(x)
			assert false
	} else {
			assert true
	}
	if x := bf.from_str('') {
			println(x)
			assert false
	} else {
			assert true
	}

}

fn test_str() {
	assert bf.from_f64(234.4598).str() == '234.4598'
	assert bf.from_u64(2344598).str() == '2344598'
	assert bf.from_i64(-386).str() == '-386'
}

fn test_i64() {
	a := bf.from_str('-439') or {panic('')}
	assert a.i64() == -439
}

// transcendentals
