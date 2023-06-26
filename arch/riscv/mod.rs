#[no_mangle]
#[link_section = ".text.boot"]
unsafe extern "C" fn _start() -> ! {
    loop {
        core::arch::asm!("
            wfi ",
        )
    }
}
