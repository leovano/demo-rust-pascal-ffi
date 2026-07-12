/// Concatenates two string buffers into an output destination.
///
/// # Safety
///
/// This function is unsafe because it dereferences raw pointer arguments. The caller must ensure that:
/// - `a_ptr` points to a valid, initialized block of at least `a_len` bytes.
/// - `b_ptr` points to a valid, initialized block of at least `b_len` bytes.
/// - `out_ptr` points to a writable block of memory of size at least `a_len + b_len` bytes.
/// - The memory ranges do not overlap.
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
