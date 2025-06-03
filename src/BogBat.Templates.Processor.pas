{
  Copyright (c) 2025, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/ddabapps/bogbat
}

unit BogBat.Templates.Processor;

interface

uses
  System.Generics.Collections,
  BogBat.IO.Base;

type

  TTemplaceProcessor = class
  strict private
    var
      fDataReader: TInputReader;
      fTemplateReader: TInputReader;
      fOutputWriter: TOutputWriter;
      fDataMap: TDictionary<string,string>;
    procedure ParseData;
    function ReplaceTemplates: string;
  public
    constructor Create(const ADataReader: TInputReader;
      const ATemplateReader: TInputReader; const AOutputWriter: TOutputWriter);
    destructor Destroy; override;
    procedure Process;
  end;

implementation

uses
  System.SysUtils,
  BogBat.Templates.DataParser,
  BogBat.Templates.Replacer;

{ TTemplaceProcessor }

constructor TTemplaceProcessor.Create(const ADataReader,
  ATemplateReader: TInputReader; const AOutputWriter: TOutputWriter);
begin
  inherited Create;
  fDataReader := ADataReader;
  fTemplateReader := ATemplateReader;
  fOutputWriter := AOutputWriter;
  fDataMap := TDictionary<string,string>.Create;
end;

destructor TTemplaceProcessor.Destroy;
begin
  fDataMap.Free;
  inherited;
end;

procedure TTemplaceProcessor.ParseData;
begin
  // Parse data file
  var DataParser := TDataParser.Create(fDataReader);
  try
    // if duplicate keys have been defined, we use the last occurrence
    for var Elem in DataParser.Parse do
      fDataMap.AddOrSetValue(Elem.Key, Elem.Value);
  finally
    DataParser.Free;
  end;
end;

procedure TTemplaceProcessor.Process;
begin
  ParseData;
  fOutputWriter.Write(ReplaceTemplates);
end;

function TTemplaceProcessor.ReplaceTemplates: string;
begin
  var TpltContent := fTemplateReader.Read;
  var Replacer := TTemplateReplacer.Create(TpltContent, fDataMap);
  try
    Result := Replacer.Replace;
  finally
    Replacer.Free;
  end;
end;

end.
