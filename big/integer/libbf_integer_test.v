// libbf_integer_test.v
import libbf.big.integer as big

fn test_new_big() {
	n := big.new()
	assert n.f64() == 0.0
	assert big.get_bf_retval() == 0
	assert n.int() == 0
	assert big.get_bf_retval() == 0
	assert n.i64() == 0
	assert big.get_bf_retval() == 0
	assert n.str_base (16) == '0'
	assert big.get_bf_retval() == 0
}

fn test_from_i64() {
	assert big.from_i64(255).str_base (16) == 'ff'
	assert big.from_i64(127).str_base (16) == '7f'
	assert big.from_i64(1024).str_base (16) == '400'
	assert big.from_i64(2147483647).str_base (16) == '7fffffff'
	assert big.from_i64(-1).str_base (16) == '-1'
}

fn test_from_u64() {
	assert big.from_u64(255).str_base (16) == 'ff'
	assert big.from_u64(127).str_base (16) == '7f'
	assert big.from_u64(1024).str_base (16) == '400'
	assert big.from_u64(4294967295).str_base (16) == 'ffffffff'
	assert big.from_u64(4398046511104).str_base (16) == '40000000000'
	assert big.from_u64(-1).str_base (16) == 'ffffffffffffffff'
}

fn test_from_str() {
	assert big.from_str('9870123').str() == '9870123'
	assert big.from_str('').str() == '0'
	assert big.from_str('0').str() == '0'
	assert big.from_str('1').str() == '1'
	for i := 1; i < 307; i += 61 {
		input := '9'.repeat(i)
		out := big.from_str(input).str()
		// eprintln('>> i: $i input: $input.str()')
		// eprintln('>> i: $i   out: $out.str()')
		assert input == out
	}
}

fn test_from_hex_str() {
	// use base 0 to interpret 0x, 0b and 0 for hexa, binary and octal
	assert big.from_str_base('0x123', 0).str_base (16) == '123'
	assert big.from_str_base('0b110011', 0).str_base (2) == '110011'
	assert big.from_str_base('0123', 0).str_base (8) == '123'
	for i in 1 .. 33 {
		input := 'e'.repeat(i)
		out := big.from_str_base(input, 16).str_base (16)
		assert input == out
	}
	assert big.from_str('0').str_base (16) == '0'
}

fn test_str() {
	assert big.from_u64(255).str() == '255'
	assert big.from_u64(127).str() == '127'
	assert big.from_u64(1024).str() == '1024'
	assert big.from_u64(4294967295).str() == '4294967295'
	assert big.from_u64(4398046511104).str() == '4398046511104'
	// assert big.from_i64(int(4294967295)).str() == '18446744073709551615'
	// assert big.from_i64(-1).str() == '18446744073709551615'
	assert big.from_str_base('e'.repeat(80), 16).str() == '1993587900192849410235353592424915306962524220866209251950572167300738410728597846688097947807470'
}

fn test_plus() {
	mut a := big.from_u64(2)
	mut b := big.from_u64(3)
	c := a + b
	assert c.str_base (16) == '5'
	assert (big.from_u64(1024) + big.from_u64(1024)).str_base (16) == '800'
	a += b
	assert a.str_base (16) == '5'
	a.inc()
	assert a.str_base (16) == '6'
	a.dec()
	a.dec()
	assert a.str_base (16) == '4'
	a = big.from_str('8337839423')
	b = big.from_str('9683495887')
	assert '${b + a}' == '18021335310'
	assert big.get_bf_retval() == 0
	a = big.from_str('-8337839423')
	b = big.from_str('9683495887')
	assert '${b + a}' == '1345656464'
	assert big.get_bf_retval() == 0
	a = big.from_str('8337839423')
	b = big.from_str('-9683495887')
	assert '${b + a}' == '-1345656464'
	assert big.get_bf_retval() == 0
	a = big.from_str('-8337839423')
	b = big.from_str('-9683495887')
	assert '${b + a}' == '-18021335310'
	assert big.get_bf_retval() == 0
	a = big.from_str('-8337839423')
	b = big.from_str('8337839423')
	assert '${b + a}' == '0'
	assert big.get_bf_retval() == 0
	a = big.from_str('8337839423')
	b = big.from_str('-8337839423')
	assert '${b + a}' == '0'
	assert big.get_bf_retval() == 0
}

fn test_add() {
	a := big.from_str('833783942383378394238337839423')
	b := big.from_str('968349588796834958879683495887')
	assert '${b + a}' == '1802133531180213353118021335310'
	mut ctx := big.get_def_ctx()
	ctx.prec = 40
	nb_dig := ctx.prec / 3
	c := a.add(b, ctx)
	mut left := c.str()
	left = left[0..nb_dig]
	right := '1802133531180213353118021335310'[0..nb_dig]
	assert left == right
	assert big.get_bf_retval() == big.bf_st_inexact
}

