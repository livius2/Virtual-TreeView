unit VisibilityDemo;

// Virtual Treeview sample form demonstrating following features:
//   - Hiding nodes.
//   - Synchronization between 2 trees (expand, scroll, selection).
//   - Wheel scrolling and panning.
// Written by Mike Lischke.
{$WARN UNSAFE_CODE OFF} // Prevent warnins that are not applicable 

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, VirtualTrees, ComCtrls, ExtCtrls, ImgList;

type
  TVisibilityForm = class(TForm)
    Label17: TLabel;
    RadioGroup1: TRadioGroup;
    Splitter2: TSplitter;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ImageBackground: TImage;
    procedure VST1InitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
    procedure VST1InitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
      var InitialStates: TVirtualNodeInitStates);
    procedure FormCreate(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure VST2GetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: string);
    procedure VST3Scroll(Sender: TBaseVirtualTree; DeltaX, DeltaY: Integer);
    procedure VST2InitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
    procedure VST2Scroll(Sender: TBaseVirtualTree; DeltaX, DeltaY: Integer);
    procedure VSTCollapsedExpanded(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VST2Change(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure Splitter2CanResize(Sender: TObject; var NewSize: Integer;
      var Accept: Boolean);
    procedure Splitter2Paint(Sender: TObject);
    procedure VST1GetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: string);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure VST3FreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VST2FreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VST1FreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
  private
    FChanging: Boolean;
    procedure HideNodes(Sender: TBaseVirtualTree; Node: PVirtualNode; Data: Pointer; var Abort: Boolean);
    public
      VST1: TVirtualStringTree;
      VST2: TVirtualStringTree;
      VST3: TVirtualStringTree;
  end;

var
  VisibilityForm: TVisibilityForm;

//----------------------------------------------------------------------------------------------------------------------

implementation

uses States;

{$R *.DFM}

type
  PLinkData = ^TLinkData;
  TLinkData = record
    Caption: UnicodeString;
    OtherNode: PVirtualNode;
  end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVisibilityForm.VST1InitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
  var InitialStates: TVirtualNodeInitStates);

var
  Level: Integer;

begin
  Level := Sender.GetNodeLevel(Node);
  if Level < 4 then
    Include(InitialStates, ivsHasChildren);
  if Level > 0 then
    Node.CheckType := TCheckType(Level)
  else
    Node.CheckType := ctTriStateCheckBox;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVisibilityForm.VST1InitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);

begin
  ChildCount := Random(5) + 1;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVisibilityForm.FormCreate(Sender: TObject);

var
  Run1, Run2: PVirtualNode;
  Data1, Data2: PLinkData;
  col: TVirtualTreeColumn;
