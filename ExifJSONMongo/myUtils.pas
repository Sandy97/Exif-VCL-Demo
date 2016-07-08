unit myUtils;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes,
  Vcl.Graphics;

type
  DRVTYPECONST = DRIVE_UNKNOWN..DRIVE_RAMDISK;
const
  drvseeking: set of DRVTYPECONST = [
    DRIVE_UNKNOWN,      // = 0;
    DRIVE_NO_ROOT_DIR,  // = 1;
    DRIVE_REMOVABLE,    // = 2;
    DRIVE_FIXED,        // = 3;
    DRIVE_REMOTE,       // = 4;
    DRIVE_CDROM,        // = 5;
    DRIVE_RAMDISK       // = 6;
  ];

  DriveTypeNames : array [DRIVE_UNKNOWN..DRIVE_RAMDISK] of string = (
    'DRIVE_UNKNOWN',
    'DRIVE_NO_ROOT_DIR',
    'DRIVE_REMOVABLE',
    'DRIVE_FIXED',
    'DRIVE_REMOTE',
    'DRIVE_CDROM',
    'DRIVE_RAMDISK'
  );

type
  HDDVolumeInfo = record
    serialNum,
    diskType:DWORD;
    fileSysName: string;
    VolLabel: string;
  end;
(*
//laVSerial.Caption := HDDVolumeInfo.serialNum.ToHexString;
//laVLabel.Caption := HDDVolumeInfo.VolLabel;
//laFsystem.Caption := HDDVolumeInfo.fileSysName;
//laDrvType.Caption:=format('dType=%d, "%s"',[HDDVolumeInfo.diskType, DriveTypeNames[HDDVolumeInfo.diskType]]);
*)

function GetVolumeLabel(const DriveChar: Char): string;
function GetVolumeInfo(const DrivePath: String): HDDVolumeInfo;
function getHDDVolumeInfo(const DrivePath: string): HDDVolumeInfo;
procedure GetDirectories(const DirStr : string; Items : TStrings);
procedure GetFiles(const DirStr : string; Items : TStrings);
function CheckScapeString(const Value: string): string;
function ImageToBytes(img:TGraphic): TBytes;

implementation

uses
  System.Diagnostics, Vcl.Forms;
var
  sw: TStopwatch;

procedure GetDirectories(const DirStr : string; Items : TStrings);
var
  DirInfo: TSearchRec;
  r : Integer;
begin
  r := FindFirst(DirStr + '\*.*', FaDirectory, DirInfo);
  while r = 0 do  begin
    Application.ProcessMessages;
    if ((DirInfo.Attr and FaDirectory = FaDirectory) and
         (DirInfo.Name <> '.') and
         (DirInfo.Name <> '..'))  then
      Items.Add(DirStr + '\' + DirInfo.Name);
    r := FindNext(DirInfo);
  end;
  System.SysUtils.FindClose(DirInfo);
end;

procedure GetFiles(const DirStr : string; Items : TStrings);
var
  DirInfo: TSearchRec;
  r : Integer;
begin
  r := FindFirst(DirStr + '\*.*', FaAnyfile, DirInfo);
  while r = 0 do  begin
    Application.ProcessMessages;
    if ((DirInfo.Attr and FaDirectory <> FaDirectory) and
        (DirInfo.Attr and faVolumeID <> FaVolumeID)) then
      Items.Add(DirStr + '\' + DirInfo.Name);
    r := FindNext(DirInfo);
  end;
  System.SysUtils.FindClose(DirInfo);
end;


function GetVolumeLabel(const DriveChar: Char): string;
var
  NotUsed: DWORD;
  VolumeFlags: DWORD;
  VolumeInfo: array [0 .. MAX_PATH] of Char;
  VolumeSerialNumber: DWORD;
  Buf: array [0 .. MAX_PATH] of Char;
begin
  GetVolumeInformation(PChar(DriveChar + ':\'),
    Buf, SizeOf(VolumeInfo), @VolumeSerialNumber, NotUsed,
    VolumeFlags, nil, 0);
  SetString(Result, Buf, StrLen(Buf)); { Set return result }
  Result := AnsiUpperCase(Result)
end;

function GetVolumeInfo(const DrivePath: string): HDDVolumeInfo;
var
  NotUsed: DWORD;
  VolumeFlags: DWORD;
  VolumeInfo: array [0 .. MAX_PATH] of Char;
  VolumeSerialNumber: DWORD;
  VolumeFSysName: array [0 .. MAX_PATH] of Char;
  Buf: array [0 .. MAX_PATH] of Char;
  RecVolumeInfo: HDDVolumeInfo;
  rc: boolean;
begin
  Result := RecVolumeInfo;
  rc:=GetVolumeInformation(PChar(DrivePath),
    Buf, SizeOf(VolumeInfo), @VolumeSerialNumber, NotUsed,
    VolumeFlags, VolumeFSysName, SizeOf(VolumeInfo));
  SetString(Result.VolLabel, Buf, StrLen(Buf)); { Set return result }
  SetString(Result.fileSysName, VolumeFSysName, StrLen(VolumeFSysName)); { Set return result }
  Result.serialNum := VolumeSerialNumber;
end;

function getHDDVolumeInfo(const DrivePath: string): HDDVolumeInfo;
var
  //VolInfoRec: HDDVolumeInfo;
  Drive: String;
  DriveLetter: String;
  VolDriveType: DRVTYPECONST;
begin
  Drive:= ExtractFileDrive(DrivePath);
  DriveLetter := Drive + '\';
  Result:=GetVolumeInfo(PChar(DriveLetter));
  VolDriveType:=GetDriveType(PChar(DriveLetter));
  Result.diskType:=VolDriveType;
end;

function StreamToByteArray(Stream: TStream): TBytes;
begin
  if Assigned(Stream) then   // Check stream
  begin
     Stream.Position:=0;    // Reset stream position
     SetLength(result, Stream.Size); // Allocate size
     Stream.Read(result[0], Stream.Size); // Read contents of stream
  end
  else
     SetLength(result, 0);  // Clear result
end;

function CheckScapeString(const Value: string): string;
var
  I: Integer;
  tmpStr: string;
begin
  Result := '';
  tmpStr := '';
  for I := 1 to Length(Value) do
    if Value[I] in [ '''', '\', '"', ';']
      then tmpStr := tmpStr + '\' + Value[I]
      else tmpStr := tmpStr + Value[I];
  Result := tmpStr;
end;

function ImageToBytes(img:TGraphic): TBytes;
var
  stream: TBytesStream;
begin
  stream:=TBytesStream.Create;
  try
    img.SaveToStream(stream);
    Result:=stream.Bytes; // Read contents of stream
    SetLength(Result, stream.Size);
  finally
    stream.Free;
  end;
end;

end.
