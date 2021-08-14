import libbf.big.integer as big

fn test_negative_pow() {
	x := big.from_u64(29)
	y := big.from_i64(-4)
	r := big.power(x, y)
	assert '${r}' == '0'
}

