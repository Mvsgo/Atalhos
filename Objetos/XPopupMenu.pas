unit XPopupMenu;
(*
Source - https://stackoverflow.com/a
Posted by Shambhala, modified by community. See post 'Timeline' for change history
Retrieved 2025-12-18, License - CC BY-SA 3.0
*)

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Vcl.Menus, Vcl.ActnList; //Vcl.ActnPopup;

type
  THackItem = class(TMenuItem);

  TMenuRightClickEvent = procedure (Sender: TObject; Item: TMenuItem) of object;

  TXPopupList = class(TPopupList)
  protected
    procedure WndProc(var Message: TMessage); override;
  end;

  TXPopupMenu = class(TPopupMenu)
  private
    FOnMenuRightClick: TMenuRightClickEvent;
  protected
    function DispatchRC(aHandle: HMENU; aPosition: Integer): Boolean;
    procedure RClick(aItem: TMenuItem);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Popup(X, Y: Integer); override;
    procedure OverPopupMenu(pMenu:TPopupMenu);
    procedure MenuRepaint(itemId:integer);
  published
    property OnMenuRightClick: TMenuRightClickEvent read FOnMenuRightClick write FOnMenuRightClick;
  end;

procedure Register;

var
  XPopupList: TXPopupList;

implementation

procedure Register;
begin
  RegisterComponents('Local', [TXPopupMenu]);
end;

{ TXPopupList }

procedure TXPopupList.WndProc(var Message: TMessage);
var i: Integer;
  pm: TPopupMenu;
  MenuItem :TMenuItem;

  SaveIndex: Integer;
  DC: HDC;
  Canvas: TCanvas;

  LWidth, LHeight: Integer;

begin
   if Message.Msg = WM_MENURBUTTONUP then begin
     for i := 0 to Count - 1 do
     begin
       pm := TPopupMenu(Items[i]);
       if pm is TXPopupMenu then
         if TXPopupMenu(Items[i]).DispatchRC(Message.lParam, Message.wParam) then exit
     end;
   end;
   inherited WndProc(Message);
end;

{ TXPopupMenu }

constructor TXPopupMenu.Create(AOwner: TComponent);
begin
  inherited;

  //PopupList.Remove(Self);
  //XPopupList.Add(Self);

  //PopupList.Remove(Self);
  XPopupList.Add( Self );
  //PopupList.Remove(Self);

end;

destructor TXPopupMenu.Destroy;
begin
  XPopupList.Remove(Self);
  PopupList.Remove(Self);
  //PopupList.Add(Self);
  inherited;
end;

(*
function TXPopupMenu.DispatchRC(aHandle: HMENU; aPosition: Integer): Boolean;
begin
  Result := False;
  if Handle = aHandle then
  begin
    RClick(Items[aPosition]);
    Result := True;
  end;
end;
*)

Function TXPopupMenu.DispatchRC(aHandle: HMENU; aPosition: Integer): Boolean;
var FParentItem: TMenuItem;
begin
  Result := False;
  if Handle = aHandle then
    FParentItem := Items
  else
    FParentItem := FindItem(aHandle, fkHandle);

  if FParentItem <> nil then
  begin
    RClick(FParentItem.Items[aPosition]);
    Result := True;
   end;
end;

procedure TXPopupMenu.MenuRepaint(itemId:integer);
var
  I:integer;
  MenuItem: TMenuItem;
  Canvas: TCanvas;
  SaveIndex: Integer;
  DC: HDC;
begin
  //THackItem(Self).MenuChanged(True);
  with PDrawItemStruct(itemId)^ do
  begin
    for I := 0 to XPopupList.Count - 1 do
    begin
      MenuItem := TPopupMenu(Items[I]).FindItem(itemID, fkCommand);
      if MenuItem <> nil then
      begin
        Canvas := TControlCanvas.Create;
        with Canvas do
        try
          SaveIndex := SaveDC(hDC);
          try
            Handle := hDC;
            Font := Screen.MenuFont;
            DrawMenuItem(MenuItem, Canvas, rcItem, TOwnerDrawState(LoWord(itemState)));
          finally
            Handle := 0;
            RestoreDC(hDC, SaveIndex);
          end;
        finally
          Canvas.Free;
        end;
        Exit;
      end;
    end;
  end;
end;

procedure TXPopupMenu.OverPopupMenu(pMenu: TPopupMenu);
var vCmd: UINT;
begin
  LongBool(vCmd) := TrackPopupMenuEx(pMenu.Handle,
                                     TPM_RECURSE or TPM_BOTTOMALIGN or TPM_RETURNCMD,// or TPM_RIGHTBUTTON, para aceitar RButton
                                     Mouse.CursorPos.X,
                                     Mouse.CursorPos.Y,
                                     XPopupList.Window,
                                     nil);
  if vCmd <> 0 then
    pMenu.DispatchCommand(vCmd);
end;

procedure TXPopupMenu.Popup(X, Y: Integer);
const
  Flags: array[Boolean, TPopupAlignment] of Word =
    ((TPM_LEFTALIGN, TPM_RIGHTALIGN, TPM_CENTERALIGN),
    (TPM_RIGHTALIGN, TPM_LEFTALIGN, TPM_CENTERALIGN));
  //Buttons: array[TTrackButton] of Word = (TPM_RIGHTBUTTON, TPM_LEFTBUTTON);
var
  AFlags: Integer;
begin
  DoPopup(Self);
  AFlags := Flags[UseRightToLeftAlignment, Alignment] {or Buttons[TrackButton]};
  if (Win32MajorVersion > 4) or ((Win32MajorVersion = 4) and (Win32MinorVersion > 0)) then
  begin
    AFlags := AFlags or (Byte(MenuAnimation) shl 10);
    AFlags := AFlags or TPM_RECURSE;
  end;
  TrackPopupMenuEx(Items.Handle, AFlags, X, Y, XPopupList.Window, nil);
end;

procedure TXPopupMenu.RClick(aItem: TMenuItem);
begin
  if Assigned (FOnMenuRightClick) then begin
    FOnMenuRightClick(Self, aItem);
  end;
end;

initialization
  XPopupList := TXPopupList.Create;
finalization
  XPopupList.Free;

end.

