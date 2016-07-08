program dirfileslist;

uses
  Vcl.Forms,
  Unit5 in 'Unit5.pas' {Form1},
  CCR.Exif in '..\CCR Exif v1.5.1\CCR Exif v1.5.1\CCR.Exif.pas',
  CCR.Exif.Consts in '..\CCR Exif v1.5.1\CCR Exif v1.5.1\CCR.Exif.Consts.pas',
  CCR.Exif.XMPUtils in '..\CCR Exif v1.5.1\CCR Exif v1.5.1\CCR.Exif.XMPUtils.pas',
  CCR.Exif.TiffUtils in '..\CCR Exif v1.5.1\CCR Exif v1.5.1\CCR.Exif.TiffUtils.pas',
  CCR.Exif.TagIDs in '..\CCR Exif v1.5.1\CCR Exif v1.5.1\CCR.Exif.TagIDs.pas',
  CCR.Exif.StreamHelper in '..\CCR Exif v1.5.1\CCR Exif v1.5.1\CCR.Exif.StreamHelper.pas',
  CCR.Exif.IPTC in '..\CCR Exif v1.5.1\CCR Exif v1.5.1\CCR.Exif.IPTC.pas',
  CCR.Exif.BaseUtils in '..\CCR Exif v1.5.1\CCR Exif v1.5.1\CCR.Exif.BaseUtils.pas',
  CCR.Exif.JpegUtils in '..\CCR Exif v1.5.1\CCR Exif v1.5.1\CCR.Exif.JpegUtils.pas',
  myUtils in 'myUtils.pas',
  ExifExtractor in 'ExifExtractor.pas',
  ConvertersUtils in 'ConvertersUtils.pas',
  CCR.Exif.Demos in '..\CCR Exif v1.5.1\CCR Exif v1.5.1\VCL Demos\CCR.Exif.Demos.pas',
  ExifWRTLoader in 'ExifWRTLoader.pas',
  ExifMongoHelper in 'ExifMongoHelper.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
