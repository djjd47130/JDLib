object frmSelectControl: TfrmSelectControl
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'Select Control'
  ClientHeight = 192
  ClientWidth = 363
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    363
    192)
  PixelsPerInch = 96
  TextHeight = 13
  object lblPrompt: TLabel
    Left = 9
    Top = 8
    Width = 147
    Height = 13
    Caption = 'Select control to convert from:'
  end
  object lstControls: TListBox
    Left = 200
    Top = 32
    Width = 155
    Height = 124
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 13
    TabOrder = 0
  end
  object cmdOK: TBitBtn
    Left = 280
    Top = 162
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      0400000000006801000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      3333333333333333333333330000333333333333333333333333F33333333333
      00003333344333333333333333388F3333333333000033334224333333333333
      338338F3333333330000333422224333333333333833338F3333333300003342
      222224333333333383333338F3333333000034222A22224333333338F338F333
      8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
      33333338F83338F338F33333000033A33333A222433333338333338F338F3333
      0000333333333A222433333333333338F338F33300003333333333A222433333
      333333338F338F33000033333333333A222433333333333338F338F300003333
      33333333A222433333333333338F338F00003333333333333A22433333333333
      3338F38F000033333333333333A223333333333333338F830000333333333333
      333A333333333333333338330000333333333333333333333333333333333333
      0000}
    NumGlyphs = 2
    TabOrder = 1
    OnClick = cmdOKClick
  end
  object cmdCancel: TBitBtn
    Left = 199
    Top = 162
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 2
  end
  object pOptions: TPanel
    Left = 9
    Top = 32
    Width = 185
    Height = 124
    Anchors = [akLeft, akTop, akBottom]
    TabOrder = 3
    DesignSize = (
      185
      124)
    object Label1: TLabel
      Left = 16
      Top = 67
      Width = 67
      Height = 13
      Caption = 'Control Class:'
    end
    object chkIncludeInherited: TCheckBox
      Left = 16
      Top = 16
      Width = 153
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Include Inherited Types'
      Checked = True
      State = cbChecked
      TabOrder = 0
      OnClick = OptionChanged
    end
    object chkCurrentParent: TCheckBox
      Left = 16
      Top = 39
      Width = 153
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Current Parent Only'
      TabOrder = 1
      OnClick = OptionChanged
    end
    object cboControlClass: TComboBox
      Left = 16
      Top = 86
      Width = 153
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      ItemIndex = 0
      TabOrder = 2
      Text = 'TCustomButton'
      OnSelect = OptionChanged
      Items.Strings = (
        'TCustomButton'
        'TButton'
        'TSpeedButton'
        'TBitBtn')
    end
  end
end
