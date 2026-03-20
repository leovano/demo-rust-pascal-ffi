#[repr(C)]
pub struct RawString {
    pub ptr: *mut u8,
    pub len: usize,
    pub cap: usize,
}

#[unsafe(no_mangle)]
pub extern "C" fn rust_concat(
    a_ptr: *const u8,
    a_len: usize,
    b_ptr: *const u8,
    b_len: usize,
) -> RawString {
    unsafe {
        let s1 = std::str::from_utf8_unchecked(std::slice::from_raw_parts(a_ptr, a_len));
        let s2 = std::str::from_utf8_unchecked(std::slice::from_raw_parts(b_ptr, b_len));

        let combined = s1.to_string() + s2;

        let (ptr, len, cap) = combined.into_raw_parts();

        RawString { ptr, len, cap }
    }
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn rust_free_string(raw: RawString) {
    if !raw.ptr.is_null() {
        let _ = unsafe {
            String::from_raw_parts(raw.ptr, raw.len, raw.cap);
        };
    }
}
