{
  Copyright (c) 2025, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/ddabapps/bogbat
}

unit BogBat.IO.Base;

interface

uses
  System.SysUtils;

type
  TInputReader = class abstract
  strict protected
    ///  <summary>Converts data in <c>ABytes</c> to a string. If data contains a
    ///  preamble then the encoding specified by the preamble is used to decode
    ///  the string data, otherwise <c>AEncoding</c> is used.</summary>
    function BytesToString(const ABytes: TBytes;
      const AEncoding: TEncoding): string;
  public
    function Read: string; virtual; abstract;
  end;

  { TODO: refactor TAbstractWriter to generate bytes to write then call
      protected abstract method to perform the write }
  TOutputWriter = class abstract
  strict protected
    function StringToBytes(const AContent: string; const AEncoding: TEncoding;
      const AWantPreamble: Boolean): TBytes;
  public
    procedure Write(const AContent: string); virtual; abstract;
  end;

  TReaderFactory = record
  public
    class function CreateConsoleStdInInstance(const AEncoding: TEncoding):
      TInputReader; static;
    class function CreateFileSystemInstance(const AFileName: string;
      const AEncoding: TEncoding): TInputReader; static;
  end;

  TWriterFactory = record
    class function CreateConsoleStdOutInstance(const AEncoding: TEncoding;
      const AWantPreamble: Boolean): TOutputWriter; static;
    class function CreateConsoleStdErrInstance(const AEncoding: TEncoding;
      const AWantPreamble: Boolean): TOutputWriter; static;
    class function CreateFileSystemInstance(const AFileName: string;
      const AEncoding: TEncoding; const AWantPreamble: Boolean): TOutputWriter;
      static;
  end;

implementation

uses
  BogBat.IO.Readers.Console,
  BogBat.IO.Writers.Console,
  BogBat.IO.Readers.FileSystem,
  BogBat.IO.Writers.FileSystem;

{ TInputReader }

function TInputReader.BytesToString(const ABytes: TBytes;
  const AEncoding: TEncoding): string;
begin
  var BufferEncoding: TEncoding := nil;
  var PreambleSize := TEncoding.GetBufferEncoding(ABytes, BufferEncoding);
  try
    var EncodingToUse: TEncoding;
    if PreambleSize > 0 then
      EncodingToUse := BufferEncoding
    else
      EncodingToUse := AEncoding;
    Result := EncodingToUse.GetString(
      ABytes, PreambleSize, Length(ABytes) - PreambleSize
    );
  finally
    if Assigned(BufferEncoding)
      and not TEncoding.IsStandardEncoding(BufferEncoding) then
      BufferEncoding.Free;
  end;
end;

{ TReaderFactory }

class function TReaderFactory.CreateConsoleStdInInstance(
  const AEncoding: TEncoding): TInputReader;
begin
  Result := TConsoleStdInReader.Create(AEncoding);
end;

class function TReaderFactory.CreateFileSystemInstance(
  const AFileName: string; const AEncoding: TEncoding): TInputReader;
begin
  Result := TFileSystemReader.Create(AFileName, AEncoding);
end;

{ TWriterFactory }

class function TWriterFactory.CreateConsoleStdErrInstance(
  const AEncoding: TEncoding; const AWantPreamble: Boolean): TOutputWriter;
begin
  Result := TConsoleStdErrWriter.Create(AEncoding, AWantPreamble);
end;

class function TWriterFactory.CreateConsoleStdOutInstance(
  const AEncoding: TEncoding; const AWantPreamble: Boolean): TOutputWriter;
begin
  Result := TConsoleStdOutWriter.Create(AEncoding, AWantPreamble);
end;

class function TWriterFactory.CreateFileSystemInstance(const AFileName: string;
  const AEncoding: TEncoding; const AWantPreamble: Boolean): TOutputWriter;
begin
  Result := TFileSystemWriter.Create(AFileName, AEncoding, AWantPreamble);
end;

{ TOutputWriter }

function TOutputWriter.StringToBytes(const AContent: string;
  const AEncoding: TEncoding; const AWantPreamble: Boolean): TBytes;
begin
  var Preamble: TBytes;
  if AWantPreamble then
    Preamble := AEncoding.GetPreamble
  else
    SetLength(Preamble, 0);
  if Length(Preamble) > 0 then
    Result := Concat(Preamble, AEncoding.GetBytes(AContent))
  else
    Result := AEncoding.GetBytes(AContent);
end;

end.

