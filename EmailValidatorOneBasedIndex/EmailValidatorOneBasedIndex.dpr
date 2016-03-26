program EmailValidatorOneBasedIndex;

uses
  Vcl.Forms,
  uEmailValidation in 'src\Main\uEmailValidation.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Run;
end.
