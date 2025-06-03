{
  Copyright (c) 2025, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/ddabapps/bogbat
}

unit BogBat.Params;

{$SCOPEDENUMS ON}

{ TODO: Set input/output encoding default when reading/writing console to
        console's current encoding using GetConsoleOutputCP and
        SetConsoleOutputCP.
}

interface

uses
  System.Types,
  System.SysUtils,
  System.Generics.Collections;

type
  TParams = class
  public
    type
      TMode = (
        Normal,       // normal operation: process template files
        Usage,        // display brief usage info and exit
        Help,         // display help screen and exit
        Version       // display version info and exit
      );

      TIOType = (
        Shell,        // Data read / written via shell redirection
        DiskFile      // Data read from / written to physical file
      );

      TIOInfo = record
      strict private
        procedure DisposeEncoding;
        procedure SetEncoding(const AEncoding: TEncoding);
        var
          fIOType: TIOType;           // type of IO (shell or file)
          fFileName: string;          // ignored if IOType <> DiskFile
          fEncoding: TEncoding;       // ignored if input file has preamble
          fRequirePreamble: Boolean;  // ignored for input files
                                      // or if IOType = Shell
      public
        class operator Initialize(out Dest: TIOInfo);
        class operator Finalize(var Dest: TIOInfo);
        class operator Assign(var Dest: TIOInfo; const [ref] Src: TIOInfo);
        property IOType: TIOType
          read fIOType write fIOType; // default TIOType.Shell
        property FileName: string
          read fFileName write fFileName; // default ''
        // NOTE: Encoding property OWNs any encoding instance it is set to and
        // will free it as required
        property Encoding: TEncoding
          read fEncoding write SetEncoding; // default TEncoding.UTF8
        property RequirePreamble: Boolean
          read fRequirePreamble write fRequirePreamble; // default False
      end;

      TDelimiters = record
      strict private
        fOpener: string;
        fCloser: string;
      public
        property Opener: string read fOpener;
        property Closer: string read fCloser;
        constructor Create(const AOpener, ACloser: string);
      end;
  strict private
    type
      TOption = (
        DataFile,
        TemplateFile,
        OutputFile,
        DataEncoding,
        TemplateEncoding,
        OutputEncoding,
        AllEncoding,
        OutputPreamble,
        Delimiters,
        Version,
        Help
      );

      TOptionInfo = record
        ID: TOption;
        Name: string;
        Value: string;
        constructor Create(AID: TOption; AName, AValue: string);
      end;

    const
      MustacheDelimiters: TDelimiters = (fOpener: '{{'; fCloser: '}}');
      DjangoDelimiters: TDelimiters = (fOpener: '{%'; fCloser: '%}');
      ASPDelimiters: TDelimiters = (fOpener: '<%'; fCloser: '%>');
      PHP2Delimiters: TDelimiters = (fOpener: '<?'; fCloser: '?>');
      HTMLDelimiters: TDelimiters = (fOpener: '<!--'; fCloser: '-->');
      PerlDelimiters: TDelimiters = (fOpener: '<?'; fCloser: '!>');
      SmartyDelimiters: TDelimiters = (fOpener: '{$'; fCloser: '}');

      OptionsList: array[TOption] of TStringDynArray = (
        // DataFile
        ['-d', '/d', '--data'],
        // TemplateFile
        ['-t', '/t', '--template'],
        // OutputFile
        ['-o', '/o', '--output'],
        // DataEncoding
        ['--data-encoding'],
        // TemplateEncoding
        ['--template-encoding'],
        // OutputEncoding
        ['--output-encoding'],
        // AllEncoding
        ['--encoding'],
        // OutputPreamble
        ['--output-preamble'],
        // Delimiters
        ['-l', '/l', '--delimiters'],
        // Version
        ['-V', '/V', '--version'],
        // Help
        ['-?', '/?', '--help']
      );
    class var
      fDataInfo: TIOInfo;
      fTemplateInfo: TIOInfo;
      fOutputInfo: TIOInfo;
      fMode: TMode;
      fDelimiters: TDelimiters;
    ///  <summary>Checks if string <c>AStr</c> is contained in string array
    ///  <c>AArr</c>, ignoring case.</summary>
    class function IsStrInArray(const AStr: string; const AArr: array of string;
      const AIgnoreCase: Boolean): Boolean;
    class function ParseEncodingValue(const AInfo: TOptionInfo): TEncoding;
    class function ParseDelimeterValue(const AInfo: TOptionInfo): TDelimiters;
    class function IsLongOption(const AOpt: string): Boolean;
    class function IsShortOption(const AOpt: string): Boolean;
    class function MakeDiskFileInfo(const AInfo: TOptionInfo;
      const IsInput: Boolean): TIOInfo;
    class function ParseOptionParam(const AParam: string): TOptionInfo;
    class function SplitParam(const AParam: string): TPair<string,string>;
    class function SplitLongOptionParam(const AParam: string):
      TPair<string,string>;
    class function SplitShortOptionParam(const AParam: string):
      TPair<string,string>;
    class function LookupOption(const AOptStr: string): TOption;
    class procedure CheckParamterlessOption(const AInfo: TOptionInfo);
    // Validate all params: call after command line processed
    class procedure Validate;
  public
    class constructor Create;
    class procedure Parse;
    // DataInfo must have IOType=TIOType.DiskFile and non-empty file name
    class property DataInfo: TIOInfo read fDataInfo;
    class property TemplateInfo: TIOInfo read fTemplateInfo;
    class property OutputInfo: TIOInfo read fOutputInfo;
    class property Mode: TMode read fMode;
    class property Delimiters: TDelimiters read fDelimiters;
  end;

