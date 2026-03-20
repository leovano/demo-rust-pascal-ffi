unit LibRust.Raw;

{$linklib gcc_s}
{$linklib gcc}

interface

type
  TRawString = record
    Ptr: PByte;
    Len: SizeInt;
    Cap: SizeInt;
  end;

function rust_concat(a: PByte; al: SizeInt; b: PByte; bl: SizeInt): TRawString; cdecl; external 'rust_concat';
procedure rust_free_string(raw: TRawString); cdecl; external 'rust_concat';

implementation
end.
