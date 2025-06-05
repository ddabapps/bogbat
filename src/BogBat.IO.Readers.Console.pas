{
  Copyright (c) 2025, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/ddabapps/bogbat
}

unit BogBat.IO.Readers.Console;

{
   TODO: Set to use current console code page - use GetConsoleOutputCP
         OR set it to UTF8 using SetConsoleOutputCP
}

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
    function ReadStdInChunk: TBytes;
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
begin
  var Data: TBytes;
  SetLength(Data, 0);
  repeat
    var Chunk := ReadStdInChunk;
    Data := Concat(Data, Chunk);
  until False;
  Result := BytesToString(Data, fEncoding);
end;

function TConsoleStdInReader.ReadStdInChunk: TBytes;
begin
  SetLength(Result, ChunkSize);
  var BytesRead: Cardinal;
  ReadFile(
    GetStdHandle(STD_INPUT_HANDLE),
    Result[0],
    Cardinal(Length(Result)),
    BytesRead,
    nil
  );
  if BytesRead < Length(Result) then
    SetLength(Result, BytesRead);
end;

end.

