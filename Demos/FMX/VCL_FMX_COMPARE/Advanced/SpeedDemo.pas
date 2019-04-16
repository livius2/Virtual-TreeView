unit SpeedDemo;

// Virtual Treeview sample form demonstrating following features:
//   - Speed.
//   - Background image.
// Written by Mike Lischke.

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, VirtualTrees, ExtDlgs, ComCtrls, jpeg, Menus, Vcl.ExtCtrls;

type
  TSpeedForm = class(TForm)
    Label1: TLabel;
    Label3: TLabel;                                             
    Label6: TLabel;
    GroupBox2: TGroupBox;
    SBCheckBox: TCheckBox;
    LoadBackgroundButton: TButton;
    GroupBox1: TGroupBox;
    AddRootButton: TButton;
    NodeCountEdit: TEdit;
    AddChildButton: TButton;
    DeleteSelectionButton: TButton;
    Label4: TLabel;
    OPD: TOpenPictureDialog;
    Label2: TLabel;
    Label5: TLabel;
    Label7: TLabel;
    ClearButton: TButton;
    ImageBackground: TImage;
    procedure SBCheckBoxClick(Sender: TObject);
    procedure LoadBackgroundButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure AddButtonClick(Sender: TObject);
    procedure VST1GetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: string);
    procedure VST1Change(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VST1StructureChange(Sender: TBaseVirtualTree; Node: PVirtualNode; Reason: TChangeReason);
    procedure DeleteSelectionButtonClick(Sender: TObject);
    procedure VST1StateChange(Sender: TBaseVirtualTree; Enter, Leave: TVirtualTreeStates);
    procedure FormCreate(Sender: TObject);
    public
      VST1: TVirtualStringTree;
  end;

var
  SpeedForm: TSpeedForm;

//----------------------------------------------------------------------------------------------------------------------

implementation

uses
  Math, States;

{$R *.DFM}

//----------------------------------------------------------------------------------------------------------------------

procedure TSpeedForm.AddButtonClick(Sender: TObject);

var
  Count: Integer;
  Start: Cardinal;

begin
  Screen.Cursor := crHourGlass;
  with VST1 do
  try
    Start := GetTickCount;
    case (Sender as TButton).Tag of
      0: // add to root
        begin
          Count := StrToInt(NodeCountEdit.Text);
          RootNodeCount := Integer(RootNodeCount) + Count;
        end;
      1: // add as child
        if Assigned(FocusedNode) then
        begin
          Count := StrToInt(NodeCountEdit.Text);
          ChildCount[FocusedNode] := Integer(ChildCount[FocusedNode]) + Count;
          Expanded[FocusedNode] := True;
          InvalidateToBottom(FocusedNode);
        end;
    end;
    Label1.Caption := Format('Last operation duration: %d ms', [GetTickCount - Start]);
    Label3.Caption := Format('Nodes in tree: %d', [VST1.TotalCount]);
  finally
    Screen.Cursor := crDefault;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TSpeedForm.ClearButtonClick(Sender: TObject);

var
  Start: Cardinal;

begin
  Screen.Cursor := crHourGlass;
  try
    Start := GetTickCount;
    VST1.Clear;
    Label1.Caption := Format('Clear operation duration: %d ms', [GetTickCount - Start]);
    Label3.Caption := 'Nodes in tree: 0';
  finally
    Screen.Cursor := crDefault;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TSpeedForm.LoadBackgroundButtonClick(Sender: TObject);

begin
  with OPD do
  begin
    if Execute then
    begin
      VST1.Background.LoadFromFile(FileName);
      if SBCheckBox.Checked then
        VST1.Invalidate
      else
        SBCheckBox.Checked := True;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TSpeedForm.SBCheckBoxClick(Sender: TObject);

begin
  if SBCheckBox.Checked then
    VST1.TreeOptions.PaintOptions := VST1.TreeOptions.PaintOptions + [toShowBackground]
  else
    VST1.TreeOptions.PaintOptions := VST1.TreeOptions.PaintOptions - [toShowBackground];
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TSpeedForm.VST1GetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);

begin
  CellText := Format('Level %d, Index %d', [Sender.GetNodeLevel(Node), Node.Index]);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TSpeedForm.VST1Change(Sender: TBaseVirtualTree; Node: PVirtualNode);

begin
  Label6.Caption := Format('Selected: %d', [VST1.SelectedCount]);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TSpeedForm.VST1StructureChange(Sender: TBaseVirtualTree; Node: PVirtualNode; Reason: TChangeReason);

begin
  Label6.Caption := Format('Selected: %d', [VST1.SelectedCount]);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TSpeedForm.DeleteSelectionButtonClick(Sender: TObject);

var
  Start: Cardinal;

begin
  Screen.Cursor := crHourGlass;
  try
    Start := GetTickCount;
    VST1.DeleteSelectedNodes;
    Label1.Caption := Format('Delete operation duration: %d ms', [GetTickCount - Start]);
    Label3.Caption := 'Nodes in tree: ' + IntToStr(VST1.TotalCount);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TSpeedForm.FormCreate(Sender: TObject);
begin
  VST1:= TVirtualStringTree.Create(Self);
  VST1.Parent:= Self;

  VST1.OnChange := VST1Change;
  VST1.OnGetText := VST1GetText;
  VST1.OnStateChange := VST1StateChange;
  VST1.OnStructureChange := VST1StructureChange;

  VST1.Left := 6;
  VST1.Top := 24;
  VST1.Width := 251;
  VST1.Height := 487;
  VST1.Anchors := [akLeft, akTop, akRight, akBottom];
  VST1.AutoScrollInterval := 10;
  VST1.Background:= ImageBackground.Picture;
  VST1.BiDiMode := bdLeftToRight;
  VST1.Colors.BorderColor := clWindowText;
  VST1.Colors.HotColor := clBlack;
  VST1.Header.AutoSizeIndex := -1;
  VST1.Header.Font.Charset := DEFAULT_CHARSET;
  VST1.Header.Font.Color := clWindowText;
  VST1.Header.Font.Height := -11;
  VST1.Header.Font.Name := 'Tahoma';
  VST1.Header.Font.Style := [];
  VST1.Header.MainColumn := -1;
  VST1.Header.Options := [hoColumnResize, hoDrag, hoHotTrack];
  //VST1.HintAnimation := hatNone
  VST1.IncrementalSearch := isAll;
  VST1.ParentBiDiMode := False;
  VST1.ParentShowHint := False;
  VST1.ScrollBarOptions.VerticalIncrement := 18;
  VST1.ShowHint := True;
  VST1.TabOrder := 0;
  VST1.TreeOptions.MiscOptions := [toAcceptOLEDrop, toEditable, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning];
  VST1.TreeOptions.SelectionOptions := [toMultiSelect];
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TSpeedForm.VST1StateChange(Sender: TBaseVirtualTree; Enter, Leave: TVirtualTreeStates);

begin
  if not (csDestroying in ComponentState) then
    UpdateStateDisplay(Sender.TreeStates, Enter, Leave);
end;

//----------------------------------------------------------------------------------------------------------------------

end.

