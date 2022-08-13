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

unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Menus, SynHighlighterHTML, LazHelpHTML, ExtCtrls, Buttons, IpHtml,
  Ipfilebroker, IniFiles, LCLType, StrUtils, SynRegExpr;

type

  { TForm1 }

  TForm1 = class(TForm)
    btn_b: TSpeedButton;
    btn_c: TSpeedButton;
    btn_c1: TSpeedButton;
    btn_c2: TSpeedButton;
    btn_i: TSpeedButton;
    btn_u: TSpeedButton;
    chk_defcol: TCheckBox;
    chk_preview: TCheckBox;
    cbx_colors: TComboBox;
    cbx_defcol: TComboBox;
    ImageList_menu: TImageList;
    IpFileDataProvider1: TIpFileDataProvider;
    Label1: TLabel;
    MenuItem_datei_export: TMenuItem;
    MenuItem_rpsplitter: TMenuItem;
    MenuItem_edit_breaks: TMenuItem;
    MenuItem_edit: TMenuItem;
    MenuItem_hilfe_info: TMenuItem;
    MenuItem_bbc_hr: TMenuItem;
    MenuItem_bbc_sub: TMenuItem;
    MenuItem_bbc_center: TMenuItem;
    MenuItem_bbc_right: TMenuItem;
    MenuItem_bbc_img: TMenuItem;
    MenuItem_einfgen: TMenuItem;
    MenuItem_bbc_br: TMenuItem;
    MenuItem_bbc_b: TMenuItem;
    MenuItem_bbc_i: TMenuItem;
    MenuItem_bbc_u: TMenuItem;
    MenuItem_bbc_s: TMenuItem;
    MenuItem_bbc_big: TMenuItem;
    MenuItem_bbc_small: TMenuItem;
    MenuItem_bbc_sup: TMenuItem;
    OpenDialog1: TOpenDialog;
    pnl_menu: TPanel;
    Preview: TIpHtmlPanel;
    MainMenu: TMainMenu;
    Plaintext: TMemo;
    MenuItem_datei_quit: TMenuItem;
    MenuItem_datei_config: TMenuItem;
    MenuItem_datei_saveas: TMenuItem;
    MenuItem_datei_save: TMenuItem;
    MenuItemdatei_open: TMenuItem;
    MenuItem_hilfe: TMenuItem;
    MenuItem_bbcode: TMenuItem;
    MenuItem_datei: TMenuItem;
    MenuItem_datei_new: TMenuItem;
    SaveDialog1: TSaveDialog;
    SaveDialog_html: TSaveDialog;
    procedure btn_nClick(Sender: TObject);
    procedure MenuItem_datei_exportClick(Sender: TObject);
    procedure splittRp(Sender: TObject);
    procedure buttonClick(Sender: TObject);
    procedure cbx_colorsChange(Sender: TObject);
    procedure chk_defcolChange(Sender: TObject);
    procedure chk_previewChange(Sender: TObject);
    procedure DrawColorMenu(Control: TWinControl; Index: Integer; ARect: TRect;
      State: TOwnerDrawState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure OpenConfig(Sender: TObject);
    procedure MenuItem_datei_saveasClick(Sender: TObject);
    procedure MenuItem_datei_saveClick(Sender: TObject);
    procedure MenuItem_hilfe_infoClick(Sender: TObject);
    procedure PlaintextKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PutBBCode(Sender: TObject);
    procedure MenuItemdatei_openClick(Sender: TObject);
    procedure MenuItem_datei_newClick(Sender: TObject);
    procedure MenuItem_datei_quitClick(Sender: TObject);
    procedure fileChanged(Sender: TObject=nil);
  private
    { private declarations }
    function convertToHtml(aStr: AnsiString): AnsiString;
    procedure LoadStringToPreview(str: AnsiString);
    function saveIfModified:Boolean;
    procedure InsertText(Sender: TObject);
    function LastPos(needle, haystack: string): integer;
  public
  	procedure BuildInsertMenu;
    { public declarations }
  end; 

	TDFColor = Record
		tag: String;
    color: TColor
  end;

  TSettings = Record
  	defaultColor, saveBehaviour: integer;
  end;

	TInsert = Record
  	Key, Value: String;
  end;


const
  MainFormTitle = 'Zandrus Dragon-Fantasies Colortool';
  DefaultFilename = 'unbenannt.txt';
  MaxCharsPerPost = 385; // für RP-Splitter

var
  Form1: TForm1;
  dfColors: Array of TDFColor;
	cfg: TSettings;
  bbcode:Array[0..8] of String;
  dfcode_buic:Array[0..4,0..2] of String;
  OffeneDatei: String = '';
  Inserts: Array of TInsert;

implementation

uses UnitSettings, UnitInfo;

{ TForm1 }

function TForm1.convertToHtml(aStr: AnsiString): AnsiString;
  function ColorToHTMLColor(Color: TColor): String;
  var
    C: packed record case Integer of
         0: (Int: LongInt);
         1: (B0, B1, B2, B3: Byte);
      end;
    H: Byte;
  begin
    // convert negative (SysColor) values like clBtnFace
    C.Int := ColorToRGB(Color);
    // red value of TColor is in byte 0, of HTML in byte 2: swap
    H := C.B0;
    C.B0 := C.B2;
    C.B2 := H;
    // output hex value
    Result := Format('#%.6x', [C.Int]);
  end; {Michael Winter}

var
  i, opentag:integer;
begin
  // HTML entfernen
  //aStr := StringReplace(aStr,'&','&amp;',[rfReplaceAll]);
  aStr := StringReplace(aStr,'<','&lt;',[rfReplaceAll]);
  aStr := StringReplace(aStr,'>','&gt;',[rfReplaceAll]);

  // Zeilenumbrüche
  aStr := StringReplace(aStr,'`n','<br />',[rfReplaceAll]);

  // BBCode
  // einfache Tags (aus derm array bbcode)
  for i := 0 to high(bbcode) do begin
    aStr := StringReplace(aStr,'['+bbcode[i]+']','<'+bbcode[i]+'>',[rfReplaceAll]);
    aStr := StringReplace(aStr,'[/'+bbcode[i]+']','</'+bbcode[i]+'>',[rfReplaceAll]);
  end;

  // kompliziertere Tags
  aStr := StringReplace(aStr,'[hr]','<hr />',[rfReplaceAll]);
  aStr := StringReplace(aStr,'[br]','<br />',[rfReplaceAll]);

  aStr := StringReplace(aStr,'[right]','<div align="right">',[rfReplaceAll]);
  aStr := StringReplace(aStr,'[/right]','</div>',[rfReplaceAll]);

  //aStr := StringReplace(aStr,'[img]','<img src="',[rfReplaceAll]);
  //aStr := StringReplace(aStr,'[/img]','" />',[rfReplaceAll]);
  aStr := StringReplace(aStr,'[img]','<font color="#FFFFFF">BILDVORSCHAU TUT LEIDER NOCH NICHT [',[rfReplaceAll]);
  aStr := StringReplace(aStr,'[/img]',']</font>',[rfReplaceAll]);


  // Farben
  for i := 0 to high(dfColors) do begin
    aStr := StringReplace(aStr, dfColors[i].tag, '<font color="'+ ColorToHTMLColor(dfColors[i].color) +'">', [rfReplaceAll]);
  end;

  opentag := 1;
  for i := 0 to 4 do begin
    while pos(dfcode_buic[i,0],aStr) <> 0 do begin
      aStr := StringReplace(aStr,dfcode_buic[i,0],dfcode_buic[i,opentag],[]);

      if opentag = 1 then opentag := 2
      else opentag := 1;
    end
  end;


  // Teruk-/Srek-/Bown-Bild -- Deaktiviert, da das TIpHtmlPanel die Bidler nicht anzeigt
  {aStr := StringReplace(aStr,'`(','<img src="http://www.dragonfantasies.de/images/teruk.gif">',[rfReplaceAll]);
  aStr := StringReplace(aStr,'`|','<img src="http://www.dragonfantasies.de/images/srek.gif">',[rfReplaceAll]);
  aStr := StringReplace(aStr,'`_','<img src="http://www.dragonfantasies.de/images/bown.gif">',[rfReplaceAll]);}


  // HTML-Seite zusammensetzten und zurückgeben...
  Result := '<html><head><title>DF-Colortool Vorschau</title></head><body bgcolor="#000000">' +
              aStr + '</body></html>';
end;

procedure TForm1.LoadStringToPreview(str: AnsiString);
var
  html: TIpHtml;
  ms:TMemoryStream;
begin
  html:=TIpHtml.Create;
  ms:=TMemoryStream.Create;
  ms.Write(str[1],Length(str));
  ms.Position:=0;
  html.LoadFromStream(ms);
  Preview.SetHtml(html);
  ms.free;
  //html.free; kackt ab
end;


function TForm1.saveIfModified:Boolean; // false, wenn Cancel
begin
  if Plaintext.Modified then
  begin
    case MessageDlg(Format('Änderung speichern in %s?', [OffeneDatei]), mtConfirmation,
                   [mbYes, mbNo, mbCancel], 0) of
      idYes: begin MenuItem_datei_saveClick(Self); Result := true; end;
      idNo: Result := true;
      idCancel: Result := false;
    end;
  end
  else
  	Result := true;
end;


procedure TForm1.fileChanged(Sender: TObject=nil);
var mdfd: String;
begin
 // Form-Titel mit aktuellem Dateiname
  // Modified-Sternchen
  if Plaintext.Modified then mdfd := '*'
  else mdfd := '';

  //if OffeneDatei <> '' then
    Caption := MainFormTitle + ' | ' + ExtractFileName(OffeneDatei) + mdfd;

  if chk_preview.Checked = true then
		LoadStringToPreview( convertToHtml(Plaintext.Text) );
end;


procedure TForm1.InsertText(Sender: TObject);
begin
   Plaintext.SelText := (Sender as TMenuItem).Hint;
end;


procedure TForm1.BuildInsertMenu;
var
  myMenuItems: Array of TMenuItem;
  insertshortcut:Word;
  i:integer;
begin
	MenuItem_einfgen.Clear;
  setLength(myMenuItems, length(Inserts)+2);
  for i:=0 to High(Inserts) do begin
    myMenuItems[i] := TMenuItem.Create(self);
    myMenuItems[i].Caption := Inserts[i].Key;
    myMenuItems[i].Hint := Inserts[i].Value;
    myMenuItems[i].OnClick := @InsertText;
    if i < 9 then
    	myMenuItems[i].ShortCut := ShortCut(49+i, [ssCtrl]) // Word 49 = Char '1'
    else if i = 9 then
    	myMenuItems[i].ShortCut := ShortCut(Word('0'), [ssCtrl]);

    MenuItem_einfgen.Add(myMenuItems[i]);
  end;

  // Trennbalken
  i := High(myMenuItems)-1;
  myMenuItems[i] := TMenuItem.Create(self);
  myMenuitems[i].Caption := '-';
  MenuItem_einfgen.Add(myMenuItems[i]);
  // "Konfigurieren"
  i := i+1;
  myMenuItems[i] := TMenuItem.Create(self);
  myMenuItems[i].Caption := 'Konfigurieren...';
  myMenuItems[i].Tag := 1;
  myMenuItems[i].OnClick := @OpenConfig;
  MenuItem_einfgen.Add(myMenuItems[i]);
end;

procedure TForm1.MenuItem_datei_newClick(Sender: TObject);
begin
  // gegebenenfalls offene Datei speichern
  case cfg.saveBehaviour of
    // Normale Sicherheitsabfrage
    0:  if (Plaintext.Modified = true) AND (saveIfModified() = false)
        then exit;

    // nur wenn Datei geöffnet
    1:  if (OffeneDatei <> '') AND (Plaintext.Modified = true) AND (saveIfModified() = false)
        then exit;
  end;

  OffeneDatei := '';
  Plaintext.Clear;
  Plaintext.Modified:=false;
  fileChanged();
end;

procedure TForm1.MenuItem_datei_quitClick(Sender: TObject);
begin
  close;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  ini: TIniFile;
  inipath: String;
  colorlist: TStrings;
  i: integer;

  tstrInserts: TStrings;
begin

  // Farben aus cbx_colors.ini laden
  colorlist := TStringList.Create;
  inipath := ExtractFilePath(ParamStr(0));
  ini:=TIniFile.Create(inipath+'colors.ini');
  try
    ini.ReadSectionValues('colors', colorlist);
    for i := 0 to colorlist.Count-1 do begin
      SetLength(dfColors,i+1);
      dfColors[i].color := StringToColor(Copy(colorlist[i],0,Pos('=',colorlist[i])-1));
      dfColors[i].tag   := Copy(colorlist[i],Pos('=',colorlist[i])+1,Length(colorlist[i]));
    end;
  finally
    ini.free;
  end;

  // Einstellungen aus config.ini laden
  ini:=TIniFile.Create(inipath+'config.ini');
  try
    cfg.saveBehaviour := ini.ReadInteger('config','savequest',0);
    cfg.defaultColor  := ini.ReadInteger('config','defcol',-1);

    tstrInserts := TStringList.Create;
    ini.ReadSectionValues('inserts', tstrInserts);
  finally
    ini.free;
  end;

  // Farben-Menüs füllen
  // Es wird einfach durchnummeriert, der Wert ist im Grund egal, da die Farben
  // eh seperat über das OnDrwaItem-Event eingefügt werden. Es muss nur sichergestellt
  // sein, das jedes Feld einen (caseINsensitiven) eindeutigen Wert hat, daher
  // können nicht die Tags verwendet werden (Problem bei defdefcol mit zB `e und `E)
  for i := 0 to High(dfColors) do begin
    cbx_colors.Items.Add(inttostr(i));
    cbx_defcol.Items.Add(inttostr(i));
  end;

  // defaultColor nach Settings setzten
  if cfg.defaultColor = -1 then
  	chk_defcol.Checked:=false
  else begin
  	chk_defcol.Checked:=true;
    cbx_defcol.ItemIndex:=cfg.defaultColor;
  end;

  // einfache BBCode-Tags in Array
  bbcode[0] := 'i';
  bbcode[1] := 'u';
  bbcode[2] := 's';
  bbcode[3] := 'b';
  bbcode[4] := 'big';
  bbcode[5] := 'small';
  bbcode[6] := 'sup';
  bbcode[7] := 'sub';
  bbcode[8] := 'center';

  // DF-Code: Fett, Unterstr., Zentiert...
  dfcode_buic[0,0] := '`b';
  dfcode_buic[0,1] := '<b>';
  dfcode_buic[0,2] := '</b>';

  dfcode_buic[1,0] := '`u';
  dfcode_buic[1,1] := '<u>';
  dfcode_buic[1,2] := '</u>';

  dfcode_buic[2,0] := '`i';
  dfcode_buic[2,1] := '<i>';
  dfcode_buic[2,2] := '</i>';

  dfcode_buic[3,0] := '`c';
  dfcode_buic[3,1] := '<div align="center">';
  dfcode_buic[3,2] := '</div>';

  //FIXME: justify doesnt work :(
  dfcode_buic[4,0] := '`-';
  dfcode_buic[4,1] := '<div align="justify">';
  dfcode_buic[4,2] := '</div>';

  // Inserts
  if tstrInserts.Count > 0 then begin
    setLength(Inserts, tstrInserts.Count);
    for i:=0 to tstrInserts.Count-1 do begin
    	Inserts[i].Key := Copy(tstrInserts[i], 0, pos('=',tstrInserts[i])-1);
      Inserts[i].Value  := Copy(tstrInserts[i], pos('=',tstrInserts[i])+1, Length(tstrInserts[i])-pos('=',tstrInserts[i])+1);
    end;
    BuildInsertMenu();
  end;


  // Vorschau-Fenster:
  LoadStringToPreview('<html><head><title>DF-Colortool Vorschau</title></head><body bgcolor="#000000"></body></html>');
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
  // Alt+C: Alles markieren und kopieren
  if(Shift = [ssAlt]) AND (Key = 67) then begin
    Plaintext.SelectAll;
    Plaintext.CopyToClipboard;
  end;

  // F2: Vorschau an/aus
  if Key = VK_F2 then begin
    chk_preview.Checked := not chk_preview.Checked;
    //chk_previewClick(Sender);
  end
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  if chk_preview.Checked = true then
		Preview.Height := round((Form1.ClientHeight - 25) - 0.5 * (Form1.ClientHeight - 25));
end;

procedure TForm1.OpenConfig(Sender: TObject);
begin
 FormConfig.PageControl1.ActivePageIndex := (Sender as TComponent).Tag;
 FormConfig.Show;
end;

procedure TForm1.MenuItem_datei_saveasClick(Sender: TObject);
begin
  SaveDialog1.FileName := OffeneDatei;
  if SaveDialog1.Execute then
  begin
		if FileExists(SaveDialog1.FileName) AND
  			(MessageDlg('Es existiert bereits eine Datei mit dem Namen '+SaveDialog1.FileName + #13#10
        						+'Wenn Sie fortfahren wird die bestehende Datei überschrieben.',
    			mtConfirmation, mbOkCancel, 0) = idCancel)
    then exit;

    OffeneDatei := SaveDialog1.FileName;
    MenuItem_datei_saveClick(Sender)
  end
end;

procedure TForm1.MenuItem_datei_saveClick(Sender: TObject);
begin
  if OffeneDatei = '' then
    MenuItem_datei_saveasClick(Sender)
  else
  begin
    Plaintext.Lines.SaveToFile(OffeneDatei);
    Plaintext.Modified := false;
    fileChanged();
  end
end;

procedure TForm1.MenuItem_hilfe_infoClick(Sender: TObject);
begin
  FormInfo.show;
end;

procedure TForm1.PlaintextKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // [VK_INSERT] fügt ` ein
  if Key = VK_INSERT then begin
    Plaintext.SelText := Plaintext.SelText + '`';
    Key := 0;
  end;

  // Bei [Umschalt] + [Enter] `n einfügen
  if (Shift = [ssShift]) AND (Key = VK_RETURN) then begin
    Plaintext.SelText := Plaintext.SelText + '`n';
    Key := 0;
  end;

  // [Strg] + [b|u|i|z] fügt b|u|i|c-Tags ein
  if Shift = [ssCtrl] then begin
    {b} if Key = 66 then buttonClick(btn_b);
    {u} if Key = 85 then buttonClick(btn_u);
    {i} if Key = 73 then buttonClick(btn_i);
    {m} if Key = 77 then buttonClick(btn_c);
  end
end;

procedure TForm1.PutBBCode(Sender: TObject);
var
  strHint, insertstr:String;
  selpos:integer;
begin
  selpos := Plaintext.SelStart;

  strHint := (Sender as TMenuItem).Hint;
  case (Sender as TMenuItem).Tag of
    // hr, br
    1,2: Plaintext.SelText := Plaintext.SelText + '['+strHint+']';

    // rest
    3..13: begin
			insertstr := '['+strHint+']' + Plaintext.SelText + '[/'+strHint+']';
      Plaintext.SelText := insertstr;
      Plaintext.SelStart:= selpos + length(insertstr) - length(strHint)-3; // Markierung vor das [/xy]-Tag setzen
    end;
  end;
  Plaintext.SetFocus;
end;

procedure TForm1.MenuItemdatei_openClick(Sender: TObject);
begin
  // gegebenenfalls offene Datei speichern
  case cfg.saveBehaviour of
    // Normale Sicherheitsabfrage
    0:  if (Plaintext.Modified = true) AND (saveIfModified() = false)
        then exit;

    // nur wenn Datei geöffnet
    1:  if (OffeneDatei <> '') AND (Plaintext.Modified = true) AND (saveIfModified() = false)
        then exit;
  end;

  with OpenDialog1 do begin
    if Execute then begin
      OffeneDatei := FileName;
      try
        with Plaintext do
        begin
          Lines.LoadFromFile(OffeneDatei);
          SelStart := 0;
          Modified := False;
          fileChanged();
        end;
      except
        MessageDlg(OffeneDatei + ' konnte nicht geöffnet werden',mtError,[mbOk],0);
      end
    end
  end
end;

procedure TForm1.DrawColorMenu(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
begin
  // Dropdown-Menüpunkt beim Hinzufügen einfärben
  with (Control as TComboBox).Canvas do begin
    Brush.Style := bsSolid;
    Brush.Color := dfColors[Index].color;
    FillRect(ARect);
    TextOut(ARect.Left+2, ARect.Top, dfColors[Index].tag);
  end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
	CanClose := true;
	case cfg.saveBehaviour of
  // Normale Sicherheitsabfrage
  0:  if (Plaintext.Modified = true) AND (saveIfModified() = false)
      then CanClose := false;

  // nur wenn Datei geöffnet
  1:  if (OffeneDatei <> '') AND (Plaintext.Modified = true) AND (saveIfModified() = false)
      then CanClose := false;
  end
end;

procedure TForm1.chk_defcolChange(Sender: TObject);
begin
  cbx_defcol.Enabled := chk_defcol.Checked;
end;

procedure TForm1.chk_previewChange(Sender: TObject);
begin
  if(chk_preview.Checked = true) then begin
    // Vorschau an
    Preview.Visible:= true;
    FormResize(Self);
    fileChanged(Self);
  end
  else begin
    // Vorschau aus
    Preview.Height := 0;
    Preview.Visible:= false;
  end
end;

procedure TForm1.cbx_colorsChange(Sender: TObject);
begin
	try
    if(chk_defcol.Checked = true) then
      Plaintext.SelText := dfColors[cbx_colors.ItemIndex].tag + Plaintext.SelText + dfColors[cbx_defcol.ItemIndex].tag // FIXME: bugt!!
    else
			Plaintext.SelText := dfColors[cbx_colors.ItemIndex].tag + Plaintext.SelText;
  except end;
  Plaintext.SetFocus;
end;

procedure TForm1.buttonClick(Sender: TObject);
var
  selpos:integer;
  insertstr:String;
begin
	// Tags einfügen und Cursor an das Ende des Markierten Textes
  // aber VOR das schließende Tag setzten:  `btext|`b
  selpos := Plaintext.SelStart;
  insertstr := (Sender as TSpeedButton).Hint + Plaintext.SelText + (Sender as TSpeedButton).Hint;
  Plaintext.SelText  := insertstr;
  Plaintext.SelStart := selpos + length(insertstr) - 2;
  Plaintext.SetFocus;
end;

procedure TForm1.btn_nClick(Sender: TObject);
var i:integer;
begin
  for i := 0 to Plaintext.Lines.Count - 1 do begin
    Plaintext.Lines[i] := Plaintext.Lines[i] + '  `n';
  end;
end;


// Als HTML speichern
procedure TForm1.MenuItem_datei_exportClick(Sender: TObject);
var html: Tstrings;
begin
  if SaveDialog_html.Execute then
  begin
		if FileExists(SaveDialog_html.FileName) AND
  			(MessageDlg('Es existiert bereits eine Datei mit dem Namen '+SaveDialog_html.FileName + #13#10
        						+'Wenn Sie fortfahren wird die bestehende Datei überschrieben.',
    			mtConfirmation, mbOkCancel, 0) = idCancel)
    then exit;

  	html := TStringList.Create;
    html.Text := convertToHtml(Plaintext.Text);
    html.Text := StringReplace(html.Text, '<body bgcolor="#000000">', '<body style="background:#000000; color:#ffffff; font-family: Verdana, Arial, Helvetica, sans-serif; font-size:10pt">', [rfReplaceAll]); // <-- eihgentlich nur ds erste replacen!
    html.SaveToFile(SaveDialog_html.FileName);
  end
end;


function TForm1.LastPos(needle, haystack: string): integer;
begin
	if Pos(needle, ReverseString(haystack)) <> 0 then
		result := length(haystack)+1 - Pos(needle, ReverseString(haystack)) // ReverseString: unit StrUtils
  else
  	result := 0;
end;


procedure TForm1.splittRp(Sender: TObject);
const
	Puffer = 8; // puffer, der für /em<FC>~ ... ~ freigelassen wird
var
	i, lastFcPos:integer;
	splitted, unsplitted, lastFc:string;
begin
	splitted := '';
  unsplitted := Plaintext.Text;

  // Wenn Text zu kurz zum splitten, abbrechen
  if length(unsplitted) <= MaxCharsPerPost - Puffer then begin
		ShowMessage('Der Text ist kurz genug und muss nicht geteilt werden.');
  	exit;
  end;

  if MessageDlg('Soll der Text wirklich in Abschnitte unterteil werden? Die Änderung kann nicht rückgänig gemacht werden!',
  								mtConfirmation, [mbYes, mbNo], 0) = idNo then exit;

	// dopppelte whitespace-zeichen entfernen und trimmen
  unsplitted := trim(ReplaceRegExpr('(\s+)', unsplitted, ' ', false));

  while length(unsplitted) > MaxCharsPerPost - Puffer do begin
		// Letztes Leerzeichen vor der Maxlength-Grenze finden
    for i := MaxCharsPerPost - Puffer downto 1 do
    	if copy(unsplitted, i, 1) = ' ' then
      	break;

    // Wenn kein leerzeichen gefunden wird einfach mitten im Wort umbrechen
    if i = 1 then i := MaxCharsPerPost - Puffer;

		// letzten Farbcode finden
		lastFcPos := LastPos('`', splitted);
    if (lastFcPos <> 0) and (lastFcPos <> length(splitted)) then
			lastFc := copy(splitted, lastFcPos, 2)
    else
			lastFc := '';

    if splitted <> '' then
    	splitted := splitted + '/em'+lastFc+'~ ';

		splitted := splitted + copy(unsplitted, 1, i) + '~' + #13#10#13#10#13#10;
    delete(unsplitted, 1, i);
  end;

  // TODO: den teil irgendwie ohne copy&paste hinkriegen...
	// letzten Farbcode finden
	lastFcPos := LastPos('`', splitted);
  if (lastFcPos <> 0) and (lastFcPos <> length(splitted)) then
			lastFc := copy(splitted, lastFcPos, 2)
  else
			lastFc := '';

	splitted := splitted + '/em'+lastFc+'~ ' + copy(unsplitted, 1, i);

  Plaintext.Text := splitted;
end;

initialization
  {$I unit1.lrs}

end.

