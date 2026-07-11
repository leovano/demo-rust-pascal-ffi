unit LibRust;

{$mode objfpc}{$H+}

interface

procedure RustConcat(const S1, S2: Utf8String; out Target: Utf8String);

implementation

uses LibRust.Raw;

procedure RustConcat(const S1, S2: Utf8String; out Target: Utf8String);
begin
  SetLength(Target, Length(S1) + Length(S2));
  if Length(Target) > 0 then
    rust_concat(PByte(S1), Length(S1), PByte(S2), Length(S2), PByte(Target));
end;

end.
