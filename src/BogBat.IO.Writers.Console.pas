{
  Copyright (c) 2025, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/ddabapps/bogbat
}

unit BogBat.IO.Writers.Console;

{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils,
  BogBat.IO.Base;

type
  TConsoleWriter = class abstract(TOutputWriter)
  strict private
    var
      fEncoding: TEncoding;
      fWantPreamble: Boolean;
    procedure WriteToConsole(const AData: TBytes);
  strict protected
    function GetOutputDeviceID: Cardinal; virtual; abstract;
  public
    constructor Create(const AEncoding: TEncoding;
      const AWantPreamble: Boolean);
    procedure Write(const AContent: string); override;
  end;

  TConsoleStdOutWriter = class(TConsoleWriter)
  strict protected
    function GetOutputDeviceID: Cardinal; override;
  end;

  TConsoleStdErrWriter = class(TConsoleWriter)
  strict protected
    function GetOutputDeviceID: Cardinal; override;
  end;

implementation

uses
  Winapi.Windows;

{ TConsoleWriter }

constructor TConsoleWriter.Create(const AEncoding: TEncoding;
  const AWantPreamble: Boolean);
begin
  inherited Create;
  fEncoding := AEncoding;
  fWantPreamble := AWantPreamble;
end;

procedure TConsoleWriter.Write(const AContent: string);
begin
  // TODO: write in chunks to avoid size limit on WriteFile ??
  var Data := StringToBytes(AContent, fEncoding, fWantPreamble);
  WriteToConsole(Data);
end;

procedure TConsoleWriter.WriteToConsole(const AData: TBytes);
begin
  var Unused: Cardinal;    // receives number of bytes written (unused)
  WriteFile(
    GetStdHandle(GetOutputDeviceID),
    AData[0],
    Cardinal(Length(AData)),
    Unused,
    nil
  );
end;

{ TConsoleStdOutWriter }

function TConsoleStdOutWriter.GetOutputDeviceID: Cardinal;
begin
  Result := STD_OUTPUT_HANDLE;
end;

{ TConsoleStdErrWriter }

function TConsoleStdErrWriter.GetOutputDeviceID: Cardinal;
begin
  Result := STD_ERROR_HANDLE;
end;

end.

