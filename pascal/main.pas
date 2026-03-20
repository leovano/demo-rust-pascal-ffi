program RustConcatTest;

uses LibRust;

var
  W: TRustString;
begin
  RustConcat('Hello ', 'from Rust!', W);

  WriteLn(W.ToUtf8String());
end.