implementation

uses
  System.Classes,
  System.Character,
  System.StrUtils,
  System.IOUtils,
  BogBat.Errors;

{ TParams }

class procedure TParams.CheckParamterlessOption(const AInfo: TOptionInfo);
begin
  if not AInfo.Value.IsEmpty then
    raise EParams.CreateFmt('%s: No value permitted', [AInfo.Name]);
end;

class constructor TParams.Create;
begin
  fDataInfo.IOType := TIOType.DiskFile;
  fMode := TMode.Normal;
  fDelimiters := MustacheDelimiters;
end;

class function TParams.IsLongOption(const AOpt: string): Boolean;
begin
  Result := (AOpt.Length >= 3) and (AOpt[1] = '-') and (AOpt[2] = '-');
end;

class function TParams.IsShortOption(const AOpt: string): Boolean;
begin
  Result := (AOpt.Length >=2)
    and (
      ((AOpt[1] = '-') and (AOpt[2] <> '-'))
      or
      ((AOpt[1] = '/') and (AOpt[2] <> '/'))
    );
end;

class function TParams.IsStrInArray(const AStr: string;
  const AArr: array of string; const AIgnoreCase: Boolean): Boolean;
begin
  Result := False;
  for var Item in AArr do
    if string.Compare(Item, AStr, AIgnoreCase) = 0 then
      Exit(True);
end;

class function TParams.LookupOption(const AOptStr: string): TOption;
begin
  for var Option := Low(OptionsList) to High(OptionsList) do
    if IsStrInArray(AOptStr, OptionsList[Option], False) then
      Exit(Option);
  raise EParams.CreateFmt('%s: Unrecognised option', [AOptStr]);
end;

class function TParams.MakeDiskFileInfo(const AInfo: TOptionInfo;
  const IsInput: Boolean): TIOInfo;
begin
  Result.IOType := TIOType.DiskFile;
  Result.Filename := AInfo.Value;
  if Result.FileName.IsEmpty then
    raise EParams.CreateFmt('%s: Valid file name required', [AInfo.Name]);
  if IsInput and not TFile.Exists(Result.FileName) then
    raise EParams.CreateFmt(
      '%0:s: Input file "%1:s" does not exist', [AInfo.Name, Result.FileName]
    );
