program ExifMongoQueryApp;

uses
  Vcl.Forms,
  uExifMongoQueryApp in 'uExifMongoQueryApp.pas' {fmExifQuery};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmExifQuery, fmExifQuery);
  Application.Run;
end.
