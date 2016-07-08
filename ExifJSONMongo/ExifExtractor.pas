unit ExifExtractor;

interface

uses
  VCL.Graphics,
  SyStem.Classes,IniFiles,
  System.JSON,System.JSON.Types,System.JSON.Writers,System.JSON.Builders,System.JSON.BSON,
  CCR.Exif,
  FireDAC.Comp.Client, FireDAC.Phys.MongoDBWrapper,
  myUtils, ExifWRTLoader, ExifMongoHelper;

type

TExifJSONExtractor = class
private
  FVolumeInfo: HDDVolumeInfo;
  FDate: TDatetime;
  FFullPath: string;
  FExifData:TExifData;
  FwithThumbN: boolean;
  FThumbnail: TPicture;
  FMakerNoteValueMap: TCustomIniFile;
  procedure SetwithThumbN(const Value: boolean);
  function GetThumbnail: TPicture;
  function GetisActive: boolean;
  procedure SetMakerNoteValueMap(const Value: TCustomIniFile);
  function isSectionHere(Kind: TExifSectionKind; const Name: string): Boolean;
public
  function AsString: string;
  constructor Create(const fullFileName: string); overload;
  constructor Create(const fullFileName: string; volInfoRec: myUtils.HDDVolumeInfo); overload;
  destructor Destroy; override;

  function toJSON(wrt: TExifWriter): TJSONObject; //TJSONAncestor
  function toString(wrt: TJsonObjectWriter): string;
  function toMongoDB(mongoConnect:TFDConnection; insert:boolean):string;
  // function toBSON(wrt: TBSONWriter): TJSONObject; //TJSONAncestor
  // function toStream(stm: TStream): boolean;

  property isActive: boolean read GetisActive;
  property thumbnail:TPicture read GetThumbnail;
  property withThumbN: boolean read FwithThumbN write SetwithThumbN;
  property MakerNoteValueMap: TCustomIniFile read FMakerNoteValueMap write SetMakerNoteValueMap;
end;

implementation

uses
  ConvertersUtils,
  System.SysUtils, System.IOUtils;

var
  FEnv: TMongoEnv;
  FCon: TMongoConnection;

{ TExifJSONExtractor }

function TExifJSONExtractor.AsString: string;
begin
  Result:=format('path:"%s",Disk Type:%s(%d),File system:%s,Vol Serial number:%s,Vol label:%s',
    [ FFullPath,DriveTypeNames[FVolumeInfo.diskType],FVolumeInfo.diskType, FVolumeInfo.fileSysName,
      FVolumeInfo.serialNum.ToHexString,FVolumeInfo.VolLabel ]);
  if isActive then Result:=Result+',Active' else  Result:=Result+',notActive';
  if FwithThumbN then Result:=Result+',+Th' else Result:=Result+',-Th';
end;

constructor TExifJSONExtractor.Create(const fullFileName: string;
                                      volInfoRec: myUtils.HDDVolumeInfo);
begin
  FVolumeInfo:=volInfoRec;
  FThumbnail:=TPicture.Create;
  FThumbnail.Assign(nil);
  FwithThumbN:=False;
  FExifData:=nil;
  FFullPath:= fullFileName;
  FileAge(FFullPath, FDate, True);
  FExifData := TExifData.Create;
  FExifData.EnsureEnumsInRange := False; //as we use case statements rather than array constants, no need to keep this property set to True
  FExifData.LoadFromGraphic(fullFileName); //get ExifData from FullFileName;
 end;

constructor TExifJSONExtractor.Create(const fullFileName: string);
var
  VolumeInfo : myUtils.HDDVolumeInfo;
begin
  VolumeInfo:=myUtils.getHDDVolumeInfo(fullFileName);
  Create(fullFileName,VolumeInfo);
end;

destructor TExifJSONExtractor.Destroy;
begin
  FThumbnail.Free;
  FwithThumbN:=False;
  FExifData.Free;
  inherited;
end;

