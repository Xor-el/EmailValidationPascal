#EmailValidationPascal#

A simple (but correct) Pascal class for validating email addresses.

Supports mail addresses as defined in rfc5322 as well as the new Internationalized Mail Address standards (rfc653x).

Ported from CSharp to Pascal using this Library [EmailValidation](https://github.com/jstedfast/EmailValidation)

**`Example`**

	uses
	    SysUtils, uEmailValidation;
	var
	  TestAddress : String;	
	begin
	  TestAddress := '_somename@example.com';
	 if TEmailValidator.Validate(TestAddress) then
	begin
	  WriteLn('Valid Email Address');
	  ReadLn;
	end
	else
	begin
	  WriteLn('Invalid Email Address')
	  ReadLn;
	end;
    end;

   > **`For International Addresses`**


    uses
	    SysUtils, uEmailValidation;
	var
	  TestAddress : String;
	begin
	  TestAddress := 'θσερ@εχαμπλε.ψομ';
	 if TEmailValidator.Validate(TestAddress, True) then
	begin
	  WriteLn('Valid Email Address');
	  ReadLn;
	end
	else
	begin
	  WriteLn('Invalid Email Address')
	  ReadLn;
	end;
    end;

**`Thanks`**
 
     Special thanks to Andreas Hausladen for suggesting I use static class
    functions.

**`ChangeLog`**

    25-07-2015
      Used static class functions as suggested by Andreas Hausladen 
     to prevent Instantiating an object for a single method call. 

    16-07-2015
    First Commit
