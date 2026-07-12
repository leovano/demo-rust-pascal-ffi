use sha2::{Digest, Sha256};
use std::panic::{AssertUnwindSafe, catch_unwind};

#[repr(C)]
pub struct Invoice {
    pub id: u64,
    pub customer_id: u32,
    pub net_amount: f64,
    pub tax_rate: f64,
    pub gross_amount: f64,
    pub tax_amount: f64,
    pub validation_hash: [u8; 32],
}

#[inline]
fn seal_invoice(invoice: &mut Invoice) {
    invoice.tax_amount = invoice.net_amount * invoice.tax_rate;
    invoice.gross_amount = invoice.net_amount + invoice.tax_amount;

    let mut hasher = Sha256::new();
    hasher.update(invoice.id.to_le_bytes());
    hasher.update(invoice.customer_id.to_le_bytes());
    hasher.update(invoice.net_amount.to_le_bytes());
    hasher.update(invoice.tax_rate.to_le_bytes());
    hasher.update(invoice.tax_amount.to_le_bytes());

    let bytes = hasher.finalize();
    invoice.validation_hash.copy_from_slice(&bytes);
}

fn with_unwind<F>(f: F) -> i32
where
    F: FnOnce() + std::panic::UnwindSafe,
{
    match catch_unwind(f) {
        Ok(_) => 0,
        Err(_) => 1,
    }
}

/// Processes and seals invoices sequentially in a single thread.
///
/// # Safety
///
/// This function is unsafe because it dereferences raw pointer arguments. The caller must ensure that:
/// - `invoices_ptr` points to a valid, aligned array of `Invoice` structs.
/// - `invoices_ptr` remains valid and is not mutated concurrently outside this function during the call.
/// - `invoices_len` represents the exact number of elements in the array.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn process_invoices_single(
    invoices_ptr: *mut Invoice,
    invoices_len: usize,
) -> i32 {
    if invoices_ptr.is_null() || invoices_len == 0 {
        return -1;
    }

    with_unwind(AssertUnwindSafe(move || {
        let invoices = unsafe { std::slice::from_raw_parts_mut(invoices_ptr, invoices_len) };

        for invoice in invoices {
            seal_invoice(invoice);
        }
    }))
}

/// Processes and seals invoices in parallel using standard library scoped threads.
///
/// # Safety
///
/// This function is unsafe because it dereferences raw pointer arguments. The caller must ensure that:
/// - `invoices_ptr` points to a valid, aligned array of `Invoice` structs.
/// - `invoices_ptr` remains valid and is not mutated concurrently outside this function during the call.
/// - `invoices_len` represents the exact number of elements in the array.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn process_invoices(invoices_ptr: *mut Invoice, invoices_len: usize) -> i32 {
    if invoices_ptr.is_null() || invoices_len == 0 {
        return -1;
    }

    with_unwind(AssertUnwindSafe(move || {
        let invoices = unsafe { std::slice::from_raw_parts_mut(invoices_ptr, invoices_len) };

        let num_threads = std::thread::available_parallelism()
            .map(|n| n.get())
            .unwrap_or(2);

        let chunk_size = invoices_len.div_ceil(num_threads);

        std::thread::scope(|s| {
            for chunk in invoices.chunks_mut(chunk_size) {
                s.spawn(move || {
                    for invoice in chunk {
                        seal_invoice(invoice);
                    }
                });
            }
        });
    }))
}
