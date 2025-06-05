{
  Copyright (c) 2025, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/ddabapps/bogbat
}

unit BogBat.AppInfo;

interface

type

  TAppInfo = record
  strict private
    class function ProgramPath: string; static; inline;
  public
    class function ProgramExeDate: string; static;
    class function ProgramVersion: string; static;
  end;

implementation

uses
  System.SysUtils,
  Winapi.Windows;

{ TAppInfo }

class function TAppInfo.ProgramExeDate: string;
begin
  const InternationalDateFmtStr = 'yyyy"-"mm"-"dd';
  var FileDate: TDateTime;
  if FileAge(ProgramPath, FileDate) then
    // Use international date format
    Result := FormatDateTime(InternationalDateFmtStr, FileDate)
  else
    Result := '';
end;

class function TAppInfo.ProgramPath: string;
begin
  Result := ParamStr(0);
end;

class function TAppInfo.ProgramVersion: string;
begin
  Result := '';
  // Get fixed file info from program's version info
  // get size of version info
  var Dummy: DWORD;
  var VerInfoSize := GetFileVersionInfoSize(PChar(ProgramPath), Dummy);
  if VerInfoSize = 0 then
    Exit;

  // create buffer and read version info into it
  var VerInfoBuf: Pointer;
  GetMem(VerInfoBuf, VerInfoSize);
  try
    if not GetFileVersionInfo(
      PChar(ProgramPath), Dummy, VerInfoSize, VerInfoBuf
    ) then
      Exit;
    var PBuf: Pointer;
    var Len: Cardinal;
    const SubBlock = '\StringFileInfo\0809FDE9\ProductVersion';
    if not VerQueryValue(VerInfoBuf, PChar(SubBlock), PBuf, Len) then
      Exit;
    Result := PChar(PBuf);
  finally
    FreeMem(VerInfoBuf);
  end;
end;

end.