end;

class procedure TParams.Parse;
begin
  if ParamCount = 0 then
    fMode := TMode.Usage
  else
  begin
    fMode := TMode.Normal;
    for var Idx := 1 to ParamCount do
    begin
      var Param := ParamStr(Idx);
      var OptionInfo := ParseOptionParam(Param);

      case OptionInfo.ID of
        TOption.DataFile:
          fDataInfo := MakeDiskFileInfo(OptionInfo, True);
        TOption.TemplateFile:
          fTemplateInfo := MakeDiskFileInfo(OptionInfo, True);
        TOption.OutputFile:
          fOutputInfo := MakeDiskFileInfo(OptionInfo, False);
        TOption.DataEncoding:
          fDataInfo.Encoding := ParseEncodingValue(OptionInfo);
        TOption.TemplateEncoding:
          fTemplateInfo.Encoding := ParseEncodingValue(OptionInfo);
        TOption.OutputEncoding:
          fOutputInfo.Encoding := ParseEncodingValue(OptionInfo);
        TOption.AllEncoding:
        begin
          fDataInfo.Encoding := ParseEncodingValue(OptionInfo);
          fTemplateInfo.Encoding := ParseEncodingValue(OptionInfo);
          fOutputInfo.Encoding := ParseEncodingValue(OptionInfo);
        end;
        TOption.OutputPreamble:
        begin
          CheckParamterlessOption(OptionInfo);
          fOutputInfo.RequirePreamble := True;
        end;
        TOption.Delimiters:
          fDelimiters := ParseDelimeterValue(OptionInfo);
        TOption.Version:
        begin
          CheckParamterlessOption(OptionInfo);
          fMode := TMode.Version;
          Break;
        end;
        TOption.Help:
        begin
          CheckParamterlessOption(OptionInfo);
          fMode := TMode.Help;
          Break;
        end;
      end;
    end;
    Validate;

  end;
end;

class function TParams.ParseDelimeterValue(
  const AInfo: TOptionInfo): TDelimiters;
begin
  // Option value must be in format <opener> <separator-text-or-space> <closer>
  // <opener> and <closer> must be punctuation or symbols OR value must be a
  // predefined string.
  // Any character that is special on command line or is a space must be quoted,
  // e.g. --delimiters="<|x&>" or -l:{{" "}} or -l"<"text">"
  if AInfo.Value.IsEmpty then
    raise EParams.CreateFmt('%s: Delimiters parameter expected', [AInfo.Name]);

  if IsStrInArray(AInfo.Value, ['moustache', 'mustache'], True) then
    Exit(MustacheDelimiters);
  if string.Compare(AInfo.Value, 'django', True) = 0 then
    Exit(DjangoDelimiters);
  if string.Compare(AInfo.Value, 'asp', True) = 0 then
    Exit(ASPDelimiters);
  if IsStrInArray(AInfo.Value, ['php', 'php2'], True) then
    Exit(PHP2Delimiters);
  if string.Compare(AInfo.Value, 'html', True) = 0 then
    Exit(HTMLDelimiters);
  if string.Compare(AInfo.Value, 'perl', True) = 0 then
    Exit(PerlDelimiters);
  if string.Compare(AInfo.Value, 'smarty', True) = 0 then
    Exit(SmartyDelimiters);

  var OpenerIdx: Integer := 1;
  while (OpenerIdx <= AInfo.Value.Length)
    and (AInfo.Value[OpenerIdx].IsPunctuation
    or AInfo.Value[OpenerIdx].IsSymbol) do
    Inc(OpenerIdx);
  if OpenerIdx = 1 then
    raise EParams.CreateFmt(
      '%0:s: "%1:s" is not a valid delimiters parameter',
      [AInfo.Name, AInfo.Value]
    );
  var Opener := AInfo.Value.Substring(0, OpenerIdx - 1);
  var CloserIdx: Integer := OpenerIdx;
  while (CloserIdx <= AInfo.Value.Length)
    and not (
      AInfo.Value[CloserIdx].IsPunctuation or AInfo.Value[CloserIdx].IsSymbol
    ) do
    Inc(CloserIdx);
  if CloserIdx > AInfo.Value.Length then
    raise EParams.CreateFmt(
      '%0:s: "%1:s" is not a valid delimiters parameter',
      [AInfo.Name, AInfo.Value]
    );
  var Closer := AInfo.Value.Substring(CloserIdx - 1);
  for var Ch in Closer do
    if not (Ch.IsPunctuation or Ch.IsSymbol) then
      raise EParams.CreateFmt(
        '%0:s: "%1:s" is not a valid delimiters parameter',
        [AInfo.Name, AInfo.Value]
      );
  Result := TDelimiters.Create(Opener, Closer);
