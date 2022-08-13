{
Dragonfantasies Colortool - Writing texts for the Browsergame Dragonfantasies
(www.dragonfantasies.de) using color tags

Copyright (C) 2010  Felix Widmaier <widiland@gmail.com>

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin St, Fifth Floor, Boston, MA 02110, USA
}

unit UnitSettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ComCtrls, Buttons, ExtCtrls, Grids, IniFiles;

type

  { TFormConfig }

  TFormConfig = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    cbx_savequest: TComboBox;
    chk_defdef: TCheckBox;
    defdefcol: TComboBox;
    edt_insertlistkey: TLabeledEdit;
    edt_insertlistvalue: TLabeledEdit;
    Label1: TLabel;
    PageControl1: TPageControl;
    SpeedButton1: TSpeedButton;
    InsertList: TStringGrid;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SaveSettings(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { private declarations }
  public
  	procedure addInsertRow(key, value: String);
    { public declarations }
  end; 

var
  FormConfig: TFormConfig;

implementation

uses Unit1;

{ TFormConfig }

procedure TFormConfig.Button2Click(Sender: TObject);
begin
  hide;
end;

procedure TFormConfig.addInsertRow(key, value: String);
var iRow:integer;
begin
  with InsertList do begin
		RowCount := RowCount+1;
    ColCount := 2;
    iRow := RowCount-1;
  	Cells[0, iRow] := key;
  	Cells[1, iRow] := value;
  end;
end;

procedure TFormConfig.Button3Click(Sender: TObject);
begin
  if (Trim(edt_insertlistkey.Text) <> '')
     AND (edt_insertlistvalue.Text <> '') then begin
  	addInsertRow(edt_insertlistkey.Text, edt_insertlistvalue.Text);

    // Eingabefelder löschen
    edt_insertlistkey.Text := '';
    edt_insertlistvalue.Text := '';
  end;
end;

procedure TFormConfig.FormCreate(Sender: TObject);
var i:integer;
begin
  // defdefcol
  for i := 0 to High(dfColors) do begin
    defdefcol.Items.Add(dfColors[i].Tag);
  end;
  defdefcol.OnDrawItem := @Form1.DrawColorMenu;
end;

procedure TFormConfig.FormShow(Sender: TObject);
var i:integer;
begin
  // Speicherabfrage
  cbx_savequest.ItemIndex := cfg.saveBehaviour;

  // defdefcol
  if cfg.defaultColor = -1 then
    chk_defdef.Checked := False
  else
    chk_defdef.Checked := True;
  defdefcol.ItemIndex := cfg.defaultColor;

	// Inserts
  InsertList.RowCount := 0;
  for i:=0 to High(Inserts) do
  	addInsertRow(Inserts[i].key, Inserts[i].value);
end;

procedure TFormConfig.SaveSettings(Sender: TObject);
var
  ini:TIniFile;
  i, defcol_on:integer;
begin
// Einstellungen speichern (in Variablen und in Ini)
  // Speicherabfrage
  cfg.saveBehaviour := cbx_savequest.ItemIndex;

  // Standartfarbe
  if chk_defdef.Checked then
    cfg.defaultColor := defdefcol.ItemIndex
  else
    cfg.defaultColor := -1;

  ini:=TIniFile.Create(ExtractFilePath(ParamStr(0))+'config.ini');
  try
    ini.WriteInteger('config','savequest', cfg.saveBehaviour);
    ini.WriteInteger('config','defcol', cfg.defaultColor);

    // Inserts
    ini.EraseSection('inserts');
    setLength(Inserts, InsertList.RowCount);
    for i := 0 to InsertList.RowCount-1 do begin
    	Inserts[i].Key  := InsertList.Cells[0,i];
      Inserts[i].Value:=InsertList.Cells[1,i];
      ini.WriteString('inserts', Inserts[i].Key, Inserts[i].Value);
    end;
    Form1.BuildInsertMenu;
  finally
    ini.free;
  end;

  Hide;
end;

procedure TFormConfig.SpeedButton1Click(Sender: TObject);
var i: Integer;
begin
  with InsertList do begin
    for i := Row to RowCount-2 do
    Rows[i].Assign(Rows[i+1]);
    RowCount := RowCount - 1
  end;
end;

initialization
  {$I unitsettings.lrs}

end.

