{
  Copyright (c) 2025, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/ddabapps/bogbat
}

unit BogBat.Info.Logger;

interface

uses
  BogBat.IO.Base;

type
  TLogger = class abstract
  strict protected
    procedure DoWrite(const AStr: string); virtual; abstract;
  public
    procedure Write(const AStr: string); overload;
    procedure Write(const AFmtStr: string; const AArgs: array of const);
      overload;
    procedure WriteLn; overload;
    procedure WriteLn(const AStr: string); overload;
    procedure WriteLn(const AFmtStr: string; const AArgs: array of const);
      overload;
  end;

  TLoggerFactory = record
  public
    class function CreateStdErrConsoleLogger: TLogger; static;
    class function CreateStdOutConsoleLogger: TLogger; static;
  end;

implementation

uses
  System.SysUtils;

type
  TConsoleLogger = class abstract(TLogger)
  strict private
    var
      fWriter: TOutputWriter;
  strict protected
    function CreateWriter: TOutputWriter; virtual; abstract;
    procedure DoWrite(const AStr: string); override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TStdOutConsoleLogger = class sealed(TConsoleLogger)
  strict protected
    function CreateWriter: TOutputWriter; override;
  end;

  TStdErrConsoleLogger = class sealed(TConsoleLogger)
  strict protected
    function CreateWriter: TOutputWriter; override;
  end;

{ TLogger }

procedure TLogger.Write(const AStr: string);
begin
  DoWrite(AStr);
end;

procedure TLogger.Write(const AFmtStr: string; const AArgs: array of const);
begin
  DoWrite(Format(AFmtStr, AArgs));
end;

procedure TLogger.WriteLn;
begin
  DoWrite(sLineBreak);
end;

procedure TLogger.WriteLn(const AStr: string);
begin
  DoWrite(AStr + sLineBreak);
end;

procedure TLogger.WriteLn(const AFmtStr: string; const AArgs: array of const);
begin
  DoWrite(Format(AFmtStr, AArgs) + sLineBreak);
end;

{ TConsoleLogger }

constructor TConsoleLogger.Create;
begin
  inherited;
  fWriter := CreateWriter;
end;

destructor TConsoleLogger.Destroy;
begin
  fWriter.Free;
  inherited;
end;

procedure TConsoleLogger.DoWrite(const AStr: string);
begin
  fWriter.Write(AStr);
end;

{ TStdOutConsoleLogger }

function TStdOutConsoleLogger.CreateWriter: TOutputWriter;
begin
  Result := TWriterFactory.CreateConsoleStdOutInstance(TEncoding.UTF8, False);
end;

{ TStdErrConsoleLogger }

function TStdErrConsoleLogger.CreateWriter: TOutputWriter;
begin
  Result := TWriterFactory.CreateConsoleStdErrInstance(TEncoding.UTF8, False);
end;

{ TLoggerFactory }

class function TLoggerFactory.CreateStdErrConsoleLogger: TLogger;
begin
  Result := TStdErrConsoleLogger.Create;
end;

class function TLoggerFactory.CreateStdOutConsoleLogger: TLogger;
begin
  Result := TStdOutConsoleLogger.Create;
end;

end.

