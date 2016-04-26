unit uEmailValidationZeroBased;

interface

uses
  System.SysUtils, System.Character;

type
  /// <summary>
  /// An Email validator.
  /// </summary>
  /// <remarks>
  /// An Email validator.
  /// </remarks>
  TEmailValidator = class
  strict private

  class var
  const
    atomCharacters: String = '!#$%&''*+-/=?^_`{|}~';

    class function IsLetterOrDigit(C: Char): Boolean; static;
    class function IsAtom(C: Char; allowInternational: Boolean)
      : Boolean; static;
    class function IsDomain(C: Char; allowInternational: Boolean)
      : Boolean; static;
    class function SkipAtom(const Text: String; var Index: Integer;
      allowInternational: Boolean): Boolean; static;
    class function SkipSubDomain(const Text: String; var Index: Integer;
      allowInternational: Boolean): Boolean; static;
    class function SkipDomain(const Text: String; var Index: Integer;
      allowInternational: Boolean): Boolean; static;
    class function SkipQuoted(const Text: String; var Index: Integer;
      allowInternational: Boolean): Boolean; static;
    class function SkipWord(const Text: String; var Index: Integer;
      allowInternational: Boolean): Boolean; static;
    class function SkipIPv4Literal(const Text: String; var Index: Integer)
      : Boolean; static;
    class function IsHexDigit(C: Char): Boolean; static;
    class function SkipIPv6Literal(const Text: String; var Index: Integer)
      : Boolean; static;

  public

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

    class function Validate(const Email: String; allowInternational: Boolean = False)
      : Boolean; static;

  end;

implementation

class function TEmailValidator.IsLetterOrDigit(C: Char): Boolean;
begin

  Result := ((C >= 'A') and (C <= 'Z')) or ((C >= 'a') and (C <= 'z')) or
    ((C >= '0') and (C <= '9'));
end;

class function TEmailValidator.IsAtom(C: Char;
  allowInternational: Boolean): Boolean;

begin
  if Ord(C) < 128 then
    Result := ((IsLetterOrDigit(C)) or (atomCharacters.IndexOf(C) <> -1))
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

class function TEmailValidator.SkipAtom(const Text: String; var Index: Integer;
  allowInternational: Boolean): Boolean;
var
  startIndex: Integer;

begin
  startIndex := Index;
  while ((Index < Text.Length) and (IsAtom(Text.Chars[Index],
    allowInternational))) do
  begin
    Inc(Index);
  end;
  Result := Index > startIndex;
end;

class function TEmailValidator.SkipSubDomain(const Text: String; var Index: Integer;
  allowInternational: Boolean): Boolean;
var
  startIndex: Integer;

begin
  startIndex := Index;
  if ((not IsDomain(Text.Chars[Index], allowInternational)) or
    ((Text.Chars[Index]) = '-')) then
  begin
    Result := False;
    Exit;
  end;
  Inc(Index);
  while ((Index < Text.Length) and IsDomain(Text.Chars[Index],
    allowInternational)) do
  begin
    Inc(Index);
  end;
  Result := ((Index - startIndex) < 64) and (Text.Chars[Index - 1] <> '-');
end;

class function TEmailValidator.SkipDomain(const Text: String; var Index: Integer;
  allowInternational: Boolean): Boolean;

begin

  if (not SkipSubDomain(Text, Index, allowInternational)) then
  begin
    Result := False;
    Exit;
  end;
  while ((Index < Text.Length) and ((Text.Chars[Index]) = '.')) do
  begin
    Inc(Index);
    if (Index = Text.Length) then
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

class function TEmailValidator.SkipQuoted(const Text: String; var Index: Integer;
  allowInternational: Boolean): Boolean;
var
  Escaped: Boolean;

