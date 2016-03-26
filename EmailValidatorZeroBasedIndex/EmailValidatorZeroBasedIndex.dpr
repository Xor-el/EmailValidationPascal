program EmailValidatorZeroBasedIndex;

uses
  Vcl.Forms,
  uEmailValidationZeroBased in 'src\Main\uEmailValidationZeroBased.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Run;
end.
