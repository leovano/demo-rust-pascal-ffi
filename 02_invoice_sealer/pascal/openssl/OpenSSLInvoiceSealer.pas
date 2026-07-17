unit OpenSSLInvoiceSealer;

{$mode objfpc}{$H+}

interface

uses InvoiceTypes;

procedure ProcessInvoicesOpenSSL(var Invoices: array of TInvoice);

implementation

uses FastSHA256;

procedure ProcessInvoicesOpenSSL(var Invoices: array of TInvoice);
var
  I: Integer;
  Ctx: TSHA256Context;
  Digest: TSHA256Digest;
begin
  for I := 0 to High(Invoices) do
  begin
    Invoices[I].TaxAmount := Invoices[I].NetAmount * Invoices[I].TaxRate;
    Invoices[I].GrossAmount := Invoices[I].NetAmount + Invoices[I].TaxAmount;

    SHA256Init(Ctx);
    SHA256Update(Ctx, Invoices[I].Id, SizeOf(Invoices[I].Id));
    SHA256Update(Ctx, Invoices[I].CustomerId, SizeOf(Invoices[I].CustomerId));
    SHA256Update(Ctx, Invoices[I].NetAmount, SizeOf(Invoices[I].NetAmount));
    SHA256Update(Ctx, Invoices[I].TaxRate, SizeOf(Invoices[I].TaxRate));
    SHA256Update(Ctx, Invoices[I].TaxAmount, SizeOf(Invoices[I].TaxAmount));
    SHA256Final(Ctx, Digest);

    Move(Digest[0], Invoices[I].ValidationHash[0], 32);
  end;
end;

end.
