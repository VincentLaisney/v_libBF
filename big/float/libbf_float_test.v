import libbf.big.float as bf
import math
import math.mathutil
import rand

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

const nb_test = 20 // can be longer...

fn test_add() {
	for _ in 0..nb_test { 
		r1 := rand.f64()
		r2 := rand.f64()
		b1 := bf.from_f64(r1)
		b2 := bf.from_f64(r2)
		assert first_diff_rune('${b1 + b2}', '${r1 + r2}') >= 15 // prec def is 17 but f64 is not so precise
	}
}

fn test_minus() {
	for _ in 0..nb_test {
		r1 := rand.f64()
		r2 := rand.f64()
		b1 := bf.from_f64(r1)
		b2 := bf.from_f64(r2)
		assert first_diff_rune('${b1 - b2}', '${r1 - r2}') >= 15 // prec def is 17 but f64 is not so precise
	}

}

fn test_mul() {
	for _ in 0..nb_test {
		r1 := rand.f64()
		r2 := rand.f64()
		b1 := bf.from_f64(r1)
		b2 := bf.from_f64(r2)
		assert first_diff_rune('${b1 * b2}', '${r1 * r2}') >= 15 // prec def is 17 but f64 is not so precise
	}
}

fn test_div() {
	for _ in 0..nb_test {
		r1 := rand.f64()
		r2 := rand.f64()
		b1 := bf.from_f64(r1)
		b2 := bf.from_f64(r2)
		assert first_diff_rune('${b1 / b2}', '${r1 / r2}') >= 15 // prec def is 17 but f64 is not so precise
	}
}

fn test_mod() {
	for _ in 0..nb_test {
		r1 := rand.f64()
		r2 := rand.f64()
		b1 := bf.from_f64(r1)
		b2 := bf.from_f64(r2)
		assert first_diff_rune('${b1 % b2}', '${math.fmod(r1, r2)}') >= 15 // prec def is 17 but f64 is not so precise
	}
}
// transcendentals
fn test_const() {
	assert bf.log2().str() == '0.69314718055994531'
	assert bf.pi().str() == '3.1415926535897932'
	mut ctx := bf.get_def_print_ctx()
	ctx.prec = 100
	assert bf.pi().str_ctx(ctx) == '3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117068'
}

fn test_sin_cos() {
	// canonical value are exact with correct rounding
	assert bf.sin(bf.pi()/bf.from_u64(2)).str() == '1'
	assert bf.sin(bf.pi()/bf.from_u64(4)).str() == (bf.sqrt(bf.from_u64(2)) / bf.from_i64(2)).str()
	assert bf.sin(bf.pi()/bf.from_u64(6)).str() == '0.5'
	assert bf.sin(bf.pi()/bf.from_u64(3)).str() == (bf.sqrt(bf.from_u64(3)) / bf.from_u64(2)).str()
	assert bf.cos(bf.from_u64(0)).str() == '1'
	assert bf.cos(bf.pi()/bf.from_u64(4)).str() == (bf.sqrt(bf.from_u64(2)) / bf.from_i64(2)).str()
	assert bf.cos(bf.pi()/bf.from_u64(3)).str() == '0.5'
	assert bf.cos(bf.pi()/bf.from_u64(6)).str() == (bf.sqrt(bf.from_u64(3)) / bf.from_u64(2)).str()
	// random value
	a := bf.from_str('0.48674624102553811') or {panic('')}
	assert bf.get_bf_retval() == bf.bf_st_inexact
	assert bf.sin(a).str() == '0.46775250353608653'
	assert bf.cos(a).str() == '0.88385948851371356'
}

fn test_tan() {
	assert bf.tan(bf.pi() / bf.from_f64(4)).str() == '1'
//	assert bf.tan(bf.pi() / bf.from_f64(2)).str() == 'inf'
	assert bf.tan(bf.pi() / bf.from_f64(3)).str() == bf.sqrt(bf.from_u64(3)).str()
	assert bf.tan(bf.pi() / bf.from_f64(6)).str() == (bf.from_u64(1) / bf.sqrt(bf.from_u64(3))).str()

	// random
	a := bf.from_str('0.8752419941') or {panic('')}
	assert bf.get_bf_retval() == bf.bf_st_inexact
	assert bf.tan(a).str() == '1.1980107696920163'
}

fn test_atan() {
	a := bf.from_str('inf') or {panic('')}
	assert bf.get_bf_retval() == 0
	assert bf.atan(a).str() == (bf.pi() / bf.from_f64(2)).str()
}

const log210 = 3.3219280948873623478703194294893901758648313930245806120547563958
const prec_500 = u64(500 * log210)

fn test_precision() {
	def_ctx := bf.get_def_print_ctx()
	print_ctx := bf.PrintContext{ 
		...def_ctx
		prec: 500
	}
	pi_500 := '3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679821480865132823066470938446095505822317253594081284811174502841027019385211055596446229489549303819644288109756659334461284756482337867831652712019091456485669234603486104543266482133936072602491412737245870066063155881748815209209628292540917153643678925903600113305305488204665213841469519415116094330572703657595919530921861173819326117931051185480744623799627495673518857527248912279381830119491'
	bf_pi := bf.pi().str_ctx(print_ctx)
	assert bf_pi != pi_500 // maybe ==
	assert first_diff_rune(bf_pi, pi_500) > 1024/log210 - 2 // bits cf rounding
	def_m_ctx := bf.get_def_math_ctx()
	math_ctx := bf.MathContext {
		...def_m_ctx
		prec: u64(500 * log210 + 10)
	}
	bf_pi_500 := bf.pi_ctx(math_ctx).str_ctx(print_ctx)
	assert bf_pi_500 == pi_500
}

fn first_diff_rune(s1 string, s2 string) int {
	len := mathutil.min(s1.len, s2.len)
	for i in 0..len {
		if s1[i] != s2[i] { return i}
	}
	return 2 * len
}