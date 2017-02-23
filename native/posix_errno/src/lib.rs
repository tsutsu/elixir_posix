#[macro_use] extern crate rustler;
#[macro_use] extern crate rustler_codegen;
#[macro_use] extern crate lazy_static;
#[macro_use] extern crate nix;

use std::io::Write;
use std::error::Error;
use rustler::{ NifEnv, NifTerm, NifResult, NifEncoder };
use rustler::types::binary::{ OwnedNifBinary };
use nix::Errno;

mod atoms {
    rustler_atoms! {
        atom undefined;
    }
}

rustler_export_nifs! {
    "Elixir.System.POSIX.Errno.Impl",
    [("probe", 1, from_i32)],
    None
}

fn from_i32<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let input: i64 = try!(args[0].decode());
    let errno: Errno = Errno::from_i32(input as i32);

    let sym = format!("{:?}", errno);
    let desc = errno.description();

    let mut sym_bin = OwnedNifBinary::new(sym.len()).unwrap();
    sym_bin.as_mut_slice().write(sym.as_bytes()).unwrap();

    let mut desc_bin = OwnedNifBinary::new(desc.len()).unwrap();
    desc_bin.as_mut_slice().write(desc.as_bytes()).unwrap();

    if errno == Errno::UnknownErrno {
        return Ok(atoms::undefined().encode(env))
    };

    Ok((input, sym_bin.release(env), desc_bin.release(env)).encode(env))
}
