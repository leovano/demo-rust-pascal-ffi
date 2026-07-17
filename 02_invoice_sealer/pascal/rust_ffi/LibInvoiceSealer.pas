unit LibInvoiceSealer;

{$mode objfpc}{$H+}

interface

uses InvoiceTypes;

procedure ProcessInvoices(var Invoices: array of TInvoice);
procedure ProcessInvoicesSingle(var Invoices: array of TInvoice);

implementation

uses SysUtils, LibInvoiceSealer.Raw;

procedure ProcessInvoices(var Invoices: array of TInvoice);
begin
  if Length(Invoices) > 0 then
  begin
    if process_invoices(@Invoices[0], Length(Invoices)) <> 0 then
      raise Exception.Create('Rust process_invoices failed or panicked');
  end;
end;

procedure ProcessInvoicesSingle(var Invoices: array of TInvoice);
begin
  if Length(Invoices) > 0 then
  begin
    if process_invoices_single(@Invoices[0], Length(Invoices)) <> 0 then
      raise Exception.Create('Rust process_invoices_single failed or panicked');
  end;
end;

end.
