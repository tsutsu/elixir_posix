#[macro_use] extern crate rustler;
#[macro_use] extern crate rustler_codegen;
#[macro_use] extern crate lazy_static;
#[macro_use] extern crate nix;

use std::io::Write;
use std::error::Error;
use rustler::{ NifEnv, NifTerm, NifResult, NifEncoder, NifError };
use rustler::env::OwnedEnv;
use rustler::types::binary::OwnedNifBinary;
use rustler::types::pid::NifPid;
use nix::Errno;
use nix::sys::signal::{ Signal, SigAction, SaFlags, SigHandler, SigSet };

static mut CONTROLLER_PID: Option<NifPid> = None;

mod atoms {
    rustler_atoms! {
        atom undefined;
        atom ok;
        atom notify;
        atom caught;
    }
}

rustler_export_nifs! {
    "Elixir.System.POSIX.Impl",
    [
        ("errno_probe", 1, errno_probe),
        ("signal_probe", 1, signal_probe),
        ("signal_set_controller", 1, signal_set_controller),
        ("signal_register", 1, signal_register)
    ],
    None
}

fn errno_probe<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
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

fn signal_probe<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let input: i64 = try!(args[0].decode());
    let signal: Signal = match Signal::from_c_int(input as nix::c_int) {
        Result::Ok(val) => val,
        Result::Err(_) => return Ok(atoms::undefined().encode(env))
    };

    let sym = format!("{:?}", signal);

    let mut sym_bin = OwnedNifBinary::new(sym.len()).unwrap();
    sym_bin.as_mut_slice().write(sym.as_bytes()).unwrap();

    Ok((input, sym_bin.release(env)).encode(env))
}

fn signal_set_controller<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let new_controller_pid: NifPid = try!(args[0].decode());

    unsafe {
        CONTROLLER_PID = Some(new_controller_pid);
    }

    Ok(atoms::ok().encode(env))
}

extern "C" fn signal_catch(code: nix::c_int) {
    let controller_pid: NifPid = unsafe {
        CONTROLLER_PID.clone().unwrap()
    };

    OwnedEnv::new().send_and_clear(&controller_pid, |env|
        (atoms::notify(), (atoms::caught(), code)).encode(env)
    );
}


fn signal_register<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let signal_code: i64 = try!(args[0].decode());
    let signal: Signal = match Signal::from_c_int(signal_code as nix::c_int) {
        Ok(val) => val,
        Err(_) => return Err(NifError::BadArg)
    };

    let mut sigset: SigSet = SigSet::thread_get_mask().unwrap();

    if sigset.contains(signal) {
        sigset.remove(signal);
    }

    let sigaction: SigAction = SigAction::new(
        SigHandler::Handler(signal_catch),
        SaFlags::empty(),
        sigset
    );

    let () = unsafe {
        nix::sys::signal::sigaction(signal, &sigaction).unwrap();
    };


    Ok(atoms::ok().encode(env))
}
