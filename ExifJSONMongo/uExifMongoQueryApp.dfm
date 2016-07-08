object fmExifQuery: TfmExifQuery
  Left = 0
  Top = 0
  Caption = 'EXIF metadata'
  ClientHeight = 372
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 635
    Height = 125
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 215
      Top = 100
      Width = 31
      Height = 13
      Caption = #1051#1080#1084#1080#1090
      FocusControl = SpinEdit1
    end
    object LabeledEdit1: TLabeledEdit
      Left = 92
      Top = 16
      Width = 249
      Height = 21
      EditLabel.Width = 73
      EditLabel.Height = 13
      EditLabel.Caption = #1054#1090#1073#1086#1088' (Query)'
      LabelPosition = lpLeft
      TabOrder = 0
    end
    object LabeledEdit2: TLabeledEdit
      Left = 92
      Top = 43
      Width = 249
      Height = 21
      EditLabel.Width = 75
      EditLabel.Height = 13
      EditLabel.Caption = #1055#1086#1082#1072#1079' (Project)'
      LabelPosition = lpLeft
      TabOrder = 1
    end
    object LabeledEdit3: TLabeledEdit
      Left = 92
      Top = 70
      Width = 249
      Height = 21
      EditLabel.Width = 60
      EditLabel.Height = 13
      EditLabel.Caption = #1057#1086#1088#1090'. (Sort)'
      LabelPosition = lpLeft
      TabOrder = 2
    end
    object SpinEdit1: TSpinEdit
      Left = 260
      Top = 97
      Width = 81
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 3
      Value = 50
    end
    object btFind: TButton
      Left = 360
      Top = 14
      Width = 85
      Height = 99
      Caption = #1053#1072#1081#1090#1080
      TabOrder = 4
      OnClick = btFindClick
    end
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 125
    Width = 635
    Height = 247
    Align = alClient
    DataSource = DataSource1
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object FDConnection1: TFDConnection
    Params.Strings = (
      'Database=Grafics'
      'Server=mslasovt02'
      'Port=27004'
      'DriverID=Mongo')
    Left = 64
    Top = 192
  end
  object DataSource1: TDataSource
    DataSet = FDMongoQuery1
    Left = 272
    Top = 228
  end
  object FDMongoQuery1: TFDMongoQuery
    DetailFields = 
      '_id;file;file.diskType;file.drive;file.driveTypeName;file.ext;fi' +
      'le.filedate;file.filename;file.filesystem;file.path;file.volLabl' +
      'e;file.volSerialNum;metadata;metadata.MakerNotes;metadata.MakerN' +
      'otes.available;metadata.standard;metadata.standard.Exif sub-IFD;' +
      'metadata.standard.Exif sub-IFD.Aperture value;metadata.standard.' +
      'Exif sub-IFD.Body serial number;metadata.standard.Exif sub-IFD.C' +
      'olour space;metadata.standard.Exif sub-IFD.Date/time digitised;m' +
      'etadata.standard.Exif sub-IFD.Date/time original;metadata.standa' +
      'rd.Exif sub-IFD.Exif image height;metadata.standard.Exif sub-IFD' +
      '.Exif image width;metadata.standard.Exif sub-IFD.Exif version;me' +
      'tadata.standard.Exif sub-IFD.Exposure bias value;metadata.standa' +
      'rd.Exif sub-IFD.Exposure programme;metadata.standard.Exif sub-IF' +
      'D.Exposure time;metadata.standard.Exif sub-IFD.F number;metadata' +
      '.standard.Exif sub-IFD.Flash fired;metadata.standard.Exif sub-IF' +
      'D.Flash mode;metadata.standard.Exif sub-IFD.Flash present;metada' +
      'ta.standard.Exif sub-IFD.Flash red eye reduction;metadata.standa' +
      'rd.Exif sub-IFD.Flash strobe light;metadata.standard.Exif sub-IF' +
      'D.Focal length;metadata.standard.Exif sub-IFD.Focal length in 35' +
      'mm film;metadata.standard.Exif sub-IFD.Focal plane resolution;me' +
      'tadata.standard.Exif sub-IFD.ISO speed rating(s);metadata.standa' +
      'rd.Exif sub-IFD.Lens model;metadata.standard.Exif sub-IFD.Lens s' +
      'erial number;metadata.standard.Exif sub-IFD.Loaded cleanly;metad' +
      'ata.standard.Exif sub-IFD.Max aperture value;metadata.standard.E' +
      'xif sub-IFD.Metering mode;metadata.standard.Exif sub-IFD.Renderi' +
      'ng;metadata.standard.Exif sub-IFD.Scene capture type;metadata.st' +
      'andard.Exif sub-IFD.Shutter speed;metadata.standard.Exif sub-IFD' +
      '.White balance mode;metadata.standard.GPS sub-IFD;metadata.stand' +
      'ard.GPS sub-IFD.GPS version;metadata.standard.GPS sub-IFD.Loaded' +
      ' cleanly;metadata.standard.Interoperability sub-IFD;metadata.sta' +
      'ndard.Interoperability sub-IFD.Interoperability type;metadata.st' +
      'andard.Interoperability sub-IFD.Interoperability version;metadat' +
      'a.standard.Interoperability sub-IFD.Loaded cleanly;metadata.stan' +
      'dard.Main IFD;metadata.standard.Main IFD.Author;metadata.standar' +
      'd.Main IFD.Camera make;metadata.standard.Main IFD.Camera model;m' +
      'etadata.standard.Main IFD.Copyright;metadata.standard.Main IFD.D' +
      'ate/time;metadata.standard.Main IFD.Loaded cleanly;metadata.stan' +
      'dard.Main IFD.Orientation;metadata.standard.Main IFD.Resolution;' +
      'metadata.standard.Main IFD.Software;metadata.standard.Thumbnail ' +
      'IFD;metadata.standard.Thumbnail IFD.Loaded cleanly;metadata.stan' +
      'dard.Thumbnail IFD.Thumbnail resolution;metadata.thumbnail;upath'
    FetchOptions.AssignedValues = [evRecsMax]
    FetchOptions.RecsMax = 5
    FormatOptions.AssignedValues = [fvStrsTrim2Len]
    FormatOptions.StrsTrim2Len = True
    UpdateOptions.KeyFields = '_id'
    Connection = FDConnection1
    DatabaseName = 'Grafics'
    CollectionName = 'tst_meta'
    Left = 312
    Top = 192
  end
end
