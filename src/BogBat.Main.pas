{
  Copyright (c) 2025, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/ddabapps/bogbat
}

unit BogBat.Main;

interface

uses
  System.SysUtils,
  BogBat.Params,
  BogBat.IO.Base,
  BogBat.Info.Logger,
  BogBat.Templates.Processor;

// TODO: Limit length of [output?] files to High(Int32) ???
type

  TMain = class
  strict private
    class var
      // TODO: Replace with logger class
      fErrorLogger: TLogger;
    class procedure Execute;
    class procedure DisplayUsage;
    class procedure DisplayHelp;
    class procedure DisplayVersion;
  public
    class procedure Run;
  end;

implementation

uses
  BogBat.Errors,
  BogBat.Info.Screen.Base;

{ TMain }

class procedure TMain.DisplayHelp;
begin
  var Help := TInfoScreenFactory.CreateHelpScreenInstance;
  try
    Help.Display;
  finally
    Help.Free;
  end;
end;

class procedure TMain.DisplayUsage;
begin
  var Usage := TInfoScreenFactory.CreateUsageScreenInstance;
  try
    Usage.Display;
  finally
    Usage.Free;
  end;
end;

class procedure TMain.DisplayVersion;
begin
  var Version := TInfoScreenFactory.CreateVersionScreenInstance;
  try
    Version.Display;
  finally
    Version.Free;
  end;
end;

class procedure TMain.Execute;
var
  TemplateReader: TInputReader;
  DataReader: TInputReader;
  OutputWriter: TOutputWriter;
begin
  Assert(TParams.DataInfo.IOType = TParams.TIOType.DiskFile);

  TemplateReader := nil;
  DataReader := nil;
  OutputWriter := nil;

  try
    DataReader := TReaderFactory.CreateFileSystemInstance(
      TParams.DataInfo.FileName, TParams.DataInfo.Encoding
    );
    case TParams.TemplateInfo.IOType of
      TParams.TIOType.Shell:
        TemplateReader := TReaderFactory.CreateConsoleStdInInstance(
          TParams.DataInfo.Encoding
        );
      TParams.TIOType.DiskFile:
        TemplateReader := TReaderFactory.CreateFileSystemInstance(
          TParams.TemplateInfo.FileName, TParams.DataInfo.Encoding
        );
    end;
    case TParams.OutputInfo.IOType of
      TParams.TIOType.Shell:
        OutputWriter := TWriterFactory.CreateConsoleStdOutInstance(
          TParams.OutputInfo.Encoding, TParams.OutputInfo.RequirePreamble
        );
      TParams.TIOType.DiskFile:
        OutputWriter := TWriterFactory.CreateFileSystemInstance(
          TParams.OutputInfo.FileName,
          TParams.OutputInfo.Encoding,
          TParams.OutputInfo.RequirePreamble
        );
    end;

    var Processor := TTemplaceProcessor.Create(
      DataReader, TemplateReader, OutputWriter
    );
    try
      Processor.Process;
    finally
      Processor.Free;
    end;

  finally
    OutputWriter.Free;
    DataReader.Free;
    TemplateReader.Free;
  end;

end;

class procedure TMain.Run;
begin
  fErrorLogger := TLoggerFactory.CreateStdErrConsoleLogger;
  try
    try
      TParams.Parse;
      case TParams.Mode of
        TParams.TMode.Normal:
          Execute;
        TParams.TMode.Usage:
          DisplayUsage;
        TParams.TMode.Help:
          DisplayHelp;
        TParams.TMode.Version:
          DisplayVersion;
      end;
      ExitCode := TExitCode.Success;
    except
      on E: Exception do
      begin
        fErrorLogger.WriteLn('ERROR: %s', [E.Message]);
        if E is EBogBat then
          ExitCode := (E as EBogBat).ExitCode
        else
          ExitCode := TExitCode.OtherError;
      end;
    end;
  finally
    fErrorLogger.Free;
  end;
end;

end.

