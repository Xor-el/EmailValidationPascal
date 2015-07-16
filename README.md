#EmailValidationPascal#

A simple (but correct) Pascal class for validating email addresses.

Supports mail addresses as defined in rfc5322 as well as the new Internationalized Mail Address standards (rfc653x).

Ported from CSharp to Pascal using this Library [EmailValidation](https://github.com/jstedfast/EmailValidation)

**`Example`**

	uses
	    SysUtils, uEmailValidation;
	var
	  TestAddress : String;
	  Validator: TEmailValidator;
	
	begin
	  TestAddress := '_somename@example.com';
	  Validator := TEmailValidator.Create;
	try
	 if Validator.Validate(TestAddress) then
	begin
	  WriteLn('Valid Email Address');
	  ReadLn;
	end
	else
	begin
	  WriteLn('Invalid Email Address')
	  ReadLn;
	end;
	finally
	  Validator.Free;
	end;
    end;

   > **`For International Addresses`**


    uses
	    SysUtils, uEmailValidation;
	var
	  TestAddress : String;
	  Validator: TEmailValidator;
	
	begin
	  TestAddress := 'θσερ@εχαμπλε.ψομ';
	  Validator := TEmailValidator.Create;
	try
	 if Validator.Validate(TestAddress, True) then
	begin
	  WriteLn('Valid Email Address');
	  ReadLn;
	end
	else
	begin
	  WriteLn('Invalid Email Address')
	  ReadLn;
	end;
	finally
	  Validator.Free;
	end;
    end;