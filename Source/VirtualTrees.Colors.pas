unit VirtualTrees.Colors;

interface
{$IFNDEF VT_FMX}
  {$DEFINE VT_VCL}
{$ENDIF}

{$IFDEF VT_FMX}
uses
    System.Classes
  , System.UITypes
  , FMX.Graphics
  , FMX.Controls
  , VirtualTrees.FMX
  ;
{$ELSE}
uses
  System.Classes,
  Vcl.Graphics,
  Vcl.Themes,
  Vcl.Controls;
{$ENDIF}

type
  // class to collect all switchable colors into one place
  TVTColors = class(TPersistent)
  private type
    TVTColorEnum = (
	    cDisabledColor
	  , cDropMarkColor
	  , cDropTargetColor
	  , cFocusedSelectionColor
	  , cGridLineColor
	  , cTreeLineColor
	  , cUnfocusedSelectionColor
	  , cBorderColor
	  , cHotColor
	  , cFocusedSelectionBorderColor
	  , cUnfocusedSelectionBorderColor
	  , cDropTargetBorderColor
	  , cSelectionRectangleBlendColor
	  , cSelectionRectangleBorderColor
	  , cHeaderHotColor
	  , cSelectionTextColor
	  , cUnfocusedColor
	  );

    // Please make sure that the published Color properties at the corresponding index
    // have the same color if you change anything here!
  const
    cDefaultColors : array [TVTColorEnum] of TColor = (
	    clBtnShadow,            //DisabledColor
      clHighlight,            //DropMarkColor
      clHighlight,            //DropTargetColor
      clHighlight,            //FocusedSelectionColor
      clBtnFace,              //GridLineColor
      clBtnShadow,            //TreeLineColor
      clInactiveCaption,      //UnfocusedSelectionColor
      clBtnFace,              //BorderColor
      clWindowText,           //HotColor
      clHighlight,            //FocusedSelectionBorderColor
      clInactiveCaption,      //UnfocusedSelectionBorderColor
      clHighlight,            //DropTargetBorderColor
      clHighlight,            //SelectionRectangleBlendColor
      clHighlight,            //SelectionRectangleBorderColor
      clBtnShadow,            //HeaderHotColor
      clHighlightText,        //SelectionTextColor
      clInactiveCaptionText //UnfocusedColor  [IPK]
    );
  private
    FOwner: TCustomControl;
    FColors: array[TVTColorEnum] of TColor; // [IPK] 15 -> 16
    function GetColor(const Index: TVTColorEnum): TColor;
    procedure SetColor(const Index: TVTColorEnum; const Value: TColor);
    function GetBackgroundColor: TColor;
    function GetHeaderFontColor: TColor;
    function GetNodeFontColor: TColor;
  public
    constructor Create(AOwner: TCustomControl);

    procedure Assign(Source: TPersistent); override;
    function GetSelectedNodeFontColor(Focused : boolean) : TColor;
    property BackGroundColor: TColor read GetBackgroundColor;
    property HeaderFontColor: TColor read  GetHeaderFontColor;
    property NodeFontColor: TColor read GetNodeFontColor;
    {$IFDEF VT_VCL}
    //Mitigator function to use the correct style service for this context (either the style assigned to the control for Delphi > 10.4 or the application style)
    function StyleServices(AControl : TControl = nil) : TCustomStyleServices;
    {$ENDIF}
  published
    property BorderColor: TColor index cBorderColor read GetColor write SetColor default clBtnFace;
    property DisabledColor: TColor index cDisabledColor read GetColor write SetColor default clBtnShadow;
    property DropMarkColor: TColor index cDropMarkColor read GetColor write SetColor default clHighlight;
    property DropTargetColor: TColor index cDropTargetColor read GetColor write SetColor default clHighlight;
    property DropTargetBorderColor: TColor index cDropTargetBorderColor read GetColor write SetColor default clHighlight;
    /// The background color of selected nodes in case the tree has the focus, or the toPopupMode flag is set.
    property FocusedSelectionColor: TColor index cFocusedSelectionColor read GetColor write SetColor default clHighlight;
    /// The border color of selected nodes when the tree has the focus.
    property FocusedSelectionBorderColor: TColor index cFocusedSelectionBorderColor read GetColor write SetColor default clHighlight;
    property GridLineColor: TColor index cGridLineColor read GetColor write SetColor default clBtnFace;
    property HeaderHotColor: TColor index cHeaderHotColor read GetColor write SetColor default clBtnShadow;
    property HotColor: TColor index cHotColor read GetColor write SetColor default clWindowText;
    property SelectionRectangleBlendColor: TColor index cSelectionRectangleBlendColor read GetColor write SetColor default clHighlight;
    property SelectionRectangleBorderColor: TColor index cSelectionRectangleBorderColor read GetColor write SetColor default clHighlight;
    /// The text color of selected nodes
    property SelectionTextColor: TColor index cSelectionTextColor read GetColor write SetColor default clHighlightText;
    property TreeLineColor: TColor index cTreeLineColor read GetColor write SetColor default clBtnShadow;
    property UnfocusedColor: TColor index cUnfocusedColor read GetColor write SetColor default clInactiveCaptionText; // [IPK] Added
    /// The background color of selected nodes in case the tree does not have the focus and the toPopupMode flag is not set.
    property UnfocusedSelectionColor: TColor index cUnfocusedSelectionColor read GetColor write SetColor default clInactiveCaption;
    /// The border color of selected nodes in case the tree does not have the focus and the toPopupMode flag is not set.
    property UnfocusedSelectionBorderColor: TColor index cUnfocusedSelectionBorderColor read GetColor write SetColor default clInactiveCaption;
  end;
  
