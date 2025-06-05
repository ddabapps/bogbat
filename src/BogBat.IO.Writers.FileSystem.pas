{
  Copyright (c) 2025, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/ddabapps/bogbat
}

unit BogBat.IO.Writers.FileSystem;

interface

uses
  System.SysUtils,
  BogBat.IO.Base;

type
  TFileSystemWriter = class(TOutputWriter)
  strict private
    var
      fFileName: string;
      fEncoding: TEncoding;
      fWantPreamble: Boolean;
  public
    constructor Create(const AFileName: string; const AEncoding: TEncoding;
      const AWantPreamble: Boolean);
    procedure Write(const AContent: string); override;
  end;

implementation

uses
  System.Classes;

{ TFileSystemWriter }

constructor TFileSystemWriter.Create(const AFileName: string;
  const AEncoding: TEncoding; const AWantPreamble: Boolean);
begin
  inherited Create;
  fFileName := AFileName;
  fEncoding := AEncoding;
  fWantPreamble := AWantPreamble;
end;

procedure TFileSystemWriter.Write(const AContent: string);
begin
  var FS := TFileStream.Create(fFileName, fmCreate);
  try
    var Data := StringToBytes(AContent, fEncoding, fWantPreamble);
    FS.WriteData(Data, Length(Data));
  finally
    FS.Free;
  end;
end;

end.