begin
  Escaped := False;
  // skip over leading '"'
  Inc(Index);
  while (Index < Text.Length) do
  begin
    if (Ord(Text.Chars[Index]) >= 128) and (not allowInternational) then
    begin
      Result := False;
      Exit;
    end;
    if ((Text.Chars[Index]) = '\') then
    begin
      Escaped := not Escaped;
    end

    else if (not Escaped) then
    begin
      if ((Text.Chars[Index]) = '"') then
        Break;
    end
    else
    begin
      Escaped := False;
    end;
    Inc(Index);
  end;

  if ((Index >= Text.Length) or ((Text.Chars[Index]) <> '"')) then
  begin
    Result := False;
    Exit;
  end;

  Inc(Index);

  Result := True;

end;

class function TEmailValidator.SkipWord(const Text: String; var Index: Integer;
  allowInternational: Boolean): Boolean;

begin
  if ((Text.Chars[Index]) = '"') then
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

class function TEmailValidator.SkipIPv4Literal(const Text: String;
  var Index: Integer): Boolean;
var
  Groups, startIndex, Value: Integer;

begin
  Groups := 0;
  while ((Index < Text.Length) and (Groups < 4)) do
  begin
    startIndex := Index;
    Value := 0;
    while ((Index < Text.Length) and ((Text.Chars[Index]) >= '0') and
      ((Text.Chars[Index]) <= '9')) do
    begin
      Value := (Value * 10) + Ord(Text.Chars[Index]) - Ord('0');
      Inc(Index);

    end;

    if ((Index = startIndex) or (Index - startIndex > 3) or (Value > 255)) then
    begin
      Result := False;
      Exit;
    end;

    Inc(Groups);
    if ((Groups < 4) and (Index < Text.Length) and ((Text.Chars[Index]) = '.'))
    then
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

class function TEmailValidator.SkipIPv6Literal(const Text: String;
  var Index: Integer): Boolean;
var
  Compact: Boolean;
  Colons, startIndex, Count: Integer;
begin
  Compact := False;
  Colons := 0;
  while (Index < Text.Length) do
  begin
    startIndex := Index;
    while ((Index < Text.Length) and (IsHexDigit(Text.Chars[Index]))) do
    begin
      Inc(Index);
    end;
    if (Index >= Text.Length) then
      Break;

    if (((Index > startIndex) and (Colons > 2) and (Text.Chars[Index] = '.')))
    then
    begin
      // IPv6v4
      Index := startIndex;

      if (not SkipIPv4Literal(Text, Index)) then
      begin
        Result := False;
        Exit;
      end;

      if Compact then
      begin
        Result := Colons < 6;
        Exit;
      end
      else
      begin
        Result := Colons = 6;
        Exit;

      end;
    end;

    Count := Index - startIndex;
    if (Count > 4) then
    begin
      Result := False;
      Exit;
    end;

    if (Text.Chars[Index] <> ':') then
      Break;

    startIndex := Index;
    while ((Index < Text.Length) and (Text.Chars[Index] = ':')) do
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
    Result := Colons < 7;
    Exit;
  end
  else
  begin
    Result := Colons = 7;
    Exit;
  end;

end;

class function TEmailValidator.Validate(const Email: String;
  allowInternational: Boolean = False): Boolean;
var
  Index: Integer;
  ipv6: String;
begin
  Index := 0;
  if (Email = '') then
    raise EArgumentNilException.Create('Email');
  if ((Email.Length = 0) or (Email.Length >= 255)) then
  begin
    Result := False;
    Exit;
  end;

  if ((not SkipWord(Email, Index, allowInternational)) or
    (Index >= Email.Length)) then
  begin
    Result := False;
    Exit;
  end;

  while (Email.Chars[Index] = '.') do
  begin
    Inc(Index);

    if (Index >= Email.Length) then
    begin
      Result := False;
      Exit;
    end;

    if (not SkipWord(Email, Index, allowInternational)) then
    begin
      Result := False;
      Exit;
    end;

    if (Index >= Email.Length) then
    begin
      Result := False;
      Exit;
    end;
  end;

  if ((Index + 1 >= Email.Length) or (Index > 64) or (Email.Chars[Index] <> '@'))
  then
  begin
    Result := False;
    Exit;
  end;
  Inc(Index);

  if (Email.Chars[Index] <> '[') then
  begin
    // domain
    if (not SkipDomain(Email, Index, allowInternational)) then
    begin
      Result := False;
      Exit;
    end;

    Result := Index = Email.Length;
    Exit;
  end;
  // address literal
  Inc(Index);
  // we need at least 8 more characters
  if (Index + 8 >= Email.Length) then
  begin
    Result := False;
    Exit;
  end;

  ipv6 := Email.Substring(Index, 5);

  if (ipv6.ToLowerInvariant = 'ipv6:') then
  begin
    Index := Index + 'IPv6:'.Length;
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

  if ((Index >= Email.Length) or (Email.Chars[Index] <> ']')) then
  begin

    Result := False;
    Exit;
  end;
  Inc(Index);
  Result := Index = Email.Length;

end;

end.
