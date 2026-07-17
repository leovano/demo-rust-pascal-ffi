unit InvoiceTypes;

{$mode objfpc}{$H+}

interface

type
  TInvoice = record
    Id: QWord;
    CustomerId: LongWord;
    NetAmount: Double;
    TaxRate: Double;
    GrossAmount: Double;
    TaxAmount: Double;
    ValidationHash: array[0..31] of Byte;
  end;
  PInvoice = ^TInvoice;

implementation

end.
