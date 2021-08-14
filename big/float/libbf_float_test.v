import libbf.big.float as bf

fn test_new() {
	a := bf.new()
	assert a.is_zero()
}

fn test_from_u64() {
	a := bf.from_u64(45)
	assert a.str() == '45'
}

fn test_from_f64() {
	assert bf.from_f64(4830.297).str() == '4830.297'
	
}

fn test_str() {
	assert bf.from_f64(234.4598).str() == '234.4598'
}