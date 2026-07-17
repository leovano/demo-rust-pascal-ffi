program InvoiceSealerDemo;

uses SysUtils, InvoiceTypes, LibInvoiceSealer, PascalInvoiceSealer, OpenSSLInvoiceSealer;

const
  DEFAULT_INVOICE_COUNT = 10000000;

type
  TInvoiceArray = array of TInvoice;
  TSealerProc = procedure(var Invoices: array of TInvoice);

function DigestToHex(const HashArray: array of Byte): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to High(HashArray) do
    Result := Result + IntToHex(HashArray[I], 2);
  Result := LowerCase(Result);
end;

procedure PrintInvoice(const Inv: TInvoice);
begin
  WriteLn('  ID:          ', Inv.Id);
  WriteLn('  Customer ID: ', Inv.CustomerId);
  WriteLn('  Net Amount:  ', Inv.NetAmount:0:2);
  WriteLn('  Tax Rate:    ', (Inv.TaxRate * 100):0:1, '%');
  WriteLn('  Tax Amount:  ', Inv.TaxAmount:0:2);
  WriteLn('  Gross Amt:   ', Inv.GrossAmount:0:2);
  WriteLn('  Hash Seal:   ', DigestToHex(Inv.ValidationHash));
end;

procedure PopulateInvoices(var Invoices: TInvoiceArray);
var
  I: Integer;
begin
  for I := 0 to High(Invoices) do
  begin
    Invoices[I].Id := I + 1;
    Invoices[I].CustomerId := (I mod 100) + 1;
    Invoices[I].NetAmount := 10.0 + (I * 0.5);
    Invoices[I].TaxRate := 0.20;
    Invoices[I].GrossAmount := 0.0;
    Invoices[I].TaxAmount := 0.0;
    FillChar(Invoices[I].ValidationHash, SizeOf(Invoices[I].ValidationHash), 0);
  end;
end;

function RunBenchmark(const LabelStr: string; Sealer: TSealerProc; const SourceInvoices: TInvoiceArray): TInvoiceArray;
var
  Invoices: TInvoiceArray;
  StartTime, EndTime: QWord;
begin
  WriteLn('>>> ', LabelStr);
  WriteLn('Copying array...');
  StartTime := GetTickCount64;

  SetLength(Invoices, Length(SourceInvoices));
  if Length(SourceInvoices) > 0 then
    Move(SourceInvoices[0], Invoices[0], Length(SourceInvoices) * SizeOf(TInvoice));

  EndTime := GetTickCount64;
  WriteLn('DONE. Took ', (EndTime - StartTime), ' ms.');

  WriteLn('Running...');
  StartTime := GetTickCount64;

  Sealer(Invoices);

  EndTime := GetTickCount64;
  WriteLn('DONE. Took ', (EndTime - StartTime), ' ms.');
  WriteLn('--------------------------------------------------');
  WriteLn;

  Result := Invoices;
end;

function VerifyResults(const Res1, Res2, Res3, Res4: TInvoiceArray): Boolean;
var
  I: Integer;
begin
  Result := True;
  if (Length(Res1) <> Length(Res2)) or (Length(Res1) <> Length(Res3)) or (Length(Res1) <> Length(Res4)) then
  begin
    WriteLn('Verification failed: Array lengths do not match!');
    Exit(False);
  end;

  for I := 0 to High(Res1) do
  begin
    if not CompareMem(@Res1[I], @Res2[I], SizeOf(TInvoice)) then
    begin
      WriteLn('Mismatch between Pascal Pure and Pascal OpenSSL at index ', I);
      Exit(False);
    end;
    if not CompareMem(@Res1[I], @Res3[I], SizeOf(TInvoice)) then
    begin
      WriteLn('Mismatch between Pascal Pure and Rust Single-Thread at index ', I);
      Exit(False);
    end;
    if not CompareMem(@Res1[I], @Res4[I], SizeOf(TInvoice)) then
    begin
      WriteLn('Mismatch between Pascal Pure and Rust Multi-Thread at index ', I);
      Exit(False);
    end;
  end;
end;

var
  Count: Integer;
  MasterInvoices: TInvoiceArray;
  PascalResults: TInvoiceArray;
  OpenSSLResults: TInvoiceArray;
  RustSingleResults: TInvoiceArray;
  RustMultiResults: TInvoiceArray;
  StartTime, EndTime: QWord;
  IsValid: Boolean;
begin
  Count := DEFAULT_INVOICE_COUNT;
  if ParamCount >= 1 then
    Count := StrToIntDef(ParamStr(1), DEFAULT_INVOICE_COUNT);

  WriteLn('=== INVOICE SEALER BENCHMARK DEMO ===');
  WriteLn('Running with ', Count, ' invoices.');
  WriteLn;

  WriteLn('Populating...');
  StartTime := GetTickCount64;

  SetLength(MasterInvoices, Count);
  PopulateInvoices(MasterInvoices);

  EndTime := GetTickCount64;
  WriteLn('DONE. Took ', (EndTime - StartTime), ' ms.');
  WriteLn;

  PascalResults := RunBenchmark('Pascal Sealer (Single Thread)', @ProcessInvoicesPascal, MasterInvoices);

  OpenSSLResults := RunBenchmark('Pascal Sealer (Single Thread - OpenSSL)', @ProcessInvoicesOpenSSL, MasterInvoices);

  RustSingleResults := RunBenchmark('Rust Sealer (Single Thread)', @ProcessInvoicesSingle, MasterInvoices);

  RustMultiResults := RunBenchmark('Rust Sealer (Multi Thread)', @ProcessInvoices, MasterInvoices);

  WriteLn('Verifying...');
  StartTime := GetTickCount64;

  IsValid := VerifyResults(PascalResults, OpenSSLResults, RustSingleResults, RustMultiResults);

  EndTime := GetTickCount64;
  WriteLn('DONE. Took ', (EndTime - StartTime), ' ms.');

  if not IsValid then
  begin
    WriteLn('VERIFICATION FAILED.');
    Halt(1);
  end;

  WriteLn('VERIFICATION SUCCESS.');
  WriteLn;
  WriteLn('Sample Sealed Invoices:');
  WriteLn('First Invoice:');
  PrintInvoice(PascalResults[0]);
  WriteLn;
  WriteLn('Last Invoice:');
  PrintInvoice(PascalResults[High(PascalResults)]);
  WriteLn;
end.