function TExifJSONExtractor.GetisActive: boolean;
begin
  Result:=not FExifData.Empty;
end;

function TExifJSONExtractor.GetThumbnail: TPicture;
begin
  Result := FThumbnail;
  if not FExifData.Thumbnail.Empty then FThumbnail.Assign(FExifData.Thumbnail);
end;

function TExifJSONExtractor.isSectionHere(Kind: TExifSectionKind;  const Name: string): Boolean;
begin
  Result := (FExifData[Kind].Count > 0) or (FExifData[Kind].LoadErrors <> []);
end;

procedure TExifJSONExtractor.SetMakerNoteValueMap(const Value: TCustomIniFile);
begin
  FMakerNoteValueMap := Value;
end;

procedure TExifJSONExtractor.SetwithThumbN(const Value: boolean);
begin
  FwithThumbN := Value;
end;

function TExifJSONExtractor.toJSON(wrt: TExifWriter): TJSONObject;
var
  jv, md,fd: TJSONObject;
begin
  jv:=TJSONObject.Create; {  : startObject, write filekey }
  Result := jv;
    jv.AddPair('upath', CheckScapeString( ExpandUNCFileName(FFullPath)));
  try
    fd:=TJSONObject.Create;
    fd.AddPair('filedate',ConvertersUtils.DateTimeToStr(FDate));
    fd.AddPair('filename',TPath.GetFileNameWithoutExtension(FFullPath));
    fd.AddPair('ext', ExtractFileExt(FFullPath));
    fd.AddPair('path', CheckScapeString( ExtractFilePath(FFullPath)));
    fd.AddPair('drive', ExtractFileDrive(FFullPath));
    fd.AddPair('driveTypeName',DriveTypeNames[FVolumeInfo.diskType]);
    fd.AddPair('diskType',FVolumeInfo.diskType.ToString);
    fd.AddPair('filesystem',FVolumeInfo.fileSysName);
    fd.AddPair('volSerialNum',FVolumeInfo.serialNum.ToHexString);
    fd.AddPair('volLable',FVolumeInfo.VolLabel);

    jv.AddPair('file',fd);

    if isActive then
    begin
      wrt.LoadStandardValues(FExifData);
      if FExifData.HasMakerNote then
        wrt.LoadMakerNoteValues(FExifData.MakerNote, MakerNoteValueMap);
    end;
    md := wrt.toJSON;
    jv.AddPair('metadata',md); { todo 1 : Close envelope object }
  finally
  end;
end;

function TExifJSONExtractor.toMongoDB(mongoConnect: TFDConnection; insert:boolean):string;
var
  //  oCrs: IMongoCursor;
  oDoc, iDoc, sDoc, mkDoc: TMongoDocument;
  s1,s2,s3,s4,s5,s6,s7,s8: TMongoDocument;
begin
  FCon := TMongoConnection(mongoConnect.CliObj);
  FEnv := FCon.Env;
  oDoc := FEnv.NewDoc;
  //  if not FDConnection1.Connected then
  iDoc:= TMongoDocument.Create(FEnv);
  sDoc:= TMongoDocument.Create(FEnv);
  mkDoc:= TMongoDocument.Create(FEnv);
  s1 := FEnv.NewDoc;
  s2 := FEnv.NewDoc;
  s3 := FEnv.NewDoc;
  s4 := FEnv.NewDoc;
  s5 := FEnv.NewDoc;

  try
   if isActive then
    begin
      // выдача миниатюры
      if withThumbN and not FExifData.Thumbnail.Empty then
        iDoc.Add('thumbnail',ImageToBytes(thumbnail.Graphic), TJsonBinaryType.UserDefined);
      // Стандартные параметры EXIF
