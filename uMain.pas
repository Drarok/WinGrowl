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
    btnTestDLL: TButton;
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
    procedure btnTestDLLClick(Sender: TObject);
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
  md5;

Function CreateRegistrationPacket() : Pointer; External 'LibWinGrowl.dll';
Procedure FreeRegistrationPacket(Packet : Pointer); External 'LibWinGrowl.dll';
Procedure Registration_SetAppName(Packet : Pointer; Name : PChar); External 'LibWinGrowl.dll';
Procedure Registration_AddNotification(Packet : Pointer; Name : PChar; Default : Boolean); External 'LibWinGrowl.dll';
Procedure Registration_SetPassword(Packet : Pointer; Password : PChar); External 'LibWinGrowl.dll';
Procedure Registration_SendPacket(Packet : Pointer; Host : PChar; Port : Integer); External 'LibWinGrowl.dll';

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

procedure TfrmMain.btnTestDLLClick(Sender: TObject);
Var
  p : Pointer;
begin
  p := CreateRegistrationPacket();
  Registration_SetAppName(p, PChar('PHP Notifier'));
  Registration_AddNotification(p, 'Informational', False);
  Registration_AddNotification(p, 'Warning', True);
  Registration_SetPassword(p, PChar('password'));
  Registration_SendPacket(p, PChar('127.0.0.1'), 9887);
  FreeRegistrationPacket(p);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FLogFile.Free();
end;

end.
