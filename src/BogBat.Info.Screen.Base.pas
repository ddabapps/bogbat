{
  Copyright (c) 2025, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/ddabapps/bogbat
}

unit BogBat.Info.Screen.Base;

interface

uses
  BogBat.Info.Logger;

type

  TInfoScreen = class abstract
  strict private
    var
      fLogger: TLogger;
  strict protected
    type
      TLF = record
      public
        const Line = sLineBreak;
        const Para = sLineBreak + sLineBreak;
      end;
    property Logger: TLogger read fLogger;
  public
    procedure Display; virtual; abstract;
    constructor Create;
    destructor Destroy; override;
  end;

  TInfoScreenFactory = record
  public
    class function CreateHelpScreenInstance: TInfoScreen; static;
    class function CreateUsageScreenInstance: TInfoScreen; static;
    class function CreateVersionScreenInstance: TInfoScreen; static;
  end;

implementation

uses
  BogBat.Info.Screen.Help,
  BogBat.Info.Screen.Usage,
  BogBat.Info.Screen.Version;

{ TInfoScreenFactory }

class function TInfoScreenFactory.CreateHelpScreenInstance: TInfoScreen;
begin
  Result := THelpScreen.Create;
end;

class function TInfoScreenFactory.CreateUsageScreenInstance: TInfoScreen;
begin
  Result := TUsageScreen.Create;
end;

class function TInfoScreenFactory.CreateVersionScreenInstance: TInfoScreen;
begin
  Result := TVersionScreen.Create;
end;

{ TInfoScreen }

constructor TInfoScreen.Create;
begin
  inherited Create;
  fLogger := TLoggerFactory.CreateStdOutConsoleLogger
end;

destructor TInfoScreen.Destroy;
begin
  fLogger.Free;
  inherited;
end;

end.

