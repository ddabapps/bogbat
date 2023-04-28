program BogBat;

{$IF not Defined(MSWINDOWS)}
{$MESSAGE FATAL 'Can only be compiled as a Windows program'}
{$ENDIF}

{$APPTYPE CONSOLE}

{$Resource *.res}

uses
  System.SysUtils;

begin

  {$IF Defined(DEBUG)}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}

  try

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

