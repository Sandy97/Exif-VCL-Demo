unit uExifMongoQueryApp;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Vcl.ExtCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MongoDB,
  FireDAC.Phys.MongoDBDef, System.Rtti, System.JSON.Types, System.JSON.Readers,
  System.JSON.BSON, System.JSON.Builders, FireDAC.Phys.MongoDBWrapper,
  FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.MongoDBDataSet,
  Vcl.StdCtrls, Vcl.Samples.Spin;

type
  TfmExifQuery = class(TForm)
    Panel1: TPanel;
    DBGrid1: TDBGrid;
    FDConnection1: TFDConnection;
    DataSource1: TDataSource;
    FDMongoQuery1: TFDMongoQuery;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    LabeledEdit3: TLabeledEdit;
    SpinEdit1: TSpinEdit;
    Label1: TLabel;
    btFind: TButton;
    procedure btFindClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ShowThumbnail(bimg: TBytes);
  end;

var
  fmExifQuery: TfmExifQuery;

implementation

{$R *.dfm}

procedure TfmExifQuery.btFindClick(Sender: TObject);
type
  Qprop = (Q,P,S);
  procedure setquery(src: string; prop: Qprop);
  begin
     case prop of
     Q: if FDMongoQuery1.QMatch <> src  then FDMongoQuery1.QMatch := src;
     P: if FDMongoQuery1.QProject <> src  then FDMongoQuery1.QProject := src;
     S: if FDMongoQuery1.QSort <> src  then FDMongoQuery1.QSort := src;
     end;
  end;
begin
  FDMongoQuery1.Active:= false;
  setquery(LabeledEdit1.Text,Q);
  setquery(LabeledEdit2.Text,P);
  setquery(LabeledEdit3.Text,S);
  FDMongoQuery1.FetchOptions.RecsMax:=SpinEdit1.Value;
  FDMongoQuery1.Active:= True;
end;

procedure TfmExifQuery.ShowThumbnail(bimg: TBytes);
begin
 //
end;

end.
