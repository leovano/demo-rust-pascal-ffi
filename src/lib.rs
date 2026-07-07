#[unsafe(no_mangle)]
pub unsafe extern "C" fn rust_concat(
    a_ptr: *const u8,
    a_len: usize,
    b_ptr: *const u8,
    b_len: usize,
    out_ptr: *mut u8,
) {
    unsafe {
        if a_len > 0 && !a_ptr.is_null() {
            std::ptr::copy_nonoverlapping(a_ptr, out_ptr, a_len);
        }
        if b_len > 0 && !b_ptr.is_null() {
            std::ptr::copy_nonoverlapping(b_ptr, out_ptr.add(a_len), b_len);
        }
    }
}