end;

class function TParams.ParseEncodingValue(const AInfo: TOptionInfo): TEncoding;
begin
  // Encoding value is case sensitive
  if AInfo.Value.IsEmpty then
    raise EParams.CreateFmt('%s: Encoding parameter expected', [AInfo.Name]);
  var CodePage: Integer;
  if Integer.TryParse(AInfo.Value, CodePage) then
    Result := TMBCSEncoding.Create(CodePage)
  else if IsStrInArray(AInfo.Value, ['utf-8', 'utf8'], True) then
    Result := TEncoding.UTF8
  else if IsStrInArray(
    AInfo.Value, ['utf-16', 'utf16', 'utf-16-le', 'utf16le'], True
  ) then
    Result := TEncoding.Unicode
  else if IsStrInArray(AInfo.Value, ['utf-16-be', 'utf16be'], True) then
    Result := TEncoding.BigEndianUnicode
  else if (string.Compare('ascii', AInfo.Value) = 0) then
    Result := TEncoding.ASCII
  else if IsStrInArray(
    AInfo.Value, ['os-default', 'osdefault', 'acp', '0'], true
  ) then
    Result := TEncoding.Default
  else
    raise EParams.CreateFmt(
      '%0:s: "%1:s" is not a valid encoding parameter',
      [AInfo.Name, AInfo.Value]
    );
end;

class function TParams.ParseOptionParam(const AParam: string): TOptionInfo;
begin
  var KVPair := SplitParam(AParam);
  if KVPair.Key.IsEmpty then
    raise EParams.CreateFmt('Badly formed parameter: "%s"', [AParam]);
  Result := TOptionInfo.Create(
    LookupOption(KVPair.Key), KVPair.Key, KVPair.Value
  );
end;

class function TParams.SplitLongOptionParam(
  const AParam: string): TPair<string, string>;
begin
  Assert(AParam.Length >= 2);
  if AParam.Length = 2 then
    raise EParams.CreateFmt('Invalid option: "%s"', [AParam]);
  var EqualPos := AParam.IndexOf('=');
  if EqualPos < 0 then
    Result := TPair<string,string>.Create(AParam, '')
  else
  begin
    if EqualPos = 0 then
      raise EParams.CreateFmt('Invalid option format: "%s"', [AParam]);
    Result := TPair<string,string>.Create(
      AParam.Substring(0, EqualPos),
      AParam.SubString(EqualPos + 1)
    );
  end;
end;

class function TParams.SplitParam(const AParam: string): TPair<string, string>;
begin
  if IsLongOption(AParam) then
    Result := SplitLongOptionParam(AParam)
  else if IsShortOption(AParam) then
    Result := SplitShortOptionParam(AParam)
  else
    raise EParams.CreateFmt('Unrecognised option type: "%s"', [AParam]);
end;

class function TParams.SplitShortOptionParam(
  const AParam: string): TPair<string, string>;
