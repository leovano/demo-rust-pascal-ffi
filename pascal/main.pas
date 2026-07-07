program RustConcatTest;

uses LibRust;

var
  W1, W2, W3: Utf8String;
begin
  RustConcat('Hello ', 'from Rust!', W1);
  WriteLn('Normal concat: ', W1);

  W2 := W1;
  WriteLn('Copy: ', W2);

  RustConcat('', '', W3);
  WriteLn('Empty concat: "', W3, '"');
end.
