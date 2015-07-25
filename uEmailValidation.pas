unit uEmailValidation;

{
  Copyright (c) 2015 Ugochukwu Mmaduekwe ugo4brain@gmail.com

  This software is provided 'as-is', without any express or implied
  warranty. In no event will the authors be held liable for any damages
  arising from the use of this software.
  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
  claim that you wrote the original software. If you use this software
  in a product, an acknowledgment in the product documentation would be
  appreciated but is not required.

  2. Altered source versions must be plainly marked as such, and must not be
  misrepresented as being the original software.

  3. This notice may not be removed or altered from any source distribution.

  Special thanks to Andreas Hausladen for suggesting I use static class
  functions.

}

/// <summary>
/// An Email validator.
/// </summary>
/// <remarks>
/// An Email validator.
/// </remarks>

interface

uses
  SysUtils;

type
  TEmailValidator = class
  strict private

  class var
  const
    atomCharacters: String = '!#$%&''*+-/=?^_`{|}~';

    class function MyIndexOf(C: Char; InString: String): Integer; static;
    class function IsLetterOrDigit(C: Char): Boolean; static;
    class function IsAtom(C: Char; allowInternational: Boolean)
      : Boolean; static;
    class function IsDomain(C: Char; allowInternational: Boolean)
      : Boolean; static;
    class function SkipAtom(Text: String; var Index: Integer;
      allowInternational: Boolean): Boolean; static;
    class function SkipSubDomain(Text: String; var Index: Integer;
      allowInternational: Boolean): Boolean; static;
    class function SkipDomain(Text: String; var Index: Integer;
      allowInternational: Boolean): Boolean; static;
    class function SkipQuoted(Text: String; var Index: Integer;
      allowInternational: Boolean): Boolean; static;
    class function SkipWord(Text: String; var Index: Integer;
      allowInternational: Boolean): Boolean; static;
    class function SkipIPv4Literal(Text: String; var Index: Integer)
      : Boolean; static;
    class function IsHexDigit(C: Char): Boolean; static;
    class function SkipIPv6Literal(Text: String; var Index: Integer)
      : Boolean; static;

  public
    class function Validate(Email: String; allowInternational: Boolean = False)
      : Boolean; static;

  end;

implementation

class function TEmailValidator.MyIndexOf(C: Char; InString: String): Integer;

begin
  Result := Pos(C, InString) - 1;
end;

class function TEmailValidator.IsLetterOrDigit(C: Char): Boolean;
begin

  Result := ((C >= 'A') and (C <= 'Z')) or ((C >= 'a') and (C <= 'z')) or
    ((C >= '0') and (C <= '9'));
end;

class function TEmailValidator.IsAtom(C: Char;
  allowInternational: Boolean): Boolean;

begin
  if Ord(C) < 128 then
    Result := ((IsLetterOrDigit(C)) or (MyIndexOf(C, atomCharacters) <> -1))
  else
    Result := allowInternational;
end;

class function TEmailValidator.IsDomain(C: Char;
  allowInternational: Boolean): Boolean;

begin
  if Ord(C) < 128 then
    Result := (IsLetterOrDigit(C) or (C = '-'))
  else
    Result := allowInternational;
end;

class function TEmailValidator.SkipAtom(Text: String; var Index: Integer;
  allowInternational: Boolean): Boolean;
var
  startIndex: Integer;

begin
  startIndex := Index;
  while ((Index < Length(Text)) and (IsAtom(Text[Index],
    allowInternational))) do
  begin
    Inc(Index);
  end;
  Result := Index > startIndex;
end;

class function TEmailValidator.SkipSubDomain(Text: String; var Index: Integer;
  allowInternational: Boolean): Boolean;

begin
  if ((not IsDomain(Text[Index], allowInternational)) or ((Text[Index]) = '-'))
  then
  begin
    Result := False;
    Exit;
  end;
  Inc(Index);
  while ((Index < Length(Text)) and IsDomain(Text[Index],
    allowInternational)) do
  begin
    Inc(Index);
  end;
  Result := True;
end;

class function TEmailValidator.SkipDomain(Text: String; var Index: Integer;
  allowInternational: Boolean): Boolean;

