unit ufrmNotification;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Gradient, StdCtrls, Contnrs, ExtCtrls;

type
  TFadeType = (ftFadeIn, ftFadeOut);
  
  TfrmNotification = class(TForm)
    Gradient1: TGradient;
    lblTitle: TLabel;
    lblDescription: TLabel;
    tmrLifetime: TTimer;
    tmrFade: TTimer;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormClick(Sender: TObject);
    procedure tmrLifetimeTimer(Sender: TObject);
    procedure tmrFadeTimer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    FBirthTime : TDateTime;

    FFadeType : TFadeType;
    FFadeValue : Integer;

    Procedure Fade(FadeType : TFadeType);
  Protected
    Procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public declarations }
    constructor Create(AOwner : TComponent; Title, Description : String); reintroduce;
    procedure Show; reintroduce;

    property BirthTime : TDateTime read FBirthTime;

    class function Factory(Title, Description : String) : TfrmNotification;
  end;

implementation

{$R *.DFM}

Uses
  uMain,
  uNotificationList;

Const
  lwColorKey : Integer = $1;
  lwAlpha : Integer = $2;

  FADE_MIN : Integer = 0;  
  FADE_MAX : Integer = 200;

Var
  Notifications : TNotificationList;

Function SetLayeredWindowAttributes(Hwnd : THandle; crKey : Integer; Alpha : Byte; dwFlags : LongWord) : Boolean; stdcall; External user32;

{ TfrmNotification }

procedure TfrmNotification.CreateParams(var Params: TCreateParams);
Const
  WS_EX_LAYERED : Cardinal = $80000;
begin
  inherited;
  With Params Do
  Begin
    // WS_EX_APPWINDOW - Show its own taskbar button.
    // WS_EX_TOPMOST - Really topmost, not Delphi's crap version.
    // WS_EX_LAYERED - Enable translucent form.
    ExStyle := ExStyle Or
//      WS_EX_APPWINDOW Or
      WS_EX_TOPMOST Or
      WS_EX_LAYERED;

    // No title bar on the Window.
    ExStyle := ExStyle And Not WS_CAPTION;

    WndParent := Application.Handle; // GetDesktopWindow();
  End;
end;

Constructor TfrmNotification.Create(AOwner : TComponent; Title, Description : String);
Begin
  Inherited Create(AOwner);
  lblTitle.Caption := Title;
  lblDescription.Caption := Description;
  FBirthTime := Now();
  FFadeValue := 0;
End;

procedure TfrmNotification.Show;
begin
  ShowWindow(Handle, SW_SHOWNOACTIVATE);
  SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE + SWP_NOMOVE + SWP_NOSIZE);
  tmrLifetime.Enabled := True;

  Fade(ftFadeIn);
end;

procedure TfrmNotification.FormClick(Sender: TObject);
begin
  Close();
end;

procedure TfrmNotification.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmMain.Log('Removing notification at pos %d.', [Top]);
  Notifications.Remove(Self);
  
  Release();
end;

procedure TfrmNotification.tmrLifetimeTimer(Sender: TObject);
Var
  pt : TPoint;
  lii : tagLASTINPUTINFO;
begin
  // Check if the cursor is inside this notification.
  GetCursorPos(pt);
  If (PtInRect(Self.BoundsRect, pt)) Then
  Begin
    // Wait a further 1.5 seconds.
    tmrLifetime.Interval := 1500;
    Exit;
  End;

  // Check the computer idle time.
  ZeroMemory(@lii, SizeOf(lii));
  lii.cbSize := SizeOf(lii);
  If (GetLastInputInfo(lii)) Then
  Begin
    // Don't close. Wait for a click.
    If (GetTickCount() - lii.dwTime > 60000) Then
    Begin
      tmrLifetime.Enabled := False;
      Exit;
    End;
  End;


  Self.Close();
end;

class function TfrmNotification.Factory(Title, Description : String): TfrmNotification;
Var
  i, x, y : Integer;
  InnerList : TList;
  FoundPos : Boolean;
begin
  InnerList := Notifications.LockList();

  frmMain.Log('Creating new notification', []);

  Result := TfrmNotification.Create(Nil, Title, Description);

  x := Screen.Width - Result.Width - 8;
  y := 8;

  FoundPos := False;
  
  While (Not FoundPos) Do
  Begin
    // Initialise for each loop.
    FoundPos := True;

    // Loop over all existing notifications.
    For i := 0 To InnerList.Count - 1 Do
    Begin
      // If there's one at this pos, increment and restart.
      If (TfrmNotification(InnerList.Items[i]).Top = y) And
         (TfrmNotification(InnerList.Items[i]).Left = x) Then
      Begin
        Inc(y, Result.Height + 8);

        If (y + Result.Height >= Screen.Height) Then
        Begin
          y := 8;
          x := x - Result.Width - 8;
        End;

        FoundPos := False;
        Break; {Flee the for, no need to check the rest}
      End; {If}
    End; {For}
  End; {While}

  Result.Left := x;
  Result.Top := y;

  InnerList.Add(Result);
  Notifications.UnlockList();

  Result.Show();
end;

procedure TfrmNotification.Fade(FadeType: TFadeType);
begin
  FFadeType := FadeType;
  tmrFade.Enabled := True;
end;

procedure TfrmNotification.tmrFadeTimer(Sender: TObject);
begin
  If (FFadeType = ftFadeIn) Then
    Inc(FFadeValue, 2)
  Else
    Dec(FFadeValue, 2);

  SetLayeredWindowAttributes(Handle, 0, FFadeValue, lwAlpha);

  If (FFadeValue <= FADE_MIN) Or
     (FFadeValue >= FADE_MAX) Then
    tmrFade.Enabled := False;

  If (FFadeValue <= FADE_MIN) Then
    Close();
end;

procedure TfrmNotification.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := (FFadeValue <= FADE_MIN);

  If (Not CanClose) Then
    Fade(ftFadeOut);
end;

Initialization
  Notifications := TNotificationList.Create();

Finalization
  Notifications.Free();

end.