fn test_add_i64() {

}

fn test_minus() {
	mut a := big.from_u64(2)
	mut b := big.from_u64(3)
	c := b - a
	assert c.str_base (16) == '1'
	e := big.from_u64(1024)
	ee := e - e
	assert ee.str_base (16) == '0'
	b -= a
	assert b.str_base (16) == '1'
	a = big.from_str('8337839423')
	b = big.from_str('9683495887')
	assert '${b - a}' == '1345656464'
	assert '${a - b}' == '-1345656464'
	a = big.from_str('-8337839423')
	b = big.from_str('-9683495887')
	assert '${b - a}' == '-1345656464'
	assert '${a - b}' == '1345656464'
	a = big.from_str('-8337839423')
	b = big.from_str('9683495887')
	assert '${b - a}' == '18021335310'
	assert '${a - b}' == '-18021335310'
	a = big.from_str('-8337839423')
	b = big.from_str('-8337839423')
	assert '${b - a}' == '0'
	assert '${a - b}' == '0'
	a = big.from_str('8337839423')
	b = big.from_str('8337839423')
	assert '${b - a}' == '0'
	assert '${a - b}' == '0'
}

fn test_sub() {
	a := big.from_str('833783942383378394238337839423')
	b := big.from_str('968349588796834958879683495887')
	assert '${b - a}' == '134565646413456564641345656464'
	mut ctx := big.get_def_ctx()
	ctx.prec = 40
	nb_dig := int(f64(ctx.prec) / 3.321928094887362)
	c := b.sub(a, ctx)
	mut left := c.str()
	left = left[0..nb_dig]
	right := '134565646413456564641345656464'[0..nb_dig]
	assert left == right
	assert big.get_bf_retval() == big.bf_st_inexact
}

fn test_multiply() {
	mut a := big.from_u64(2)
	mut b := big.from_u64(3)
	c := b * a
	assert c.str_base (16) == '6'
	e := big.from_u64(1024)
	e2 := e * e
	e4 := e2 * e2
	e8 := e2 * e2 * e2 * e2
	e9 := e8 + big.from_u64(1)
	d := ((e9 * e9) + b) * c
	assert e4.str_base (16) == '10000000000'
	assert e8.str_base (16) == '100000000000000000000'
	assert e9.str_base (16) == '100000000000000000001'
	assert d.str_base (16) == '60000000000000000000c00000000000000000018'
	a *= b
	assert a.str_base (16) == '6'
	a = big.from_str('12345678901234567890')
	b = big.from_str('98765432109876543210')
	assert '${a * b}' == '1219326311370217952237463801111263526900'
	a = big.from_str('12345678901234567890')
	b = big.from_str('281474976710656')
	assert '${a * b}' == '3474999681202237152443873718435840'
	a = big.from_str('12345678901234567890')
	a.mul_2exp(48)
	assert '${a}' == '3474999681202237152443873718435840'
	a = big.from_str('12345678901234567890')
	a.mul_2exp(2) // lshift(2)
	b = big.from_str('281474976710656')
	b.mul_2exp(4)
	assert '${a * b}' == '222399979596943177756407917979893760'
}

fn test_divide() {
	mut a := big.from_u64(2)
	mut b := big.from_u64(3)
	c := b / a
	assert c.str_base (16) == '1'
	assert (b % a).str_base (16) == '1' // rem is rounded to zero
	e := big.from_u64(1024) // dec(1024) == hex(0x400)
	ee := e / e
	assert ee.str_base (16) == '1'
	assert (e / a).str_base (16) == '200'
	assert (e / (a * a)).str_base (16) == '100'
	b /= a
	assert b.str_base (16) == '1'
	a = big.from_str('12345678901234567890')
	b = big.from_str('281474976710656')
	mut ctx := big.get_def_ctx()
	ctx.rnd = .rndz
	assert '${a.div_ctx(b, ctx)}' == '43860'
	a = big.from_str('12345678901234567890')
	a.mul_2exp_ctx(-48, ctx)
	assert '${a}' == '43860'
}

fn test_mod() {
	assert ((big.from_u64(13) % big.from_u64(10)).i64()) == 3
	assert ((big.from_u64(13) % big.from_u64(9)).i64()) == 4
	assert ((big.from_u64(7) % big.from_u64(5)).i64()) == 2
}

fn test_divrem() {
	x, y := big.divrem(big.from_u64(13), big.from_u64(10))
	assert x.i64() == 1
	assert y.i64() == 3
	p, q := big.divrem(big.from_u64(13), big.from_u64(9))
	assert p.i64() == 1
	assert q.i64() == 4
	c, d := big.divrem(big.from_u64(7), big.from_u64(5))
	assert c.i64() == 1
	assert d.i64() == 2
}

