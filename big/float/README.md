# LibFloat

The routines of the libBF library have been adapted to the V philosophy. The conversion routines from string return an option Bigfloat (`?Bigfloat`). Many of the functions return a Bigfloat instead of taking a `mut Bigfloat` parameter.

## The Contexts ##
To control the operations of the functions Fabrice Bellard put generaly three parameters: precision, rounding and flags.
This V library can use either default parameters, which are also available through routines and functions with the suffix _ctx and that take an additional parameter.

There are three contexts.

### MathContext ###
It control most of the operation of the library. **The precision parameter indicates the number of bits**. The default value is 1024, i.e. 32 words of 32 bits. It corresponds to an decimal number of around 300 digits.

The default rounding is rounding to the nearest.

### PrintContext ###
The PrintContext control the conversion of the Bigfloat to strings. **The precision indicates the number of digits**.

The default rounding is toward zero and the printing format is `fixed`. They can be changed through the rounding and flags parameters.

### AtofContext ###
The AtofContext control the conversion from string (ascii) to Bigfloat. The precision indicates the precision of resulting BigInt. If the precision is not sufficient the routines return the retval of `bf_st_inexact`.

The default behavior of the conversion routine is to return an error when the string does not contain a valid number. But if the `AtofContext.accept_nan` flag is true it accept any string and return a NaN-Bigfloat

## The retval ##
Each routine of the library return a status value. This value is available through the bf_get_retval() function. If this value is not 0, it means that something happens. This value could be tested.

The return status are constants:

`const bf_st_invalid_op = 0`

`const bf_st_divide_zero = 1`

`const bf_st_overflow = 2`

`const bf_st_underflow = 4`

`const bf_st_inexact = 8`