begin
  VST1:= TVirtualStringTree.Create(Self);
  VST1.Parent:= Self;

  VST1.OnFreeNode := VST1FreeNode;
  VST1.OnGetText := VST1GetText;
  VST1.OnInitChildren := VST1InitChildren;
  VST1.OnInitNode := VST1InitNode;

  VST1.Left := 4;
  VST1.Top := 4;
  VST1.Width := 354;
  VST1.Height := 193;
  VST1.Anchors := [akLeft, akTop, akRight];
  VST1.Colors.BorderColor := clWindowText;
  VST1.Colors.HotColor := clBlack;
  VST1.DefaultNodeHeight := 24;
  VST1.Header.AutoSizeIndex := 0;
  VST1.Header.Font.Charset := DEFAULT_CHARSET;
  VST1.Header.Font.Color := clWindowText;
  VST1.Header.Font.Height := -11;
  VST1.Header.Font.Name := 'Tahoma';
  VST1.Header.Font.Style := [];
  VST1.Header.MainColumn := -1;
  VST1.Header.Options := [hoColumnResize, hoDrag];
  VST1.HintMode := hmTooltip;
  VST1.IncrementalSearch := isAll;
  VST1.ParentShowHint := False;
  VST1.ShowHint := True;
  VST1.TabOrder := 0;
  VST1.TreeOptions.AutoOptions := [toAutoDropExpand, toAutoScroll, toAutoScrollOnExpand, toAutoTristateTracking, toAutoHideButtons, toAutoChangeScale];
  VST1.TreeOptions.SelectionOptions := [toMultiSelect];

  VST1.DefaultText := '';

  //------------------------------------------------

  VST2:= TVirtualStringTree.Create(Self);
  VST2.Parent:= Panel2;

  VST2.OnChange := VST2Change;
  VST2.OnCollapsed := VSTCollapsedExpanded;
  VST2.OnExpanded := VSTCollapsedExpanded;
  VST2.OnFreeNode := VST2FreeNode;
  VST2.OnGetText := VST2GetText;
  VST2.OnInitChildren := VST2InitChildren;
  VST2.OnInitNode := VST1InitNode;
  VST2.OnScroll := VST2Scroll;

  VST2.Left := 1;
  VST2.Top := 1;
  VST2.Width := 204;
  VST2.Height := 264;
  VST2.Align := alLeft;
  VST2.Background:= ImageBackground.Picture;
  VST2.BorderStyle := bsNone;
  VST2.ButtonStyle := bsTriangle;
  VST2.Colors.BorderColor := clWindowText;
  VST2.Colors.HotColor := clBlack;
  VST2.Colors.UnfocusedSelectionColor := clHighlight;
  VST2.Colors.UnfocusedSelectionBorderColor := clHighlight;
  VST2.DefaultNodeHeight := 24;
  VST2.Font.Charset := ANSI_CHARSET;
  VST2.Font.Color := clNavy;
  VST2.Font.Height := -11;
  VST2.Font.Name := 'Verdana';
  VST2.Font.Style := [];
  VST2.Header.AutoSizeIndex := 0;
  VST2.Header.Font.Charset := DEFAULT_CHARSET;
  VST2.Header.Font.Color := clWindowText;
  VST2.Header.Font.Height := -11;
  VST2.Header.Font.Name := 'Tahoma';
  VST2.Header.Font.Style := [];
  VST2.Header.Height := 24;
  VST2.Header.Options := [hoAutoResize, hoColumnResize, hoDrag, hoVisible];
  VST2.Header.Style := hsFlatButtons;
  VST2.HintMode := hmTooltip;
  VST2.IncrementalSearch := isAll;
  VST2.ParentFont := False;
  VST2.ParentShowHint := False;
  VST2.ScrollBarOptions.AlwaysVisible := True;
  VST2.ScrollBarOptions.ScrollBars := ssHorizontal;
  VST2.SelectionCurveRadius := 3;
  VST2.ShowHint := True;
  VST2.TabOrder := 0;
  VST2.TreeOptions.AutoOptions := [toAutoDropExpand, toAutoScroll, toAutoTristateTracking, toAutoChangeScale];
  VST2.TreeOptions.MiscOptions := [toAcceptOLEDrop, toCheckSupport, toInitOnSave, toToggleOnDblClick, toWheelPanning];
  VST2.TreeOptions.PaintOptions := [toHideFocusRect, toShowBackground, toShowButtons, toShowDropmark, toShowRoot, toShowTreeLines, toThemeAware, toUseBlendedImages, toUseBlendedSelection];
  VST2.TreeOptions.SelectionOptions := [toExtendedFocus];

  col:= VST2.Header.Columns.Add;
  col.Position := 0;
  col.Width := 204;
  col.Text := 'Main column';

  VST2.DefaultText := '';
  VST2.Left:= -1000; //splitter

  //------------------------------------------------

  VST3:= TVirtualStringTree.Create(Self);
  VST3.Parent:= Panel2;

  VST3.OnChange := VST2Change;
  VST3.OnCollapsed := VSTCollapsedExpanded;
  VST3.OnExpanded := VSTCollapsedExpanded;
  VST3.OnFreeNode := VST3FreeNode;
  VST3.OnGetText := VST2GetText;
  VST3.OnInitChildren := VST2InitChildren;
  VST3.OnInitNode := VST1InitNode;
  VST3.OnScroll := VST3Scroll;

  VST3.Left := 3;
  VST3.Top := 1;
  VST3.Width := 485;
  VST3.Height := 264;
  VST3.Align := alClient;
  VST3.Background:= ImageBackground.Picture;

  VST3.BevelEdges := [beTop, beRight, beBottom];
  VST3.BorderStyle := bsNone;
  VST3.ButtonStyle := bsTriangle;
  VST3.Colors.BorderColor := clWindowText;
  VST3.Colors.HotColor := clBlack;
  VST3.Colors.UnfocusedSelectionColor := clHighlight;
  VST3.Colors.UnfocusedSelectionBorderColor := clHighlight;
  VST3.DefaultNodeHeight := 24;
  VST3.Font.Charset := ANSI_CHARSET;
  VST3.Font.Color := clNavy;
  VST3.Font.Height := -11;
  VST3.Font.Name := 'Verdana';
  VST3.Font.Style := [];
  VST3.Header.AutoSizeIndex := 0;
  VST3.Header.Font.Charset := DEFAULT_CHARSET;
  VST3.Header.Font.Color := clWindowText;
  VST3.Header.Font.Height := -11;
  VST3.Header.Font.Name := 'Tahoma';
  VST3.Header.Font.Style := [];
  VST3.Header.Height := 24;
  VST3.Header.Options := [hoColumnResize, hoDrag, hoVisible];
  VST3.Header.Style := hsFlatButtons;
  VST3.HintMode := hmTooltip;
  VST3.IncrementalSearch := isAll;
  VST3.ParentFont := False;
  VST3.ParentShowHint := False;
  VST3.ScrollBarOptions.AlwaysVisible := True;
  VST3.SelectionCurveRadius := 3;
  VST3.ShowHint := True;
  VST3.TabOrder := 0;
  VST3.TreeOptions.AutoOptions := [toAutoDropExpand, toAutoScroll, toAutoTristateTracking, toAutoChangeScale];
  VST3.TreeOptions.MiscOptions := [toAcceptOLEDrop, toCheckSupport, toInitOnSave, toToggleOnDblClick, toWheelPanning];
  VST3.TreeOptions.PaintOptions := [toHideFocusRect, toShowBackground, toShowButtons, toShowDropmark, toShowRoot, toShowTreeLines, toThemeAware, toUseBlendedImages, toUseBlendedSelection];
  VST3.TreeOptions.SelectionOptions := [toExtendedFocus, toFullRowSelect];



  col:= VST3.Header.Columns.Add;
  col.Color := clWindow;
  col.Options := [coAllowClick, coEnabled, coParentBidiMode, coResizable, coShowDropMark];
  col.Position := 0;
  col.Width := 100;
  col.Text := 'Column 0';

  col:= VST3.Header.Columns.Add;
  col.Position := 1;
  col.Width := 100;
  col.Text := 'Column 1';

  col:= VST3.Header.Columns.Add;
  col.Position := 2;
  col.Width := 100;
  col.Text := 'Column 2';

  col:= VST3.Header.Columns.Add;
  col.Position := 3;
  col.Width := 100;
  col.Text := 'Column 3';

  col:= VST3.Header.Columns.Add;
  col.Position := 4;
  col.Width := 100;
  col.Text := 'Column 4';

  VST3.DefaultText := '';

  //------------------------------------------------

  Randomize;
  VST1.RootNodeCount := 5;

  // The base idea behind linking two (or more) trees together is that one has access to the nodes of the others.
  // This can be reached in several ways. I use here the simplest approach by validating both trees fully and creating
  // cross references for all nodes. Another one would be to create a common data base and link all trees to this.
  VST2.NodeDataSize := SizeOf(TLinkData);
  VST2.RootNodeCount := 5;
  VST3.NodeDataSize := SizeOf(TLinkData);
  VST3.RootNodeCount := 5;

  VST3.BackgroundOffsetX := Splitter2.Left + Splitter2.Width;

  // Create cross references. This will validate all nodes.
  Run1 := VST2.GetFirst;
  Run2 := VST3.GetFirst;
  while Assigned(Run1) do
  begin
    Data1 := VST2.GetNodeData(Run1);
    Data1.OtherNode := Run2;
    Data2 := VST3.GetNodeData(Run2);
    Data2.OtherNode := Run1;
    Run1 := VST2.GetNext(Run1);
    Run2 := VST3.GetNext(Run2);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVisibilityForm.HideNodes(Sender: TBaseVirtualTree; Node: PVirtualNode; Data: Pointer; var Abort: Boolean);

