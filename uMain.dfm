object frmMain: TfrmMain
  Left = 234
  Top = 121
  Width = 870
  Height = 640
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
  object IdUDPServer1: TIdUDPServer
    OnStatus = IdUDPServer1Status
    Bindings = <>
    DefaultPort = 9887
    OnUDPRead = IdUDPServer1UDPRead
    Left = 48
    Top = 16
  end
end
