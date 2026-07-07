unit LibRust.Raw;

{$linklib gcc_s}
{$linklib gcc}

interface

procedure rust_concat(a: PByte; al: SizeInt; b: PByte; bl: SizeInt; target: PByte); cdecl; external 'rust_concat';

implementation
end.
