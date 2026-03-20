unit LibRust;

{$mode objfpc}{$H+}
{$modeswitch advancedrecords}

interface

type
  TRustString = record
  private
    FData: Pointer;
    FLen, FCap: SizeInt;
  public
    function ToUtf8String: Utf8String;
    class operator Finalize(var Dest: TRustString);
  end;

procedure RustConcat(const S1, S2: Utf8String; out Target: TRustString);

implementation

uses LibRust.Raw;

procedure RustConcat(const S1, S2: Utf8String; out Target: TRustString);
var
  Raw: TRawString;
begin
  Raw := rust_concat(PByte(S1), Length(S1), PByte(S2), Length(S2));

  Target.FData := Raw.Ptr;
  Target.FLen := Raw.Len;
  Target.FCap := Raw.Cap;
end;

class operator TRustString.Finalize(var Dest: TRustString);
var
  RawToFree: TRawString;
begin
  if Dest.FData <> nil then
  begin
    RawToFree.Ptr := Dest.FData;
    RawToFree.Len := Dest.FLen;
    RawToFree.Cap := Dest.FCap;

    rust_free_string(RawToFree);

    Dest.FData := nil;
  end;
end;

function TRustString.ToUtf8String: Utf8String;
begin
  Result := '';
  if FData <> nil then
    SetString(Result, PAnsiChar(FData), FLen);
end;

end.
