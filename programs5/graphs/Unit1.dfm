object Form1: TForm1
  Left = 190
  Top = 121
  Width = 798
  Height = 610
  Caption = 'Expression viewer'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 112
    Width = 640
    Height = 471
    Align = alClient
    BevelOuter = bvNone
    BorderStyle = bsSingle
    Color = clWhite
    FullRepaint = False
    TabOrder = 0
    OnMouseDown = Panel1MouseDown
    OnMouseMove = Panel1MouseMove
    OnMouseUp = Panel1MouseUp
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 790
    Height = 112
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object GroupBox2: TGroupBox
      Left = 8
      Top = 4
      Width = 777
      Height = 101
      Caption = ' Graph Type '
      TabOrder = 0
      object Label2: TLabel
        Left = 127
        Top = 40
        Width = 14
        Height = 13
        Caption = 'z ='
      end
      object Label6: TLabel
        Left = 127
        Top = 73
        Width = 95
        Height = 13
        Caption = 'Available functions :'
      end
      object RadioButton1: TRadioButton
        Left = 8
        Top = 24
        Width = 89
        Height = 17
        Caption = '2D  { y = f(x) }'
        TabOrder = 5
        OnClick = RadioButton1Click
      end
      object RadioButton2: TRadioButton
        Left = 8
        Top = 48
        Width = 97
        Height = 17
        Caption = '3D  { z = f(x,y) }'
        Checked = True
        TabOrder = 4
        TabStop = True
        OnClick = RadioButton2Click
      end
      object functionEdit: TEdit
        Left = 144
        Top = 37
        Width = 209
        Height = 21
        Hint = 'Examples : cos(x) + cos(y)'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        Text = 'x^2 + y^2 - 1'
      end
      object ComboBox1: TComboBox
        Left = 226
        Top = 70
        Width = 128
        Height = 21
        Style = csDropDownList
        Color = clInfoBk
        DropDownCount = 16
        ItemHeight = 13
        TabOrder = 1
        Items.Strings = (
          'Operators'
          '---------------'
          '+'
          '-'
          '*'
          '/'
          '^  (power  i.e X^2)'
          ''
          'Standard Functions'
          '------------------------------'
          'ABS'
          'SQR'
          'SQRT'
          'EXP'
          'LN'
          'FR   (fractional part   i.e fr(x) )'
          ''
          'Trig functions'
          '---------------------'
          'SIN'
          'COS'
          'TAN'
          'SINH'
          'COSH'
          'TANH'
          'ARCSIN'
          'ARCCOS'
          'COT'
          '    '
          'Constants'
          '----------------'
          'PI'
          ''
          '')
      end
      object Button1: TButton
        Left = 371
        Top = 36
        Width = 75
        Height = 25
        Caption = 'Calculate'
        TabOrder = 2
        OnClick = Button1Click
      end
      object GroupBox1: TGroupBox
        Left = 464
        Top = 9
        Width = 305
        Height = 82
        Caption = ' Range '
        TabOrder = 3
        object Label3: TLabel
          Left = 8
          Top = 23
          Width = 16
          Height = 13
          Caption = 'X : '
        end
        object Label4: TLabel
          Left = 86
          Top = 23
          Width = 9
          Height = 13
          Caption = 'to'
        end
        object Label1: TLabel
          Left = 8
          Top = 51
          Width = 16
          Height = 13
          Caption = 'Y : '
        end
        object Label5: TLabel
          Left = 86
          Top = 51
          Width = 9
          Height = 13
          Caption = 'to'
        end
        object Label7: TLabel
          Left = 176
          Top = 24
          Width = 58
          Height = 13
          Caption = 'Increments :'
        end
        object Label8: TLabel
          Left = 176
          Top = 51
          Width = 58
          Height = 13
          Caption = 'Increments :'
        end
        object minX: TEdit
          Left = 28
          Top = 20
          Width = 53
          Height = 21
          TabOrder = 0
          Text = '-1.000'
        end
        object maxX: TEdit
          Left = 102
          Top = 20
          Width = 53
          Height = 21
          TabOrder = 1
          Text = '1.000'
        end
        object minY: TEdit
          Left = 28
          Top = 48
          Width = 53
          Height = 21
          TabOrder = 2
          Text = '-1.000'
        end
        object maxY: TEdit
          Left = 102
          Top = 48
          Width = 53
          Height = 21
          TabOrder = 3
          Text = '1.000'
        end
        object incX: TEdit
          Left = 240
          Top = 20
          Width = 53
          Height = 21
          TabOrder = 4
          Text = '0.1'
        end
        object incY: TEdit
          Left = 240
          Top = 48
          Width = 53
          Height = 21
          TabOrder = 5
          Text = '0.1'
        end
      end
    end
  end
  object Panel3: TPanel
    Left = 640
    Top = 112
    Width = 150
    Height = 471
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      150
      471)
    object GroupBox3: TGroupBox
      Left = 8
      Top = 0
      Width = 137
      Height = 241
      Caption = ' Graph Options '
      TabOrder = 0
      object Shape1: TShape
        Left = 13
        Top = 122
        Width = 20
        Height = 20
        Brush.Color = 12541952
      end
      object Shape2: TShape
        Left = 13
        Top = 152
        Width = 20
        Height = 20
        Brush.Color = 16711422
      end
      object CheckBox1: TCheckBox
        Left = 16
        Top = 23
        Width = 97
        Height = 17
        Caption = 'Smooth shading'
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = CheckBox1Click
      end
      object Button3: TButton
        Left = 40
        Top = 119
        Width = 75
        Height = 25
        Caption = 'Graph Color'
        TabOrder = 4
        OnClick = Button3Click
      end
      object Button4: TButton
        Left = 40
        Top = 149
        Width = 75
        Height = 25
        Caption = 'Background'
        TabOrder = 5
        OnClick = Button4Click
      end
      object Button5: TButton
        Left = 32
        Top = 208
        Width = 75
        Height = 25
        Caption = 'Refresh'
        TabOrder = 6
        OnClick = Button5Click
      end
      object CheckBox2: TCheckBox
        Left = 16
        Top = 65
        Width = 97
        Height = 17
        Caption = 'Wireframe'
        TabOrder = 2
        OnClick = CheckBox2Click
      end
      object CheckBox3: TCheckBox
        Left = 16
        Top = 44
        Width = 97
        Height = 17
        Caption = 'Flat shaded'
        TabOrder = 1
        OnClick = CheckBox3Click
      end
      object ShowAxis: TCheckBox
        Left = 16
        Top = 87
        Width = 97
        Height = 17
        Caption = 'Show Axis'
        TabOrder = 3
        OnClick = ShowAxisClick
      end
    end
    object GroupBox4: TGroupBox
      Left = 8
      Top = 256
      Width = 137
      Height = 93
      Caption = ' Example 3D graphs '
      TabOrder = 1
      object ComboBox2: TComboBox
        Left = 8
        Top = 25
        Width = 122
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        Items.Strings = (
          'x^2 + y^2 - 1'
          'x^2 - y^2'
          'cos(pi*x)/2 + cos(pi*y)/2'
          'cos(x + pi*sin(y))'
          'Sambrero Expression')
      end
      object Button6: TButton
        Left = 32
        Top = 56
        Width = 75
        Height = 25
        Caption = 'Select'
        TabOrder = 1
        OnClick = Button6Click
      end
    end
    object Button2: TButton
      Left = 43
      Top = 441
      Width = 75
      Height = 25
      Anchors = [akBottom]
      Caption = 'Exit'
      TabOrder = 3
      OnClick = Button2Click
    end
    object Button7: TButton
      Left = 43
      Top = 408
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'About'
      TabOrder = 2
      OnClick = Button7Click
    end
  end
  object ColorDialog1: TColorDialog
    Options = [cdFullOpen, cdSolidColor, cdAnyColor]
    Left = 656
    Top = 264
  end
end
