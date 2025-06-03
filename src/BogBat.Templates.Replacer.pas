{
  Copyright (c) 2025, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/ddabapps/bogbat
}

unit BogBat.Templates.Replacer;

interface

uses
  System.SysUtils,
  System.Generics.Collections;

type
  TTemplateReplacer = class
  strict private
    var
      fInputText: string;
      fDataMap: TDictionary<string,string>;

      // NOTE: AStartIdx in zero based
      function TryNextTpltStartIdx(var AStartIdx: Integer): Boolean;
      function ExtractTpltFrom(const AStartIdx: Integer): string;
      function ExtractDataNameFromTplt(const ATemplate: string): string;
      function GetDataValue(const ADataName: string): string;
  public
    constructor Create(const AInputText: string;
      const ADataMap: TDictionary<string,string>);
    function Replace: string;
  end;

implementation

uses
  BogBat.Params;

{ TTemplateReplacer }

constructor TTemplateReplacer.Create(const AInputText: string;
  const ADataMap: TDictionary<string, string>);
begin
  inherited Create;
  fInputText := AInputText;
  fDataMap := ADataMap;
end;

function TTemplateReplacer.ExtractDataNameFromTplt(
  const ATemplate: string): string;
begin
  var ContentStartIdx := TParams.Delimiters.Opener.Length;
  var ContentLength := ATemplate.Length - TParams.Delimiters.Opener.Length
    - TParams.Delimiters.Closer.Length;
  Result := ATemplate.Substring(ContentStartIdx, ContentLength).Trim;
end;

function TTemplateReplacer.ExtractTpltFrom(const AStartIdx: Integer): string;
begin
  Assert(fInputText.Substring(
    AStartIdx, TParams.Delimiters.Opener.Length) = TParams.Delimiters.Opener
  );

  var EndIdx := fInputText.IndexOf(TParams.Delimiters.Closer, AStartIdx);
  if EndIdx < 0 then
    Exit('');
  var Len := EndIdx + TParams.Delimiters.Closer.Length - AStartIdx;
  Result := fInputText.Substring(AStartIdx, Len);
end;

function TTemplateReplacer.GetDataValue(const ADataName: string): string;
begin
  if not fDataMap.TryGetValue(ADataName, Result) then
    Result := '';
end;

function TTemplateReplacer.Replace: string;
begin
  var Builder := TStringBuilder.Create;
  try
    var NextTpltIdx: Integer := 0;
    var PlainTextStartIdx: Integer := NextTpltIdx;

    while TryNextTpltStartIdx(NextTpltIdx) do
    begin
      if PlainTextStartIdx < NextTpltIdx then
        Builder.Append(
          fInputText.Substring(
            PlainTextStartIdx, NextTpltIdx - PlainTextStartIdx
          )
        );
      // TODO -cRefactor: simplify following function call chain
      var Template := ExtractTpltFrom(NextTpltIdx);
      var DataName := ExtractDataNameFromTplt(Template);
      var DataValue := GetDataValue(DataName);
      Builder.Append(DataValue);
      Inc(NextTpltIdx, Template.Length);
      PlainTextStartIdx := NextTpltIdx;
    end;

    if PlainTextStartIdx > NextTpltIdx then
      Builder.Append(fInputText.Substring(PlainTextStartIdx));

    Result := Builder.ToString;

  finally
    Builder.Free;
  end;
end;

function TTemplateReplacer.TryNextTpltStartIdx(var AStartIdx: Integer): Boolean;
begin
  AStartIdx := fInputText.IndexOf(TParams.Delimiters.Opener, AStartIdx);
  Result := AStartIdx >= 0;
end;

end.
