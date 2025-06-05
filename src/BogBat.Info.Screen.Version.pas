{
  Copyright (c) 2025, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/ddabapps/bogbat
}

unit BogBat.Info.Screen.Version;

interface

uses
  BogBat.Info.Screen.Base;

type

  TVersionScreen = class sealed(TInfoScreen)
  public
    procedure Display; override;
  end;

implementation

uses
  BogBat.AppInfo;

{ TVersionScreen }

procedure TVersionScreen.Display;
begin
  Logger.WriteLn('*** WARNING: No version information resource available');
  Logger.WriteLn('%s %s ', [TAppInfo.ProgramVersion, TAppInfo.ProgramExeDate]);
end;

end.

