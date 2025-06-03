{
  Copyright (c) 2025, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/ddabapps/bogbat
}

program BogBat;

{$IF not Defined(MSWINDOWS)}
{$MESSAGE FATAL 'Can only be compiled as a Windows program'}
{$ENDIF}

{$APPTYPE CONSOLE}

{$Resource *.res}

uses
  System.SysUtils,
  BogBat.AppInfo in 'BogBat.AppInfo.pas',
  BogBat.Errors in 'BogBat.Errors.pas',
  BogBat.Info.Logger in 'BogBat.Info.Logger.pas',
  BogBat.Info.Screen.Base in 'BogBat.Info.Screen.Base.pas',
  BogBat.Info.Screen.Help in 'BogBat.Info.Screen.Help.pas',
  BogBat.Info.Screen.Usage in 'BogBat.Info.Screen.Usage.pas',
  BogBat.Info.Screen.Version in 'BogBat.Info.Screen.Version.pas',
  BogBat.IO.Base in 'BogBat.IO.Base.pas',
  BogBat.IO.Readers.Console in 'BogBat.IO.Readers.Console.pas',
  BogBat.IO.Readers.FileSystem in 'BogBat.IO.Readers.FileSystem.pas',
  BogBat.IO.Writers.Console in 'BogBat.IO.Writers.Console.pas',
  BogBat.IO.Writers.FileSystem in 'BogBat.IO.Writers.FileSystem.pas',
  BogBat.Main in 'BogBat.Main.pas',
  BogBat.Params in 'BogBat.Params.pas',
  BogBat.Templates.DataParser in 'BogBat.Templates.DataParser.pas',
  BogBat.Templates.Processor in 'BogBat.Templates.Processor.pas',
  BogBat.Templates.Replacer in 'BogBat.Templates.Replacer.pas';

begin

  {$IF Defined(DEBUG)}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}

  try

    // Run main body of program
    TMain.Run;

    // User must press enter to close the program when running a debug build
    // under Delphi debugger
    {$IF Defined(DEBUG)}
    {$WARN SYMBOL_PLATFORM OFF}
    if DebugHook <> 0 then
    begin
      Writeln;
      Writeln('Press enter to end the program');
      Readln;
    end;
    {$WARN SYMBOL_PLATFORM ON}
    {$ENDIF}

  except

    // Catch any uncaught exceptions
    on E: Exception do
    begin
      Writeln('Uncaught exception:');
      Writeln(E.ClassName + ': ' + E.Message);
    end;
  end;

end.