begin
  case Integer(Data) of
    0: // show all nodes
      Sender.IsVisible[Node] := True;
    1: // hide every second
      Sender.IsVisible[Node] := not Odd(Node.Index);
    2: // hide nodes with child nodes only
      Sender.IsVisible[Node] := not Sender.HasChildren[Node];
    3: // hide all
      Sender.IsVisible[Node] := False;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVisibilityForm.RadioGroup1Click(Sender: TObject);

begin
  with Sender as TRadioGroup do
  begin
    VST1.BeginUpdate;
    try
      VST1.IterateSubtree(nil, HideNodes, Pointer(ItemIndex), [], True);
    finally
      VST1.EndUpdate;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVisibilityForm.VST2GetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: string);

var
  Data: PLinkData;

begin
  Data := Sender.GetNodeData(Node);
  if Length(Data.Caption) = 0 then
    Data.Caption := 'Node ' + IntToStr(Sender.AbsoluteIndex(Node));

  CellText := Data.Caption;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVisibilityForm.VST3Scroll(Sender: TBaseVirtualTree; DeltaX, DeltaY: Integer);

// Synchronizes scroll offsets of VST2 and VST3.

begin
  if not FChanging then
  begin
    FChanging := True;
    try
      VST3.Update;
      VST2.OffsetY := VST3.OffsetY;
      VST2.Update;
    finally
      FChanging := False;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVisibilityForm.VST2Scroll(Sender: TBaseVirtualTree; DeltaX, DeltaY: Integer);

