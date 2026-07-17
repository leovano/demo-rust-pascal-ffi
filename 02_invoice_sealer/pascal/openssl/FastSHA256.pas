unit FastSHA256;

{$mode objfpc}{$H+}{$inline on}
{$linklib crypto}

interface

type
  TSHA256Context = record
    Data: array[0..255] of Byte;
  end;
  TSHA256Digest = array[0..31] of Byte;

procedure SHA256Init(var Ctx: TSHA256Context);
procedure SHA256Update(var Ctx: TSHA256Context; const Msg; Len: QWord);
procedure SHA256Final(var Ctx: TSHA256Context; out Digest: TSHA256Digest);

implementation

const
  LIBCRYPTO = 'crypto';

function SHA256_Init(var c: TSHA256Context): Integer; cdecl; external LIBCRYPTO;
function SHA256_Update(var c: TSHA256Context; const data: Pointer; len: SizeUInt): Integer; cdecl; external LIBCRYPTO;
function SHA256_Final(md: Pointer; var c: TSHA256Context): Integer; cdecl; external LIBCRYPTO;

procedure SHA256Init(var Ctx: TSHA256Context);
begin
  SHA256_Init(Ctx);
end;

procedure SHA256Update(var Ctx: TSHA256Context; const Msg; Len: QWord);
begin
  if Len > 0 then
    SHA256_Update(Ctx, @Msg, Len);
end;

procedure SHA256Final(var Ctx: TSHA256Context; out Digest: TSHA256Digest);
begin
  SHA256_Final(@Digest[0], Ctx);
end;

end.
