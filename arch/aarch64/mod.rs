#[naked]
#[no_mangle]
#[link_section = ".text.boot"]
unsafe extern "C" fn _start() -> ! {
    core::arch::asm!("
        wfe ",
        options(noreturen),
    )
}
