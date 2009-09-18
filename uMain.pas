unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IdGlobal, IdBaseComponent, IdComponent, IdUDPBase, IdUDPServer,
  IdSocketHandle, ufrmNotification, ExtCtrls, IdUDPClient;

type
  TfrmMain = class(TForm)
    IdUDPServer1: TIdUDPServer;
    lstLog: TListBox;
    btnTest: TButton;
    btnDelayedTest: TButton;
    Timer1: TTimer;
    btnClearLog: TButton;
    Button1: TButton;
    IdUDPClient1: TIdUDPClient;
    procedure FormCreate(Sender: TObject);
    procedure IdUDPServer1Status(ASender: TObject;
      const AStatus: TIdStatus; const AStatusText: String);
    procedure IdUDPServer1UDPRead(Sender: TObject; AData: TBytes;
      ABinding: TIdSocketHandle);
    procedure btnTestClick(Sender: TObject);
    procedure btnDelayedTestClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure btnClearLogClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FLogFile : TFileStream;
  public
    { Public declarations }
    Procedure Log(s: String; a : Array Of Const);
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.DFM}

Uses
  uGrowlTypes,
  uLibWinGrowlMain,
  uMutableGrowlRegistrationPacket,
  uMutableGrowlNotificationPacket,
  md5;

Function GetRegistrationPacket() : TMutableGrowlRegistrationPacket; External 'LibWinGrowl.dll';
Function GetNotificationPacket() : TMutableGrowlNotificationPacket; External 'LibWinGrowl.dll';

{ TForm1 }

procedure TfrmMain.Log(s: String; a : Array Of Const);
Var
  LogStr : String;
begin
  LogStr := Format(s, a);
  lstLog.Items.Add(LogStr);
  lstLog.ItemIndex := lstLog.Items.Count - 1;

  LogStr := LogStr+#13#10;
  FLogFile.WriteBuffer(LogStr[1], Length(LogStr));
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FLogFile := TFileStream.Create('Log.txt', fmCreate);
  IdUDPServer1.Active := True;
end;

procedure TfrmMain.IdUDPServer1Status(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: String);
begin
  Log(AStatusText, []);
end;

procedure TfrmMain.IdUDPServer1UDPRead(Sender: TObject; AData: TBytes; ABinding: TIdSocketHandle);
Var
  GPacket : TGrowlPacket;
  RegPacket : TGrowlRegistrationPacket;
  NotPacket : TGrowlNotificationPacket;
begin
  GPacket := Nil;
  RegPacket := Nil;
  NotPacket := Nil;
  
  Try
    Log('Received a %d byte packet:', [Length(AData)]);
    Log('%s', [BytesToString(AData)]);
    GPacket := TGrowlPacket.Create(AData, 'password');

    Case GPacket.Header.PacketType Of
      GROWL_TYPE_REGISTRATION: Begin
        RegPacket := GPacket.GetRegistractionPacket();
        Log('Got a reg packet from %s', [RegPacket.AppName]);
        Log('Notifications: '#13#10+RegPacket.Notifications.Text, []);
      End;

      GROWL_TYPE_NOTIFICATION: Begin
        Log('Got a notify packet', []);
        NotPacket := GPacket.GetNotificationPacket();
        TfrmNotification.Factory(NotPacket.Title+' - '+NotPacket.Notification, NotPacket.Description);
      End;
    End; {Case}
  Except
    On E: Exception Do
    Begin
      Log('Exception: %s', [E.Message]);
      
      If (GPacket <> Nil) Then
        GPacket.Free();

      If (RegPacket <> Nil) Then
        RegPacket.Free();

      If (NotPacket <> Nil) Then
        NotPacket.Free();
    End;
  End;
end;

procedure TfrmMain.btnTestClick(Sender: TObject);
begin
  TfrmNotification.Factory('Test', 'Testing the growl');
end;

procedure TfrmMain.btnDelayedTestClick(Sender: TObject);
begin
  Timer1.Enabled := True;
end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  btnTest.Click();
end;

procedure TfrmMain.btnClearLogClick(Sender: TObject);
begin
  lstLog.Clear();
end;

procedure TfrmMain.Button1Click(Sender: TObject);
Var
  Reg : TMutableGrowlRegistrationPacket;
  Notif : TMutableGrowlNotificationPacket;
  s : String;
  Stream : TStream;
begin
  Reg := GetRegistrationPacket();
  Stream := Reg.GetPacket();
  SetLength(s, Stream.Size);
  Stream.ReadBuffer(s[1], Stream.Size);
  IdUDPClient1.Send('127.0.0.1', 9887, s);
  Stream.Free();
  Reg.Free();

  Notif := GetNotificationPacket();
  Stream := Notif.GetPacket();
  SetLength(s, Stream.Size);
  Stream.ReadBuffer(s[1], Stream.Size);
  IdUDPClient1.Send('127.0.0.1', 9887, s);
  Stream.Free();
  Notif.Free();
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FLogFile.Free();
end;

end.
