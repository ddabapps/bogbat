{
  Copyright (c) 2025, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/ddabapps/bogbat
}

unit BogBat.IO.Readers.FileSystem;

interface

uses
  System.SysUtils,
  System.Classes,
  BogBat.IO.Base;

type
  TFileSystemReader = class(TInputReader)
  strict private
    var
      fFileName: string;
      fEncoding: TEncoding;
    function StreamToBytes(const AStream: TStream): TBytes;
  public
    constructor Create(const AFileName: string; const AEncoding: TEncoding);
    function Read: string; override;
  end;

implementation

{ TFileSystemReader }

constructor TFileSystemReader.Create(const AFileName: string;
  const AEncoding: TEncoding);
begin
  inherited Create;
  fFileName := AFileName;
  fEncoding := AEncoding;
end;

function TFileSystemReader.Read: string;
begin
  var FS := TFileStream.Create(fFileName, fmOpenRead or fmShareDenyWrite);
  try
    Result := BytesToString(StreamToBytes(FS), fEncoding);
  finally
    FS.Free;
  end;
end;

function TFileSystemReader.StreamToBytes(const AStream: TStream): TBytes;
begin
  SetLength(Result, AStream.Size);
  if AStream.Size > 0 then
    AStream.ReadData(Result, AStream.Size);
end;

end.

