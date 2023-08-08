object Form1: TForm1
  Left = 437
  Top = 160
  BorderStyle = bsDialog
  Caption = 'AVD System - '#1052#1086#1076#1091#1083#1100' '#1087#1077#1088#1077#1074#1086#1076#1072' '#1091#1095#1077#1085#1080#1082#1086#1074' '#1085#1072' '#1085#1086#1074#1099#1081' '#1091#1095#1077#1073#1085#1099#1081' '#1075#1086#1076
  ClientHeight = 475
  ClientWidth = 330
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 64
    Height = 13
    Caption = #1055#1077#1088#1077#1074#1086#1076#1080#1090#1100':'
    Enabled = False
  end
  object Label2: TLabel
    Left = 8
    Top = 32
    Width = 68
    Height = 13
    Caption = #1058#1077#1082#1091#1097#1080#1081' '#1075#1086#1076':'
  end
  object ComboBox1: TComboBox
    Left = 80
    Top = 8
    Width = 145
    Height = 21
    Enabled = False
    ItemHeight = 13
    TabOrder = 0
  end
  object Button1: TButton
    Left = 8
    Top = 440
    Width = 105
    Height = 25
    Caption = #1055#1077#1088#1077#1074#1077#1089#1090#1080
    TabOrder = 1
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 8
    Top = 56
    Width = 313
    Height = 377
    ScrollBars = ssBoth
    TabOrder = 2
  end
  object Button2: TButton
    Left = 216
    Top = 440
    Width = 105
    Height = 25
    Caption = #1042#1099#1081#1090#1080
    TabOrder = 3
    OnClick = Button2Click
  end
  object Edit1: TEdit
    Left = 80
    Top = 32
    Width = 145
    Height = 21
    Enabled = False
    TabOrder = 4
    Text = 'Edit1'
  end
end
