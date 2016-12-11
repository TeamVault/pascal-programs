object Form2: TForm2
  Left = 390
  Top = 283
  BorderStyle = bsDialog
  Caption = 'About'
  ClientHeight = 221
  ClientWidth = 298
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 11
    Top = 16
    Width = 39
    Height = 36
    Picture.Data = {
      07544269746D61701E030000424D1E0300000000000076000000280000002200
      0000220000000100040000000000A8020000130B0000130B0000100000001000
      000000000000FF00000084848400C6C6C600CED6D600FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00444444444444444444444444444444444400000044444444444444444444
      2244444444444400000044444444444444444442224444444444440000004444
      4444444444444400224444444444440000004444444444444444405022444444
      4444440000004444444444444444055022444444444444000000444444444444
      4420555022444444444444000000444444444442222055502222244444444400
      0000444444444222000355502222222444444400000044444444200035555553
      0002222244444400000044444440035555555555553002222444440000004444
      4403555555555555555530222244440000004444405555555555555555555502
      2224440000004444055555555555555555555550222244000000444255555555
      1111111115555555022244000000442355555555551111155555555530222400
      0000442555555555551111155555555550222400000042355555555555111115
      5555555553022400000042555555555555111115555555555502240000004255
      5555555555111115555555555502240000004255555555555511111555555555
      5502240000004255555555555511111555555555550224000000425555555555
      1111111555555555550244000000423555555555555555555555555553024400
      0000442555555555555555555555555550244400000044235555555553111135
      5555555530444400000044425555555551111115555555550444440000004444
      2555555551111115555555504444440000004444425555555311113555555504
      4444440000004444442355555555555555553244444444000000444444422355
      5555555555322444444444000000444444444222355555532224444444444400
      0000444444444444222222224444444444444400000044444444444444444444
      44444444444444000000}
    Transparent = True
  end
  object Label1: TLabel
    Left = 64
    Top = 20
    Width = 209
    Height = 25
    Alignment = taCenter
    Caption = 'Graphical Expression Viewer'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
  object Label2: TLabel
    Left = 136
    Top = 48
    Width = 53
    Height = 13
    Caption = 'Version 1.0'
  end
  object Label3: TLabel
    Left = 24
    Top = 80
    Width = 249
    Height = 41
    Alignment = taCenter
    AutoSize = False
    Caption = 
      'If you have any suggestion or interesting functions that you wou' +
      'ld like to share with me that I can add the the application, ple' +
      'ase let me know.'
    WordWrap = True
  end
  object Label4: TLabel
    Left = 24
    Top = 136
    Width = 249
    Height = 27
    Caption = 'My email address is jhorn@global.co.za, or go to my website at '
    WordWrap = True
  end
  object Label5: TLabel
    Left = 77
    Top = 149
    Width = 87
    Height = 13
    Cursor = crHandPoint
    Caption = 'www.sulaco.co.za'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnClick = Label5Click
  end
  object Button1: TButton
    Left = 111
    Top = 184
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 0
    OnClick = Button1Click
  end
end
