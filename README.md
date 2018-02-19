#EmailValidationPascal#

**This is a Port of [EmailValidation](https://github.com/jstedfast/EmailValidation) to Delphi/Pascal.**

A simple (but correct) Pascal class for validating email addresses.

Supports Internationalized Mail Address standards (rfc653x).


#### Building
This project was created using Delphi 10 Seattle Update 1. 
The (**`uEmailValidation.pas`**) unit should compile in any Delphi version from 2009 and FreePascal 2.6.4 Upwards.

if you are using XE3 Upwards and working with the **`Mobile`** compilers in which strings are Zero-Based by Default, Please use the (**`uEmailValidationZeroBased.pas`**) unit else any of the units you like.

* FreePascal Users and Delphi Users below XE3 can Only use the (**`uEmailValidation.pas`**) unit.

###Code Examples

```pascal
	uses
	    SysUtils, uEmailValidation;
	var
	  TestAddress : String;	
	begin
	  TestAddress := '_somename@example.com';
	  Validator := TEmailValidator.Create;
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
```

   > **`For International Addresses`**

```pascal
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
```

###Unit Tests

    Unit Tests can be found in EmailValidation.Test Folder.
    The unit tests makes use of DUnitX and TestInsight.

###License

This "Software" is Licensed Under  **`MIT License (MIT)`** .

#### Tip Jar
* :dollar: **Bitcoin**: `1MhFfW7tDuEHQSgie65uJcAfJgCNchGeKf`
* :euro: **Ethereum**: `0x6c1DC21aeC49A822A4f1E3bf07c623C2C1978a98`
* :pound: **Pascalcoin**: `345367-40`

###Conclusion


   Special Thanks to [Jeffrey Stedfast](https://github.com/jstedfast/) for [this](https://github.com/jstedfast/EmailValidation) awesome library.
(Thanks to the developers of [DUnitX Testing Framework](https://github.com/VSoftTechnologies/DUnitX/) and [TestInsight](https://bitbucket.org/sglienke/testinsight/wiki/Home/) for making tools that simplifies unit testing.