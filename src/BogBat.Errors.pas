{
  Copyright (c) 2025, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/ddabapps/bogbat
}

unit BogBat.Errors;

interface

uses
  System.SysUtils;

type

  TExitCode = record
  public
    const
      Success = 0;
      Parsing = 1;
      Usage = 2;
      OtherError = 9;
  end;

  EBogBat = class(Exception)
  strict private
    var
      fExitCode: Integer;
  strict protected
    procedure SetExitCode(const AExitCode: Integer);
  public
    property ExitCode: Integer read fExitCode;
  end;

  EParams = class(EBogBat)
  public
    procedure AfterConstruction; override;
  end;

  EParsing = class(EBogBat)
  public
    procedure AfterConstruction; override;
  end;

implementation

{ EBogBat }

procedure EBogBat.SetExitCode(const AExitCode: Integer);
begin
  fExitCode := AExitCode;
end;

{ EParams }

procedure EParams.AfterConstruction;
begin
  inherited;
  SetExitCode(TExitCode.Usage);
end;

{ EParsing }

procedure EParsing.AfterConstruction;
begin
  inherited;
  SetExitCode(TExitCode.Parsing);
end;

end.
