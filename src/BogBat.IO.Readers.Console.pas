{
  Copyright (c) 2025, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/ddabapps/bogbat
}

unit BogBat.IO.Readers.Console;

interface

uses
  System.SysUtils,
  BogBat.IO.Base;

type
  TConsoleStdInReader = class(TInputReader)
  strict private
    const
      ChunkSize = 1024 * 32;
    var
      fEncoding: TEncoding;
    function ReadBuf(var Buffer; const Count: Integer): Integer;
  public
    constructor Create(const AEncoding: TEncoding);
    function Read: string; override;
  end;

implementation

uses
  Winapi.Windows;

{ TConsoleStdInReader }

constructor TConsoleStdInReader.Create(const AEncoding: TEncoding);
begin
  inherited Create;
  fEncoding := AEncoding;
end;

function TConsoleStdInReader.Read: string;
var
  Buffer: TBytes;
  Data: TBytes;
  BytesRead: Cardinal;
  TotalBytes: Cardinal;
  Offset: Cardinal;
begin
  // read data from stdin to Data in chunks
  SetLength(Buffer, ChunkSize);
  TotalBytes := 0;
  repeat
    BytesRead := ReadBuf(Buffer[0], ChunkSize);
    if BytesRead = 0 then
      Break;
    Offset := TotalBytes;
    Inc(TotalBytes, BytesRead);
    SetLength(Data, TotalBytes);
    Move(Buffer[0], Data[Offset], BytesRead);
  until False;
  // convert to string, detecting encoding
  SetLength(Result, 1);
  Result := BytesToString(Data, fEncoding);
end;

function TConsoleStdInReader.ReadBuf(var Buffer; const Count: Integer): Integer;
var
  BytesRead: Cardinal;  // Number of bytes actually read
begin
  if Count = 0 then
  begin
    // No bytes required - nothing to do
    Result := 0;
    Exit;
  end;
  // Read from std input into buffer
  ReadFile(
    GetStdHandle(STD_INPUT_HANDLE), Buffer, Count, BytesRead, nil
  );
  Result := BytesRead;
end;

end.