fn test_divide_mod_big() {
	a := big.from_str('987654312345678901234567890')
	b := big.from_str('98765432109876543210')

	assert '${a / b}' == '9999999'
	assert '${a % b}' == '90012345579011111100'
}

fn test_divide_mod() {
	divide_mod_inner(0, -3)
	divide_mod_inner(22, 3)
	divide_mod_inner(22, -3)
	divide_mod_inner(-22, 3)
	divide_mod_inner(-22, -3)
	divide_mod_inner(1, -3)
	divide_mod_inner(-1, 3)
	divide_mod_inner(-1, -3)
	divide_mod_inner(1 << 8, 1 << 8)
	divide_mod_inner(-1 << 8, 1 << 4)
}

fn divide_mod_inner(a int, b int) {
	a_big := big.from_i64(a)
	b_big := big.from_i64(b)

	assert '${a_big / b_big}' == '${a / b}'
	assert '${a_big % b_big}' == '${a % b}'
}

fn test_ceil_div() {
	mut ctx := big.get_def_ctx()
	ctx.rnd = .rndu
	mut a := big.from_i64(495943893)
	mut b := a.div_ctx(big.from_i64(594837), ctx)
	assert '${b}' == '834'
	a = big.from_i64(-938206328)
	b = a.div_ctx(big.from_i64(85943), ctx)
	assert '${b}' == '-10916'
}

fn test_floor_div() {
	mut ctx := big.get_def_ctx()
	ctx.rnd = .rndd
	mut a := big.from_i64(495943893)
	mut b := a.div_ctx(big.from_i64(594837), ctx)
	assert '${b}' == '833'
	a = big.from_i64(-938206328)
	b = a.div_ctx(big.from_i64(85943), ctx)
	assert '${b}' == '-10917'
}

fn test_trunc_div() {
	mut ctx := big.get_def_ctx()
	ctx.rnd = .rndz // toward zero
	mut a := big.from_i64(495943893)
	mut b := a.div_ctx(big.from_i64(594837), ctx)
	assert '${b}' == '833'
	a = big.from_i64(-938206328)
	b = a.div_ctx(big.from_i64(85943), ctx)
	assert '${b}' == '-10916'
}

fn test_nearest_div() {
	mut ctx := big.get_def_ctx()
	ctx.rnd = .rndn // toward nearest or even
	mut a := big.from_i64(495943893)
	mut b := a.div_ctx(big.from_i64(594837), ctx)
	assert '${b}' == '834'
	a = big.from_i64(-938206328)
	b = a.div_ctx(big.from_i64(85943), ctx)
	assert '${b}' == '-10917'
	a = big.from_i64(7)
	b = a.div_ctx(big.from_i64(2), ctx)
	assert '${b}' == '4'
}

fn test_isqrt() {
	a := big.from_u64(81)
	b := big.isqrt(a)
	assert '${b}' == '9'
}

fn test_sqrtrem() {
	a := big.from_u64(69)
	r, rem := big.sqrtrem(a)
	assert '${r}' == '8'
	assert '${rem}' == '5'
}
/*
fn test_factorial() {
	f5 := big.factorial(5)
	assert f5.str_base (16) == '78'
	f100 := big.factorial(100)
	assert f100.str_base (16) == '1b30964ec395dc24069528d54bbda40d16e966ef9a70eb21b5b2943a321cdf10391745570cca9420c6ecb3b72ed2ee8b02ea2735c61a000000000000000000000000'
}
*/
// fn trimbytes(n int, x []byte) []byte {
// 	mut res := x.clone()
// 	res.trim(n)
// 	return res
// }

// fn test_bytes() {
// 	assert big.from_i64(0).bytes().len == 128
// 	assert big.from_hex_string('e'.repeat(100)).bytes().len == 128
// 	assert trimbytes(3, big.from_i64(1).bytes()) == [byte(0x01), 0x00, 0x00]
// 	assert trimbytes(3, big.from_i64(1024).bytes()) == [byte(0x00), 0x04, 0x00]
// 	assert trimbytes(3, big.from_i64(1048576).bytes()) == [byte(0x00), 0x00, 0x10]
// }

// fn test_bytes_trimmed() {
// 	assert big.from_i64(0).bytes_trimmed().len == 0
// 	assert big.from_hex_string('AB'.repeat(50)).bytes_trimmed().len == 50
// 	assert big.from_i64(1).bytes_trimmed() == [byte(0x01)]
// 	assert big.from_i64(1024).bytes_trimmed() == [byte(0x00), 0x04]
// 	assert big.from_i64(1048576).bytes_trimmed() == [byte(0x00), 0x00, 0x10]
// }
