unit LibInvoiceSealer.Raw;

{$linklib gcc_s}
{$linklib gcc}

interface

uses LibInvoiceSealer;

function process_invoices(Invoices: PInvoice; Len: SizeInt): LongInt; cdecl; external 'invoice_sealer';
function process_invoices_single(Invoices: PInvoice; Len: SizeInt): LongInt; cdecl; external 'invoice_sealer';

implementation
end.
