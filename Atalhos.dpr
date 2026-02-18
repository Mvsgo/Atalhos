program Atalhos;

uses
  Vcl.Forms,
  UnitMain in 'UnitMain.pas' {FormMain},
  Vcl.Themes,
  Vcl.Styles,
  UnitAddShortcut in 'UnitAddShortcut.pas' {FormAddShortcut};

{$R *.res}

begin
  Application.Initialize;
  Application.ShowMainForm := False;
  //TStyleManager.TrySetStyle('Amakrits');
  Application.MainFormOnTaskbar := True;
  //TStyleManager.TrySetStyle('Windows10');
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
