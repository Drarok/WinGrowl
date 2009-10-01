object frmMain: TfrmMain
  Left = 234
  Top = 121
  Width = 483
  Height = 460
  Caption = 'Main'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lstLog: TListBox
    Left = 8
    Top = 8
    Width = 369
    Height = 409
    ItemHeight = 13
    TabOrder = 0
  end
  object btnTest: TButton
    Left = 384
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Test'
    TabOrder = 1
    OnClick = btnTestClick
  end
  object btnDelayedTest: TButton
    Left = 384
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Delayed Test'
    TabOrder = 2
    OnClick = btnDelayedTestClick
  end
  object btnClearLog: TButton
    Left = 384
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Clear Log'
    TabOrder = 3
    OnClick = btnClearLogClick
  end
  object btnTestDLL: TButton
    Left = 384
    Top = 128
    Width = 75
    Height = 25
    Caption = 'Test DLL'
    TabOrder = 4
    OnClick = btnTestDLLClick
  end
  object btnUDPTest: TButton
    Left = 384
    Top = 160
    Width = 75
    Height = 25
    Caption = 'UDP Test'
    TabOrder = 5
    OnClick = btnUDPTestClick
  end
  object IdUDPServer1: TIdUDPServer
    Bindings = <>
    DefaultPort = 9887
    OnUDPRead = IdUDPServer1UDPRead
    Left = 48
    Top = 16
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 2500
    OnTimer = Timer1Timer
    Left = 384
    Top = 72
  end
  object IdUDPClient1: TIdUDPClient
    Port = 0
    Left = 72
    Top = 152
  end
end
