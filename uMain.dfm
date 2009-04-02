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
  object Button1: TButton
    Left = 384
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 384
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Button2'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 384
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Button3'
    TabOrder = 3
    OnClick = Button3Click
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
end