// Synchronizes scroll offsets of VST2 and VST3.

begin
  if not FChanging then
  begin
    FChanging := True;
    try
      VST2.Update;
      VST3.OffsetY := VST2.OffsetY;
      VST3.Update;
    finally
      FChanging := False;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVisibilityForm.VST2InitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);

begin
  ChildCount := Sender.GetNodeLevel(Node) + 2;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVisibilityForm.VSTCollapsedExpanded(Sender: TBaseVirtualTree; Node: PVirtualNode);

// Collapse/Expand state synchronization.

var
  OtherTree: TBaseVirtualTree;
  Data: PLinkData;
  
begin
  // Avoid recursive calls.
  if not FChanging then
  begin
    FChanging := True;
    try
      if Sender = VST2 then
        OtherTree := VST3
      else
        OtherTree := VST2;

      Data := Sender.GetNodeData(Node);
      OtherTree.ToggleNode(Data.OtherNode);
    finally
      FChanging := False;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVisibilityForm.VST2Change(Sender: TBaseVirtualTree; Node: PVirtualNode);

// Keep selected nodes in sync.

var
  Data: PLinkData;
  OtherTree: TBaseVirtualTree;

begin
  if not FChanging and Assigned(Node) then
  begin
    FChanging := True;
    try
      Data := Sender.GetNodeData(Node);
      if Sender = VST2 then
        OtherTree := VST3
      else
        OtherTree := VST2;

      OtherTree.Selected[Data.OtherNode] := True;
      OtherTree.FocusedNode := Data.OtherNode;
    finally
      FChanging := False;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVisibilityForm.Splitter2CanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);

// This method is called just before resizing is done. This is a good opportunity to adjust the background image
// offset.

begin
  VST3.BackgroundOffsetX := NewSize + Splitter2.Width;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVisibilityForm.Splitter2Paint(Sender: TObject);

begin
  with Splitter2, Canvas do
  begin
    Brush.Color := clBtnFace;
    FillRect(Rect(0, 0, Width, VST2.Header.Height));
    Brush.Color := clWindow;
    FillRect(Rect(0, VST2.Header.Height, Width, Height));
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVisibilityForm.VST1GetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: UnicodeString);

begin
  CellText := Format('Node Level %d, Index %d', [Sender.GetNodeLevel(Node), Node.Index]);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVisibilityForm.FormShow(Sender: TObject);

begin
  StateForm.Hide;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVisibilityForm.FormHide(Sender: TObject);

begin
  StateForm.Show;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVisibilityForm.VST1FreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PLinkData;
begin
  Data := Sender.GetNodeData(Node);
  Finalize(Data^);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVisibilityForm.VST2FreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PLinkData;
begin
  Data := Sender.GetNodeData(Node);
  Finalize(Data^);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVisibilityForm.VST3FreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PLinkData;

begin
  Data := Sender.GetNodeData(Node);
  Finalize(Data^);
end;


end.
