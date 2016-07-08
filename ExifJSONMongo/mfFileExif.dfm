object fmFileExif: TfmFileExif
  Left = 0
  Top = 0
  Caption = #1059#1087#1088#1072#1074#1083#1077#1085#1080#1077' EXIF '
  ClientHeight = 586
  ClientWidth = 817
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 817
    Height = 145
    Align = alTop
    BevelOuter = bvNone
    Caption = ' '
    TabOrder = 0
    object Label2: TLabel
      Left = 8
      Top = 14
      Width = 68
      Height = 13
      Caption = #1048#1079#1086#1073#1088#1072#1078#1077#1085#1080#1077
    end
    object leRoot: TEdit
      Left = 82
      Top = 11
      Width = 271
      Height = 21
      TabOrder = 0
      Text = 'C:\Temp\fotos\100EOS7D\_72_9961.JPG'
    end
    object btOpen: TButton
      Left = 368
      Top = 9
      Width = 69
      Height = 25
      Caption = #1042#1099#1073#1088#1072#1090#1100
      TabOrder = 1
      OnClick = btOpenClick
    end
    object grpThumbnail: TGroupBox
      AlignWithMargins = True
      Left = 648
      Top = 0
      Width = 169
      Height = 145
      Margins.Left = 6
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alRight
      Caption = #1052#1080#1085#1080#1072#1090#1102#1088#1072
      TabOrder = 2
      Visible = False
      object imThumbnail: TImage
        AlignWithMargins = True
        Left = 36
        Top = 14
        Width = 105
        Height = 128
        Proportional = True
        Stretch = True
      end
    end
    object Volume: TGroupBox
      AlignWithMargins = True
      Left = 8
      Top = 42
      Width = 157
      Height = 100
      Caption = #1053#1086#1089#1080#1090#1077#1083#1100
      TabOrder = 3
      object laDrvType: TLabel
        Left = 11
        Top = 18
        Width = 3
        Height = 13
        Caption = ' '
      end
      object laFsystem: TLabel
        Left = 11
        Top = 75
        Width = 3
        Height = 13
      end
      object laVLabel: TLabel
        Left = 11
        Top = 37
        Width = 3
        Height = 13
      end
      object laVSerial: TLabel
        Left = 11
        Top = 56
        Width = 3
        Height = 13
      end
    end
    object btJSON: TButton
      Left = 368
      Top = 48
      Width = 97
      Height = 40
      Caption = 'JSON'
      TabOrder = 4
      OnClick = btJSONClick
    end
    object btMongoDB: TButton
      Left = 368
      Top = 94
      Width = 97
      Height = 40
      Caption = 'MongoDB'
      TabOrder = 5
      OnClick = btMongoDBClick
    end
    object grMongo: TGroupBox
      Left = 171
      Top = 42
      Width = 182
      Height = 100
      Caption = #1057#1077#1088#1074#1077#1088
      TabOrder = 6
      object Label1: TLabel
        Left = 12
        Top = 18
        Width = 46
        Height = 13
        Caption = 'Host:port'
      end
      object Label3: TLabel
        Left = 44
        Top = 45
        Width = 14
        Height = 13
        Caption = #1041#1044
      end
      object Label4: TLabel
        Left = 44
        Top = 72
        Width = 62
        Height = 13
        Caption = #1057#1086#1077#1076#1080#1085#1077#1085#1080#1077
      end
      object ToggleSwitch1: TToggleSwitch
        Left = 112
        Top = 68
        Width = 65
        Height = 20
        FrameColor = clScrollBar
        StateCaptions.CaptionOn = #1044#1072
        StateCaptions.CaptionOff = #1053#1077#1090
        SwitchWidth = 40
        TabOrder = 0
        OnClick = ToggleSwitch1Click
      end
      object Edit2: TEdit
        Left = 67
        Top = 13
        Width = 109
        Height = 21
        TabOrder = 1
        Text = 'localhost:27017'
      end
      object Edit1: TEdit
        Left = 67
        Top = 40
        Width = 109
        Height = 21
        TabOrder = 2
        Text = 'Grafics'
      end
    end
    object grpOptions: TGroupBox
      Left = 471
      Top = 42
      Width = 130
      Height = 100
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
      TabOrder = 7
      object cbInsert: TCheckBox
        Left = 9
        Top = 55
        Width = 108
        Height = 17
        Caption = #1047#1072#1075#1088#1091#1078#1072#1090#1100' '#1074' '#1041#1044
        TabOrder = 0
      end
      object cbWThumb: TCheckBox
        Left = 9
        Top = 23
        Width = 104
        Height = 17
        Caption = #1057' '#1084#1080#1085#1080#1072#1090#1102#1088#1086#1081
        TabOrder = 1
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 567
    Width = 817
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object Memo1: TMemo
    AlignWithMargins = True
    Left = 3
    Top = 148
    Width = 811
    Height = 416
    Align = alClient
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssBoth
    TabOrder = 2
  end
  object OpenDialog1: TOpenDialog
    InitialDir = 'c:\temp'
    Left = 88
    Top = 284
  end
  object FDConnection1: TFDConnection
    Params.Strings = (
      'DriverID=Mongo')
    Left = 244
    Top = 244
  end
  object ActionList1: TActionList
    Left = 80
    Top = 168
    object acPickupFile: TAction
      Caption = 'acPickupFile'
      OnExecute = acPickupFileExecute
    end
    object acMongoExtract: TAction
      Caption = 'acMongoExtract'
      OnExecute = acMongoExtractExecute
    end
    object acJSONExtract: TAction
      Caption = 'acJSONExtract'
    end
    object acMongoConnect: TAction
      Caption = 'acMongoConnect'
      OnExecute = acMongoConnectExecute
    end
  end
end
