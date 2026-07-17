unit SHA256;

{$mode objfpc}{$H+}{$inline on}

interface

type
  TSHA256Context = record
    State: array[0..7] of LongWord;
    Count: QWord;
    Buffer: array[0..63] of Byte;
  end;
  TSHA256Digest = array[0..31] of Byte;

procedure SHA256Init(var Ctx: TSHA256Context);
procedure SHA256Update(var Ctx: TSHA256Context; const Msg; Len: QWord);
procedure SHA256Final(var Ctx: TSHA256Context; out Digest: TSHA256Digest);

implementation

const
  K: array[0..63] of LongWord = (
    $428a2f98, $71374491, $b5c0fbcf, $e9b5dba5, $3956c25b, $59f111f1, $923f82a4, $ab1c5ed5,
    $d807aa98, $12835b01, $243185be, $550c7dc3, $72be5d74, $80deb1fe, $9bdc06a7, $c19bf174,
    $e49b69c1, $efbe4786, $0fc19dc6, $240ca1cc, $2de92c6f, $4a7484aa, $5cb0a9dc, $76f988da,
    $983e5152, $a831c66d, $b00327c8, $bf597fc7, $c6e00bf3, $d5a79147, $06ca6351, $14292967,
    $27b70a85, $2e1b2138, $4d2c6dfc, $53380d13, $650a7354, $766a0abb, $81c2c92e, $92722c85,
    $a2bfe8a1, $a81a664b, $c24b8b70, $c76c51a3, $d192e819, $d6990624, $f40e3585, $106aa070,
    $19a4c116, $1e376c08, $2748774c, $34b0bcb5, $391c0cb3, $4ed8aa4a, $5b9cca4f, $682e6ff3,
    $748f82ee, $78a5636f, $84c87814, $8cc70208, $90befffa, $a4506ceb, $bef9a3f7, $c67178f2
  );

procedure SHA256Init(var Ctx: TSHA256Context);
begin
  Ctx.State[0] := $6a09e667;
  Ctx.State[1] := $bb67ae85;
  Ctx.State[2] := $3c6ef372;
  Ctx.State[3] := $a54ff53a;
  Ctx.State[4] := $510e527f;
  Ctx.State[5] := $9b05688c;
  Ctx.State[6] := $1f83d9ab;
  Ctx.State[7] := $5be0cd19;
  Ctx.Count := 0;
  FillChar(Ctx.Buffer, SizeOf(Ctx.Buffer), 0);
end;

procedure SHA256Compress(var Ctx: TSHA256Context; Block: PByte);
var
  W: array[0..63] of LongWord;
  A, B, C, D, E, F, G, H: LongWord;
  I: Integer;
  S0, S1, Ch, Maj, Temp1, Temp2: LongWord;
  P: PLongWord;
begin
  P := PLongWord(Block);
  for I := 0 to 15 do
  begin
    W[I] := BEtoN(P[I]);
  end;

  for I := 16 to 63 do
  begin
    S0 := RorDword(W[I-15], 7) xor RorDword(W[I-15], 18) xor (W[I-15] shr 3);
    S1 := RorDword(W[I-2], 17) xor RorDword(W[I-2], 19) xor (W[I-2] shr 10);
    W[I] := S1 + W[I-7] + S0 + W[I-16];
  end;

  A := Ctx.State[0];
  B := Ctx.State[1];
  C := Ctx.State[2];
  D := Ctx.State[3];
  E := Ctx.State[4];
  F := Ctx.State[5];
  G := Ctx.State[6];
  H := Ctx.State[7];

  for I := 0 to 63 do
  begin
    S1 := RorDword(E, 6) xor RorDword(E, 11) xor RorDword(E, 25);
    Ch := (E and F) xor ((not E) and G);
    Temp1 := H + S1 + Ch + K[I] + W[I];

    S0 := RorDword(A, 2) xor RorDword(A, 13) xor RorDword(A, 22);
    Maj := (A and B) xor (A and C) xor (B and C);
    Temp2 := S0 + Maj;

    H := G;
    G := F;
    F := E;
    E := D + Temp1;
    D := C;
    C := B;
    B := A;
    A := Temp1 + Temp2;
  end;

  Ctx.State[0] += A;
  Ctx.State[1] += B;
  Ctx.State[2] += C;
  Ctx.State[3] += D;
  Ctx.State[4] += E;
  Ctx.State[5] += F;
  Ctx.State[6] += G;
  Ctx.State[7] += H;
end;

procedure SHA256Update(var Ctx: TSHA256Context; const Msg; Len: QWord);
var
  P: PByte;
  Left, Filled: QWord;
begin
  if Len = 0 then Exit;
  P := PByte(@Msg);
  Left := (Ctx.Count div 8) and 63;
  Ctx.Count += Len * 8;

  if Left > 0 then
  begin
    Filled := 64 - Left;
    if Len < Filled then
    begin
      Move(P^, Ctx.Buffer[Left], Len);
      Exit;
    end;
    Move(P^, Ctx.Buffer[Left], Filled);
    SHA256Compress(Ctx, @Ctx.Buffer[0]);
    P += Filled;
    Len -= Filled;
  end;

  while Len >= 64 do
  begin
    SHA256Compress(Ctx, P);
    P += 64;
    Len -= 64;
  end;

  if Len > 0 then
  begin
    Move(P^, Ctx.Buffer[0], Len);
  end;
end;

procedure SHA256Final(var Ctx: TSHA256Context; out Digest: TSHA256Digest);
var
  Bits: QWord;
  BitsBE: array[0..7] of Byte;
  PadLen: Integer;
  Left: Integer;
  I: Integer;
  Pad: array[0..63] of Byte;
begin
  Bits := Ctx.Count;
  for I := 0 to 7 do
  begin
    BitsBE[I] := Byte(Bits >> ((7 - I) * 8));
  end;

  Left := (Bits div 8) and 63;
  if Left < 56 then
    PadLen := 56 - Left
  else
    PadLen := 120 - Left;

  FillChar(Pad, SizeOf(Pad), 0);
  Pad[0] := $80;
  SHA256Update(Ctx, Pad, PadLen);
  SHA256Update(Ctx, BitsBE, 8);

  for I := 0 to 7 do
  begin
    Digest[I * 4 + 0] := Byte(Ctx.State[I] >> 24);
    Digest[I * 4 + 1] := Byte(Ctx.State[I] >> 16);
    Digest[I * 4 + 2] := Byte(Ctx.State[I] >> 8);
    Digest[I * 4 + 3] := Byte(Ctx.State[I]);
  end;
end;

end.
