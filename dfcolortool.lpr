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

program dfcolortool;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, LResources
  { you can add units after this }, Unit1, TurboPowerIPro, UnitSettings,
UnitInfo;

{$IFDEF WINDOWS}{$R dfcolortool.rc}{$ENDIF}

begin
  {$I dfcolortool.lrs}
  Application.Title:='Zandrus Dragon-Fantasies-Colortool';
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TFormConfig, FormConfig);
  Application.CreateForm(TFormInfo, FormInfo);
  Application.Run;
end.

