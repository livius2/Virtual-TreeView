object DrawTreeForm: TDrawTreeForm
  Left = 544
  Top = 320
  ClientHeight = 475
  ClientWidth = 710
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    710
    475)
  PixelsPerInch = 96
  TextHeight = 18
  object Label7: TLabel
    Left = 0
    Top = 0
    Width = 710
    Height = 61
    Align = alTop
    AutoSize = False
    Caption = 
      'A sample for a draw tree, which shows images of all known types ' +
      'as thumbnails. By default this tree uses the image loader librar' +
      'y GraphicEx  to support many common image formats like png, gif ' +
      'etc. (see www.delphi-gems.com for more infos and download).'
    WordWrap = True
  end
  object Label1: TLabel
    Left = 4
    Top = 381
    Width = 247
    Height = 18
    Anchors = [akLeft, akBottom]
    Caption = 'Adjust vertical image alignment of nodes:'
  end
  object Label3: TLabel
    Left = 424
    Top = 381
    Width = 22
    Height = 18
    Anchors = [akLeft, akBottom]
    Caption = '50%'
  end
  object TrackBar1: TTrackBar
    Left = 264
    Top = 379
    Width = 157
    Height = 21
    Anchors = [akLeft, akBottom]
    Max = 100
    Position = 50
    TabOrder = 0
    ThumbLength = 15
    TickStyle = tsNone
    OnChange = TrackBar1Change
  end
  object SystemImages: TImageList
    Left = 668
    Top = 404
  end
end
