{
  Copyright (c) 2025, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/ddabapps/bogbat
}

unit BogBat.Templates.DataParser;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  BogBat.IO.Base;

type
  TDataParser = class
  strict private
    var
      fReader: TInputReader;
    const
      KVSeparator = '=';
      CommentStarter = '#';
  public
    constructor Create(const ADataReader: TInputReader);
    function Parse: TArray<TPair<string,string>>;
  end;

implementation

uses
  System.Classes,
  BogBat.Errors;

{ TDataParser }

constructor TDataParser.Create(const ADataReader: TInputReader);
begin
  inherited Create;
  fReader := ADataReader;
end;

function TDataParser.Parse: TArray<TPair<string, string>>;
begin
  var RawData := fReader.Read;
  var Lines := RawData.Split([sLineBreak]);

  // Use TStringList to parse lines, since it handles Key=Value strings for us
  var ParsedLines := TStringList.Create;
  try
    for var Line in Lines do
    begin
      var BareLine := Line.Trim;
      if BareLine.IsEmpty or BareLine.StartsWith(CommentStarter) then
        Continue;
      if BareLine.StartsWith(KVSeparator)
        or not BareLine.Contains(KVSeparator) then
        raise EParsing.CreateFmt(
          'Malformed line in data file:' + sLineBreak + '  "%s"', [Line]
        );
      ParsedLines.Add(BareLine);
    end;

    SetLength(Result, ParsedLines.Count);
    for var Idx := 0 to Pred(ParsedLines.Count) do
      Result[Idx] := TPair<string,string>.Create(
        ParsedLines.Names[Idx].Trim, ParsedLines.ValueFromIndex[Idx]
      );
  finally
    ParsedLines.Free;
  end;
end;

end.