implementation
{$IFDEF VT_FMX}
uses
  {$IFDEF MSWINDOWS}
  WinApi.Windows,
  {$ENDIF}
  VirtualTrees,
  VirtualTrees.Utils,
  VirtualTrees.StyleHooks,
  VirtualTrees.BaseTree;
{$ELSE}
uses
  WinApi.Windows,
  VirtualTrees.Types,
  VirtualTrees.Utils,
  VirtualTrees.StyleHooks,
  VirtualTrees.BaseTree;
{$ENDIF}

type
  TBaseVirtualTreeCracker = class(TBaseVirtualTree);

  TVTColorsHelper = class helper for TVTColors
    function TreeView : TBaseVirtualTreeCracker;
  end;

  //----------------- TVTColors ------------------------------------------------------------------------------------------

constructor TVTColors.Create(AOwner: TCustomControl);
var
  CE : TVTColorEnum;
begin
  FOwner := AOwner;
  for CE := Low(TVTColorEnum) to High(TVTColorEnum) do
    FColors[CE] := cDefaultColors[CE];
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTColors.GetBackgroundColor: TColor;
begin
// XE2 VCL Style
{$IFDEF VT_VCL}
  if TreeView.VclStyleEnabled and (seClient in FOwner.StyleElements) then
    Result := StyleServices.GetStyleColor(scTreeView)
  else
{$ENDIF}
    Result := TreeView.{$IFDEF VT_FMX}Fill.Color{$ELSE}Color{$ENDIF};
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTColors.GetColor(const Index: TVTColorEnum): TColor;
begin
  {$IFDEF VT_VCL}  
  // Only try to fetch the color via StyleServices if theses are enabled
  // Return default/user defined color otherwise
  if not (csDesigning in TreeView.ComponentState) { see issue #1185 } and TreeView.VclStyleEnabled then
  begin
    //If the ElementDetails are not defined, fall back to the SystemColor
    case Index of
      cDisabledColor :
        if not StyleServices.GetElementColor(StyleServices.GetElementDetails(ttItemDisabled), ecTextColor, Result) then
          Result := StyleServices.GetSystemColor(FColors[Index]);
      cTreeLineColor :
        if not StyleServices.GetElementColor(StyleServices.GetElementDetails(ttBranch), ecBorderColor, Result) then
          Result := StyleServices.GetSystemColor(FColors[Index]);
      cBorderColor :
        if (seBorder in FOwner.StyleElements) then
          Result := StyleServices.GetSystemColor(FColors[Index])
        else
          Result := FColors[Index];
      cHotColor :
        if not StyleServices.GetElementColor(StyleServices.GetElementDetails(ttItemHot), ecTextColor, Result) then
          Result := StyleServices.GetSystemColor(FColors[Index]);
      cHeaderHotColor :
        if not StyleServices.GetElementColor(StyleServices.GetElementDetails(thHeaderItemHot), ecTextColor, Result) then
          Result := StyleServices.GetSystemColor(FColors[Index]);
      cSelectionTextColor :
        if not StyleServices.GetElementColor(StyleServices.GetElementDetails(ttItemSelected), ecTextColor, Result) then
          Result := StyleServices.GetSystemColor(clHighlightText);
      cUnfocusedColor :
        if not StyleServices.GetElementColor(StyleServices.GetElementDetails(ttItemSelectedNotFocus), ecTextColor, Result) then
          Result := StyleServices.GetSystemColor(FColors[Index]);
    else
      Result := StyleServices.GetSystemColor(FColors[Index]);
    end;
  end
  else
    Result := FColors[Index];
{$ENDIF}
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTColors.GetHeaderFontColor: TColor;
begin
// XE2+ VCL Style
{$IFDEF VT_FMX}
  Result := clBlack; //TODO: color!!!
{$ELSE}
  if TreeView.VclStyleEnabled and (seFont in FOwner.StyleElements) then
    StyleServices.GetElementColor(StyleServices.GetElementDetails(thHeaderItemNormal), ecTextColor, Result)
  else
    Result := TreeView.Header.Font.Color;
{$ENDIF}
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTColors.GetNodeFontColor: TColor;
begin
{$IFDEF VT_FMX}
  Result := clBlack; //TODO: color!!!
{$ELSE}
  if TreeView.VclStyleEnabled and (seFont in FOwner.StyleElements) then
    StyleServices.GetElementColor(StyleServices.GetElementDetails(ttItemNormal), ecTextColor, Result)
  else
    Result := TreeView.Font.Color;
{$ENDIF}
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTColors.GetSelectedNodeFontColor(Focused: boolean): TColor;
begin
  if Focused then
  begin
{$IFDEF VT_VCL}
    if (tsUseExplorerTheme in TreeView.TreeStates) and not IsHighContrastEnabled then begin
      Result := NodeFontColor
    end
    else
{$ENDIF}
      Result := SelectionTextColor
  end// if Focused
  else
    Result := UnfocusedColor;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTColors.SetColor(const Index: TVTColorEnum; const Value: TColor);
begin
  if FColors[Index] <> Value then
  begin
    FColors[Index] := Value;
    if not (csLoading in FOwner.ComponentState) and TreeView.HandleAllocated then
    begin
      // Cause helper bitmap rebuild if the button color changed.
      case Index of
        cTreeLineColor:
          begin
{$IFDEF VT_FMX}
            TreeView.PrepareBitmaps(False, True);
{$ELSE}
            TreeView.PrepareBitmaps(True, False);
{$ENDIF}
            TreeView.Invalidate;
          end;
        cBorderColor :
          TreeView.RedrawWindow(nil, 0, RDW_FRAME or RDW_INVALIDATE or RDW_NOERASE or RDW_NOCHILDREN)
      else
        {$IFDEF VT_VCL}if not (TVirtualTreeStates.tsPainting in TreeView.TreeStates) then{$ENDIF} // See issue #1186
          TreeView.Invalidate;
      end;//case
    end;// if
  end;
end;

//----------------------------------------------------------------------------------------------------------------------
{$IFDEF VT_VCL}
function TVTColors.StyleServices(AControl : TControl) : TCustomStyleServices;
begin
  if AControl = nil then
    AControl := FOwner;
  Result := VTStyleServices(AControl);
end;
{$ENDIF}
//----------------------------------------------------------------------------------------------------------------------

procedure TVTColors.Assign(Source : TPersistent);
begin
  if Source is TVTColors then
  begin
    FColors := TVTColors(Source).FColors;
    if TreeView.UpdateCount = 0 then
      TreeView.Invalidate;
  end
  else
    inherited;
end;

{ TVTColorsHelper }

function TVTColorsHelper.TreeView : TBaseVirtualTreeCracker;
begin
  Result := TBaseVirtualTreeCracker(FOwner);
end;

end.