begin
  Assert(AParam.Length >= 1);
  if AParam.Length = 1 then
    raise EParams.CreateFmt('Invalid option: "%s"', [AParam]);
  if (AParam.Length >= 3) and CharInSet(AParam[3], [':', '=']) then
  begin
    // we have param in form -x:value or /x=value etc.
    if AParam.Length = 3 then
      // can't have -x: or -x= as an option: text must follow : or =
      raise EParams.CreateFmt('Invalid option format: "%s"', [AParam]);
    Result := TPair<string,string>.Create(
      AParam.Substring(0, 2), AParam.Substring(3)
    );
  end
  else
  begin
    // we have param in form -xvalue or /xvalue
    if Length(AParam) = 2 then
      Result := TPair<string,string>.Create(AParam, '')
    else
      Result := TPair<string,string>.Create(
        AParam.Substring(0, 2), AParam.Substring(2)
      );
  end;
end;

class procedure TParams.Validate;

  procedure CheckForDuplicateFileName(AIOInfo: TIOInfo;
    AFileNames: TStringList);
  begin
    if AIOInfo.IOType <> TIOType.DiskFile then
      Exit;
    if AFileNames.IndexOf(AIOInfo.FileName) >= 0 then
      raise EParams.Create('All file names must be unique');
    AFileNames.Add(AIOInfo.FileName);
  end;

begin
  case fMode of
    TMode.Normal:
    begin
      // Data file must be specified
      Assert(fDataInfo.IOType = TIOType.DiskFile);
      if fDataInfo.FileName.IsEmpty then
        raise EParams.Create('A data file name must be specified');

      // All file names must be unique
      var FileNames := TStringList.Create;
      try
        FileNames.Add(fDataInfo.FileName);
        CheckForDuplicateFileName(fOutputInfo, FileNames);
        CheckForDuplicateFileName(fTemplateInfo, FileNames);
      finally
        FileNames.Free;
      end;
    end;
    TMode.Usage:
      {no checks required};
    TMode.Help:
      if ParamCount <> 1 then
        raise EParams.Create(
          '-? / --help option must not be mixed with other options'
        );
    TMode.Version:
      if ParamCount <> 1 then
        raise EParams.Create(
          '-V / --version option must not be mixed with other options'
        );
  end;
end;

{ TParams.TIOInfo }

class operator TParams.TIOInfo.Assign(var Dest: TIOInfo;
  const [ref] Src: TIOInfo);
begin
  Dest.fIOType := Src.fIOType;
  Dest.fFileName := Src.fFileName;
  if TEncoding.IsStandardEncoding(Src.fEncoding) then
    Dest.SetEncoding(Src.fEncoding)
  else
    Dest.SetEncoding(TMBCSEncoding.Create(Src.fEncoding.CodePage));
  Dest.fRequirePreamble := Src.fRequirePreamble;
end;

procedure TParams.TIOInfo.DisposeEncoding;
begin
  if TEncoding.IsStandardEncoding(fEncoding) then
    fEncoding := nil
  else
    FreeAndNil(fEncoding);
end;

class operator TParams.TIOInfo.Finalize(var Dest: TIOInfo);
begin
  Dest.DisposeEncoding;
end;

class operator TParams.TIOInfo.Initialize(out Dest: TIOInfo);
begin
  Dest.fIOType := TIOType.Shell;
  Dest.fFileName := '';
  Dest.fEncoding := TEncoding.UTF8;
  Dest.fRequirePreamble := False;
end;

procedure TParams.TIOInfo.SetEncoding(const AEncoding: TEncoding);
begin
  DisposeEncoding;
  fEncoding := AEncoding;
end;

{ TParams.TOptionInfo }

constructor TParams.TOptionInfo.Create(AID: TOption; AName, AValue: string);
begin
  ID := AID;
  Name := AName;
  Value := AValue;
end;

{ TParams.TDelimiters }

constructor TParams.TDelimiters.Create(const AOpener, ACloser: string);
begin
  fOpener := AOpener;
  fCloser := ACloser;
end;

end.

