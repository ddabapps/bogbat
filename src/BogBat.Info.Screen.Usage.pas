{
  Copyright (c) 2025, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/ddabapps/bogbat
}

unit BogBat.Info.Screen.Usage;

interface

uses
  BogBat.Info.Screen.Base;

type

  TUsageScreen = class sealed(TInfoScreen)
    strict private
      const
        UsageText =
        '''
        Main usage:
          bogbat -d:data_file [-t:template_file] [-o:output_file] [options]

        To view version information enter:
          bogbat --version

        For help enter:
          bogbat --help
        ''';
  public
    procedure Display; override;
  end;

implementation

{ TUsageScreen }

procedure TUsageScreen.Display;
begin
  Logger.WriteLn(UsageText);
end;

end.