begin

  if (not SkipSubDomain(Text, Index, allowInternational)) then
  begin
    Result := False;
    Exit;
  end;
  while ((Index < Length(Text)) and ((Text[Index]) = '.')) do
  begin
    Inc(Index);
    if (Index = Length(Text)) then
    begin
      Result := False;
      Exit;
    end;

    if (not SkipSubDomain(Text, Index, allowInternational)) then
    begin
      Result := False;
      Exit;
    end;

  end;

  Result := True;
end;

class function TEmailValidator.SkipQuoted(Text: String; var Index: Integer;
  allowInternational: Boolean): Boolean;
var
  Escaped: Boolean;

begin
  Escaped := False;
  // skip over leading '"'
  Inc(Index);
  while (Index < Length(Text)) do
  begin
    if (Ord(Text[Index]) >= 128) and (not allowInternational) then
    begin
      Result := False;
      Exit;
    end;
    if ((Text[Index]) = '\') then
    begin
      Escaped := not Escaped;
    end

    else if (not Escaped) then
    begin
      if ((Text[Index]) = '"') then
        Break;
    end
    else
    begin
      Escaped := False;
    end;
    Inc(Index);
  end;

  if ((Index >= Length(Text)) or ((Text[Index]) <> '"')) then
  begin
    Result := False;
    Exit;
  end;

  Inc(Index);

  Result := True;

end;

class function TEmailValidator.SkipWord(Text: String; var Index: Integer;
  allowInternational: Boolean): Boolean;

begin
  if ((Text[Index]) = '"') then
  begin
    Result := SkipQuoted(Text, Index, allowInternational);
    Exit;
  end
  else
  begin
    Result := SkipAtom(Text, Index, allowInternational);
    Exit;
  end;
end;

class function TEmailValidator.SkipIPv4Literal(Text: String;
  var Index: Integer): Boolean;
var
  Groups, startIndex, Value: Integer;

begin
  Groups := 0;
  while ((Index < Length(Text)) and (Groups < 4)) do
  begin
    startIndex := Index;
    Value := 0;
    while ((Index < Length(Text)) and ((Text[Index]) >= '0') and
      ((Text[Index]) <= '9')) do
    begin
      Value := (Value * 10) + Ord(Text[Index]) - Ord('0');
      Inc(Index);

    end;

    if ((Index = startIndex) or (Index - startIndex > 3) or (Value > 255)) then
    begin
      Result := False;
      Exit;
    end;

    Inc(Groups);
    if ((Groups < 4) and (Index < Length(Text)) and ((Text[Index]) = '.')) then
      Inc(Index);
  end;
  Result := Groups = 4;
end;

class function TEmailValidator.IsHexDigit(C: Char): Boolean;
begin

  Result := ((C >= 'A') and (C <= 'F')) or ((C >= 'a') and (C <= 'f')) or
    ((C >= '0') and (C <= '9'));

end;

// This needs to handle the following forms:
//
// IPv6-addr = IPv6-full / IPv6-comp / IPv6v4-full / IPv6v4-comp
// IPv6-hex  = 1*4HEXDIG
// IPv6-full = IPv6-hex 7(":" IPv6-hex)
// IPv6-comp = [IPv6-hex *5(":" IPv6-hex)] "::" [IPv6-hex *5(":" IPv6-hex)]
// ; The "::" represents at least 2 16-bit groups of zeros
// ; No more than 6 groups in addition to the "::" may be
// ; present
// IPv6v4-full = IPv6-hex 5(":" IPv6-hex) ":" IPv4-address-literal
// IPv6v4-comp = [IPv6-hex *3(":" IPv6-hex)] "::"
// [IPv6-hex *3(":" IPv6-hex) ":"] IPv4-address-literal
// ; The "::" represents at least 2 16-bit groups of zeros
// ; No more than 4 groups in addition to the "::" and
// ; IPv4-address-literal may be present

class function TEmailValidator.SkipIPv6Literal(Text: String;
  var Index: Integer): Boolean;
var
  Compact: Boolean;
  Colons, startIndex, Count: Integer;
begin
  Compact := False;
  Colons := 0;
  while (Index < Length(Text)) do
  begin
    startIndex := Index;
    while ((Index < Length(Text)) and (IsHexDigit(Text[Index]))) do
    begin
      Inc(Index);

    end;
    if (Index >= Length(Text)) then
      Break;

    if (((Index > startIndex) and (Colons > 2) and (Text[Index] = '.'))) then
    begin
      // IPv6v4
      Index := startIndex;

      if (not SkipIPv4Literal(Text, Index)) then
      begin
        Result := False;
        Exit;
      end;

      Break;
    end;

    Count := Index - startIndex;
    if (Count > 4) then
    begin
      Result := False;
      Exit;
    end;

    if (Text[Index] <> ':') then
      Break;

    startIndex := Index;
    while ((Index < Length(Text)) and (Text[Index] = ':')) do
    begin
      Inc(Index);
    end;
    Count := Index - startIndex;
    if (Count > 2) then
    begin
      Result := False;
      Exit;
    end;

    if (Count = 2) then
    begin
      if (Compact) then
      begin
        Result := False;
        Exit;
      end;
      Compact := True;
      Colons := Colons + 2;
    end
    else
    begin
      Inc(Colons);
    end;

  end;

  if (Colons < 2) then
  begin
    Result := False;
    Exit;
  end;

  if (Compact) then
  begin
    Result := Colons < 6;
    Exit;
  end;

  Result := Colons < 7;

end;

/// <summary>
/// Validate the specified email address.
/// </summary>
/// <remarks>
/// <para>Validates the syntax of an email address.</para>
/// <para>If <paramref name="allowInternational"/> is <value>true</value>, then the validator
/// will use the newer International Email standards for validating the email address.</para>
/// </remarks>
/// <returns><c>true</c> if the email address is valid; otherwise <c>false</c>.</returns>
/// <param name="Email">An email address.</param>
/// <param name="allowInternational"><value>true</value> if the validator should allow international characters; otherwise, <value>false</value>.</param>
/// <exception cref="System.SysUtils.EArgumentNilException">
/// <paramref name="Email"/> is <c>Empty</c>.
/// </exception>

class function TEmailValidator.Validate(Email: String;
  allowInternational: Boolean = False): Boolean;
var
  Index, PrevIndex: Integer;
  ipv6: String;
begin
  Index := 0;
  if (Email = '') then
    raise EArgumentNilException.Create('Email');
  if (Length(Email) = 0) then
  begin
    Result := False;
    Exit;
  end;
  Inc(Index);
  if ((not SkipWord(Email, Index, allowInternational)) or
    (Index >= Length(Email))) then
  begin
    Result := False;
    Exit;
  end;

  while (Email[Index] = '.') do
  begin
    Inc(Index);

    if (Index >= Length(Email)) then
    begin
      Result := False;
      Exit;
    end;

    if (not SkipWord(Email, Index, allowInternational)) then
    begin
      Result := False;
      Exit;
    end;

    if (Index >= Length(Email)) then
    begin
      Result := False;
      Exit;
    end;
  end;

  if ((Index >= Length(Email)) or (Email[Index] <> '@')) then
  begin
    Result := False;
    Exit;
  end;

  Inc(Index);
  if (Email[Index] <> '[') then
  begin
    // domain
    if (not SkipDomain(Email, Index, allowInternational)) then
    begin
      Result := False;
      Exit;
    end;

    Result := Index = Length(Email);
    Exit;
  end;
  // address literal
  Inc(Index);
  // we need at least 8 more characters
  if (Index + 8 >= Length(Email)) then
  begin
    Result := False;
    Exit;
  end;

  ipv6 := Copy(Email, Index, 5);

  if (AnsiLowerCase(ipv6) = 'ipv6:') then
  begin
    Index := Index + Length('IPv6:');
    if (not SkipIPv6Literal(Email, Index)) then
    begin
      Result := False;
      Exit;
    end;
  end
  else
  begin
    if (not SkipIPv4Literal(Email, Index)) then
    begin
      Result := False;
      Exit;
    end;
  end;
  PrevIndex := Index - 1;

  if ((PrevIndex >= Length(Email)) or (Email[Index] <> ']')) then
  begin
    Result := False;
    Exit;
  end;

  Result := Index = Length(Email);

end;

end.
