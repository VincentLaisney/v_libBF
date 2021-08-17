# v_libbf

## Porting of libBF library of Fabrice Bellard to the V programming language (vlang)

Module for [V (Vlang)](https://vlang.io/) with most of the bindings of [libBF](https://bellard.org/libbf/).

The libBF is state-free. To ease the use of this module, we have used some static variable to represent the state. Each function of the original library have several arguments to indicate the precision, rounding and flags. Most of the functions have dual-aspect. One do not take a MathContext structure argument and use default arguments, the other have a last argument for the MathContext.

The suffix for the V types of numerical have been renamed according to the V names. The endings in _ui _si and _d are _u64 _i64 and _f64.

The conversion routines begin with from_ and the output routines are member functions: .i64() .u64() .f64() and .str().
This last routine get a 10-base representation. For the original bf_ftoa() there is .str_base(base int). The other names have not been changed.

The operators + - * / % have been overloaded.

The imports are:
`import libbf.big.integer`
or
`import libbf.big.float`

### Bigfloat ###
The Bigfloats are available through a distinct module. See the [README](https://github.com/VincentLaisney/v_libBF/tree/main/big/float) in the big/float folder.

### Installation ###
The libbf is part of the distribution and has been patched.

Locate your vmodules directory with `v doctor` command.

Create a libbf directory in your vmodules directory and copy in it the big directory which contains the libbf library and the interface files.

At the first run of V, the libbf library get compiled for your system. It is possible that the default C-compiler of V reports a bug. In this case compile it with the argument `-cc cc` to use the default compiler of your system. In this case you get a message:

`The /your/path/to_vmodules/library/libbf/big/libbf.o file has not been found. Compilation of the /your/path/to_vmodules/library/cache/xxxxxx/xxxxx.o`.
In this case you must copy the paths in order to copy the cached files to the `libbf/big/` directory:

`cp /your/path/to_vmodules/library/cache/xxx/xx.o /your/path/to_vmodules/library/libbf/big/libbf.o`

Thus you can use the next times the default compiler.

### License ###
LibBF is under the [MIT-license](https://mit-license.org/)

V_gmp is under the [MIT-license](https://raw.githubusercontent.com/VincentLaisney/v_gmp/main/LICENSE).

### To do ###
Porting of Decimal part of LibBF
