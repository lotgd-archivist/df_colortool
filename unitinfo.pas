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

unit UnitInfo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls;

type

  { TFormInfo }

  TFormInfo = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Memo3: TMemo;
    ToolBar1: TToolBar;
    procedure Button1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  FormInfo: TFormInfo;

implementation

{ TFormInfo }

procedure TFormInfo.Button1Click(Sender: TObject);
begin
  hide;
end;

initialization
  {$I unitinfo.lrs}

end.