//--      sDoc.Clear
//--        .BeginObject('standard')
    if isSectionHere(esGeneral, 'Main IFD') then
      s1.Clear
        .DoSection(esGeneral, 'Main IFD',FExifData)
          .AddValue('Camera make', FExifData.CameraMake)
          .AddValue('Camera model', FExifData.CameraModel)
          .AddValue('Software', FExifData.Software)
          .AddValue('Date/time', FExifData.DateTime)
          .AddValue('Image description', FExifData.ImageDescription)
          .AddValue('Copyright', FExifData.Copyright)
          .AddValue('Orientation', OrientationToStr(FExifData.Orientation))
          .AddValue('Resolution', FExifData.Resolution)
          .AddValue('Author', FExifData.Author)
          .AddValue('Comments', FExifData.Comments)
          .AddValue('Keywords', FExifData.Keywords)
          .AddValue('Subject', FExifData.Subject)
          .AddValue('Title', FExifData.Title)
        .EndSection;
    if isSectionHere(esDetails, 'Exif sub-IFD') then
      s2.Clear
        .DoSection(esDetails, 'Exif sub-IFD',FExifData)
          .AddValue('Exif version', FExifData.ExifVersion.AsString)
          .AddValue('Aperture value', FExifData.ApertureValue)
          .AddValue('Body serial number', FExifData.BodySerialNumber)
          .AddValue('Brightness value', FExifData.BrightnessValue)
          .AddValue('Camera owner', FExifData.CameraOwnerName)
          .AddValue('Colour space', ColorSpaceToStr(FExifData.ColorSpace))
          .AddValue('Compressed bits per pixel', FExifData.CompressedBitsPerPixel)
          .AddValue('Date/time original', FExifData.DateTimeOriginal)
          .AddValue('Date/time digitised', FExifData.DateTimeDigitized)
          .AddValue('Digital zoom ratio', FExifData.DigitalZoomRatio)
          .AddValue('Exif image width', FExifData.ExifImageWidth)
          .AddValue('Exif image height', FExifData.ExifImageHeight)
          .AddValue('Exposure programme', ExposureProgramToStr(FExifData.ExposureProgram))
          .AddValue('Exposure time', FExifData.ExposureTime, 'seconds')
          .AddValue('Exposure index', FExifData.ExposureIndex)
          .AddValue('Exposure bias value', FExifData.ExposureBiasValue)
          .AddValue('File source', FileSourceToStr(FExifData.FileSource))
      //    if not FExifData.Flash.MissingOrInvalid then
      //    begin
            .AddValue('Flash present', FExifData.Flash.Present)
            .AddValue('Flash mode', FlashModeToStr(FExifData.Flash.Mode))
            .AddValue('Flash fired', FExifData.Flash.Fired)
            .AddValue('Flash red eye reduction', FExifData.Flash.RedEyeReduction)
            .AddValue('Flash strobe energy', FExifData.Flash.StrobeEnergy)
            .AddValue('Flash strobe light', StrobeLightToStr(FExifData.Flash.StrobeLight))
      //    end
          .AddValue('F number', FExifData.FNumber)
          .AddValue('Focal length', FExifData.FocalLength)
          .AddValue('Focal length in 35mm film', FExifData.FocalLengthIn35mmFilm)
          .AddValue('Focal plane resolution', FExifData.FocalPlaneResolution)
          .AddValue('Gain control', GainControlToStr(FExifData.GainControl))
          .AddValue('Image unique ID', FExifData.ImageUniqueID)
      //    if not FExifData.ISOSpeedRatings.MissingOrInvalid then
            .AddValue('ISO speed rating(s)', FExifData.ISOSpeedRatings.AsString)
          .AddValue('Lens make', FExifData.LensMake)
          .AddValue('Lens model', FExifData.LensModel)
          .AddValue('Lens serial number', FExifData.LensSerialNumber)
          .AddValue('Light source', LightSourceToStr(FExifData.LightSource))
          .AddValue('MakerNote data offset', FExifData.OffsetSchema)
          .AddValue('Max aperture value', FExifData.MaxApertureValue)
          .AddValue('Metering mode', MeteringModeToStr(FExifData.MeteringMode))
          .AddValue('Related sound file', FExifData.RelatedSoundFile)
          .AddValue('Rendering', RenderingToStr(FExifData.Rendering))
          .AddValue('Scene capture type', SceneCaptureTypeToStr(FExifData.SceneCaptureType))
          .AddValue('Scene type', SceneTypeToStr(FExifData.SceneType))
          .AddValue('Sensing method', SensingMethodToStr(FExifData.SensingMethod))
      //    if FExifData.ShutterSpeedInMSecs <> 0 then
            .AddValue('Shutter speed', '%.4g milliseconds', [FExifData.ShutterSpeedInMSecs])
          .AddValue('Subject distance', FExifData.SubjectDistance)
          .AddValue('Spectral sensitivity', FExifData.SpectralSensitivity)
          .AddValue('Subject distance', FExifData.SubjectDistance)
          .AddValue('Subject distance range', SubjectDistanceRangeToStr(FExifData.SubjectDistanceRange))
          .AddValue('Subject location', FExifData.SubjectLocation)
          .AddValue('White balance mode', WhiteBalanceModeToStr(FExifData.WhiteBalanceMode))
          { don't do sub sec tags as their values are rolled into the date/times by the
            latters' property getters }
        .EndSection;
    if isSectionHere(esInterop, 'Interoperability sub-IFD') then
      s3.Clear
        .DoSection(esInterop, 'Interoperability sub-IFD',FExifData)
          .AddValue('Interoperability type', FExifData.InteropTypeName)
          .AddValue('Interoperability version', FExifData.InteropVersion.AsString)
        .EndSection
        ;
    if isSectionHere(esGPS, 'GPS sub-IFD') then
      s4.Clear
        .DoSection(esGPS, 'GPS sub-IFD',FExifData)
          .AddValue('GPS version', FExifData.GPSVersion.AsString)
          .AddValue('GPS date/time (UTC)', FExifData.GPSDateTimeUTC)
          .AddValue('GPS latitude', FExifData.GPSLatitude)
          .AddValue('GPS longitude', FExifData.GPSLongitude)
          .AddValue('GPS altitude', FExifData.GPSAltitude, 'metres ' +
            GPSAltitudeRefToStr(FExifData.GPSAltitudeRef))
          .AddValue('GPS satellites', FExifData.GPSSatellites)
          .AddValue('GPS status', GPSStatusToStr(FExifData.GPSStatus))
          .AddValue('GPS measure mode', GPSMeasureModeToStr(FExifData.GPSMeasureMode))
          .AddValue('GPS DOP', FExifData.GPSDOP)
          .AddValue('GPS speed', FExifData.GPSSpeed, GPSSpeedRefToStr(FExifData.GPSSpeedRef))
          .AddValue('GPS track', FExifData.GPSTrack, FExifData.GPSTrackRef)
          .AddValue('GPS image direction', FExifData.GPSImgDirection,
            FExifData.GPSImgDirectionRef)
          .AddValue('GPS map datum', FExifData.GPSMapDatum)
          .AddValue('GPS destination latitude', FExifData.GPSDestLatitude)
          .AddValue('GPS destination longitude', FExifData.GPSDestLongitude)
          .AddValue('GPS destination bearing', FExifData.GPSDestBearing,
            FExifData.GPSDestBearingRef)
          .AddValue('GPS destination distance', FExifData.GPSDestDistance,
            FExifData.GPSDestDistanceRef)
          .AddValue('GPS differential', GPSDifferentialToStr(FExifData.GPSDifferential))
        .EndSection
        ;
    if isSectionHere(esThumbnail, 'Thumbnail IFD') then
      s5.Clear
        .DoSection(esThumbnail, 'Thumbnail IFD',FExifData)
          .AddValue('Thumbnail orientation', OrientationToStr(FExifData.ThumbnailOrientation))
          .AddValue('Thumbnail resolution', FExifData.ThumbnailResolution)
        .EndSection
        ;

       sDoc.Clear
        .BeginObject('standard')
          .Append(s1)
          .Append(s2)
          .Append(s3)
          .Append(s4)
          .Append(s5)
        .EndObject;

      if FExifData.HasMakerNote then begin
        //  wrt.LoadMakerNoteValues(FExifData.MakerNote, MakerNoteValueMap);
        //загрузка MakerNotes
        mkDoc
          .BeginObject('MakerNotes')
             .add('available','Not in demo version')
          .EndObject;
      end;
    end;
    // Создание полного документа из составных частей
    oDoc.Clear
      // ключ документа
      .addValue('upath', ExpandUNCFileName(FFullPath))
      .beginObject('file')
        .addValue('filedate',FDate)
        .addValue('filename',TPath.GetFileNameWithoutExtension(FFullPath))
        .addValue('ext', ExtractFileExt(FFullPath))
        .addValue('path', ExtractFilePath(FFullPath))
        .addValue('drive', ExtractFileDrive(FFullPath))
        .addValue('driveTypeName',DriveTypeNames[FVolumeInfo.diskType])
        .addValue('diskType',FVolumeInfo.diskType)
        .addValue('filesystem',FVolumeInfo.fileSysName)
        .addValue('volSerialNum',FVolumeInfo.serialNum.ToHexString)
        .addValue('volLable',FVolumeInfo.VolLabel)
      .EndObject
      .BeginObject('metadata')
        // стандартный EXIF
        .Append(sDoc)
        // миниатюра
        .Append(iDoc)
        // MakerNotes
        .Append(mkDoc)
      .endObject;

    Result:=oDoc.AsJSON;  // демонстрация резульата
    if insert then begin
      FCon['Grafics']['tst_meta'].Insert(oDoc);
    end;
  finally
    s1.Free;
    s2.Free;
    s3.Free;
    s4.Free;
    s5.Free;

    oDoc.Free;
    iDoc.Free;
    sDoc.Free;
    mkDoc.Free;
//    FEnv.Free;
//    FCon.Free;
  end;


 (*
 var
  oDoc: TMongoDocument;
  oCrs: IMongoCursor;
  imgbytes: TBytes;
begin
  // For details see:
  // http://docs.mongodb.org/manual/reference/operator/query/
  // http://docs.mongodb.org/manual/reference/operator/query-modifier/
  oDoc := FEnv.NewDoc;
  try
    //FCon['test']['perf_test'].RemoveAll;
//    imgbytes:= _ImageToBytes(Image1.Picture.Graphic);
//    oDoc.Clear
//      .Add('upath','C:\Users\asovtsov\Downloads\1\0908d400-0422-75-76.jpg')
//      .BeginObject('file')
//      .Add('filedate', StrToDatetime('14.08.2010 18:12:12'))
//      .Add('filename', '0908d400-0422-75-76')
//      .Add('ext', '.jpg')
//      .Add('path', 'C:\Users\asovtsov\Downloads\1\')
//      .Add('drive', 'C:')
//      .Add('driveTypeName', 'DRIVE_FIXED')
//      .Add('diskType', 3)
//      .Add('filesystem', 'NTFS').Add('volSerialNum', '940B7FD7')
//      .Add('volLable', 'OS')
//      .Add('thumbnail',_ImageToBytes(Image1.Picture.Graphic), TJsonBinaryType.Generic)
//    .EndObject;
//
//    FCon['Grafics']['tst_meta'].Insert(oDoc);

    oCrs := FCon['Grafics']['tst_meta']
      .Find()
{      .Match
        .BeginObject('f1')
          .Add('$gt', 5)
        .EndObject
      .&End

      .Sort
        .Field('f1', False)
        .Field('f2', True)
      .&End }
      .Limit(5);

    while oCrs.Next do
      Memo1.Text := Memo1.Text + #13#10 + #13#10 + oCrs.Doc.AsJSON;
//
  finally
    oDoc.Free;
  end;
end;
*)

end;

function TExifJSONExtractor.toString(wrt: TJsonObjectWriter): string;
begin
  //
end;

end.
