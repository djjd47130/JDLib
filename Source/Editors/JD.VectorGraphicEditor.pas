unit JD.VectorGraphicEditor;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  System.TypInfo, System.Rtti,
  Vcl.StdCtrls,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  System.ImageList, Vcl.ImgList, System.Actions, Vcl.ActnList, Vcl.ToolWin,
  Vcl.ComCtrls, Vcl.Clipbrd, Vcl.Grids, Vcl.ValEdit, Vcl.ExtCtrls,

  JD.Graphics,
  JD.Common, JD.FontGlyphs,
  JD.Ctrls.FontButton,
  JD.Ctrls, JD.Vector, JD.Ctrls.VectorEditor,

  VirtualTrees.BaseAncestorVCL, VirtualTrees.BaseTree,
  VirtualTrees.AncestorVCL, VirtualTrees, VirtualTrees.Types,
  Vcl.Menus, Vcl.CheckLst, Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnMan,
  Vcl.ActnCtrls,

  LMDDckSite, LMDIdeCompBar, LMDControl, LMDCustomControl, LMDCustomPanel,
  LMDCustomBevelPanel, LMDCustomParentPanel, LMDCustomPanelFill, LMDButtonPanel,
  ElPanel, ElToolBar, ElMenuBar, ElCGControl, ElPopBtn;

type
  TEditorMode = (emFile, emIntegrated);

  TPropertyType = (ptString, ptInteger, ptFloat, ptBoolean, ptEnum, ptSet, ptObject, ptButton);

  PPropertyItem = ^TPropertyItem;
  TPropertyItem = record
    Name: string;
    Value: string;
    Owner: TPersistent;
    PropertyType: TPropertyType;
    EnumValues: TStringList; // Holds possible values for enums/dropdowns
    PersistentObject: TPersistent; // Stores nested TPersistent instances
    ButtonCaption: string; // Caption for button-triggered editors
  end;

  PVectorNode = ^TVectorNode;
  TVectorNode = record
    Obj: TPersistent;
    function IsList: Boolean;
    function IsGraphic: Boolean;
    function IsPart: Boolean;

    //function GetList: TJDVectorList;
    function GetGraphic: TJDVectorGraphic;
    function GetPart: TJDVectorPart;
  end;

type
  TfrmJDVectorEditor = class(TForm)
    TB: TToolBar;
    ActImg16: TImageList;
    ActImg24: TImageList;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    CoolBar1: TCoolBar;
    ToolBar2: TToolBar;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    Stat: TStatusBar;
    PartImg16: TImageList;
    MM: TMainMenu;
    File1: TMenuItem;
    New1: TMenuItem;
    Open1: TMenuItem;
    Open2: TMenuItem;
    SaveAs1: TMenuItem;
    SaveAs2: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    Edit1: TMenuItem;
    View1: TMenuItem;
    View2: TMenuItem;
    Help1: TMenuItem;
    Undo1: TMenuItem;
    Undo2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    SelectNone1: TMenuItem;
    SelectNone2: TMenuItem;
    Copy1: TMenuItem;
    Copy2: TMenuItem;
    Paste1: TMenuItem;
    Paste2: TMenuItem;
    PartStructure1: TMenuItem;
    PartStructure2: TMenuItem;
    AppSettings1: TMenuItem;
    ZoomIn1: TMenuItem;
    ZoomOut1: TMenuItem;
    N5: TMenuItem;
    Graphic1: TMenuItem;
    Graphic2: TMenuItem;
    popParts: TPopupMenu;
    NewPart1: TMenuItem;
    NewPart2: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    SelectAll1: TMenuItem;
    DockMgr: TLMDDockManager;
    ActMgr: TActionManager;
    actFileNew: TAction;
    actFileOpen: TAction;
    actFileSave: TAction;
    actFileSaveAs: TAction;
    actEditCut: TAction;
    actEditCopy: TAction;
    actEditPaste: TAction;
    actGraphicNew: TAction;
    actGraphicNewPart: TAction;
    actGraphicDelete: TAction;
    LMDComponentBar1: TLMDComponentBar;
    Dock: TLMDDockSite;
    dpMain: TLMDDockPanel;
    SB: TScrollBox;
    LMDDockPanel1: TLMDDockPanel;
    tvStructure: TVirtualStringTree;
    LMDDockPanel3: TLMDDockPanel;
    tvProps: TVirtualStringTree;
    ToolButton14: TToolButton;
    NewGraphic1: TMenuItem;
    Img: TJDVectorImage;
    ActGlyphs: TJDFontGlyphs;
    PartGlyphs: TJDFontGlyphs;
    procedure actNewExecute(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure actFileSaveExecute(Sender: TObject);
    procedure actEditCopyExecute(Sender: TObject);
    procedure actPasteExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SBMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure ImgMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ImgExit(Sender: TObject);
    procedure tvPropsGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: string);
    procedure tvPropsEditing(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var Allowed: Boolean);
    procedure tvPropsNewText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; NewText: string);
    procedure tvStructureGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure tvStructureGetImageIndexEx(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: TImageIndex;
      var ImageList: TCustomImageList);
    procedure tvStructureFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure tvPropsCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; out EditLink: IVTEditLink);
    procedure tvPropsFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex);
    procedure actGraphicNewPartExecute(Sender: TObject);
    procedure actGraphicDeleteExecute(Sender: TObject);
    procedure actGraphicNewExecute(Sender: TObject);
    procedure tvPropsEdited(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex);
    procedure actEditCutExecute(Sender: TObject);
    procedure actFileSaveAsExecute(Sender: TObject);
  private
    FMode: TEditorMode;
    procedure PopulateValEdit(Node: PVectorNode);
    procedure SetupVirtualTree;
    procedure LoadStructureNode(Parent: PVirtualNode; Obj: TPersistent);
    procedure PopulateTreeFromObject(Obj: TPersistent;
      ParentNode: PVirtualNode);
    procedure ApplyMode;
  public
    constructor Create(AOwner: TComponent); override;
    constructor CreateIDE;
    procedure LoadGraphic(AGraphic: TJDVectorGraphic);
  end;

var
  frmJDVectorEditor: TfrmJDVectorEditor;

implementation

{$R *.dfm}

uses
  VirtualTrees.EditLink;

{ TVTTextEditLink }

type
  TVTTextEditLink = class(TInterfacedObject, IVTEditLink)
  private
    FEdit: TEdit;
    FTree: TBaseVirtualTree;
    FNode: PVirtualNode;
    FColumn: Integer;
    procedure EditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  public
    constructor Create;
    destructor Destroy; override;
    function PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean; stdcall;
    function BeginEdit: Boolean; stdcall;
    function EndEdit: Boolean; stdcall;
    function CancelEdit: Boolean; stdcall;
    function GetBounds: TRect; stdcall;
    procedure SetBounds(Rect: TRect); stdcall;
    procedure ProcessMessage(var Message: TMessage); stdcall;
  end;

constructor TVTTextEditLink.Create;
begin
  inherited Create;
  FEdit := TEdit.Create(nil);
  FEdit.OnKeyDown:= EditKeyDown;
end;

destructor TVTTextEditLink.Destroy;
begin
  FEdit.Free;
  inherited Destroy;
end;

procedure TVTTextEditLink.EditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  try
    case Key of

      VK_RETURN: begin
        //TVirtualStringTree(FTree).OnEdited(FTree, FNode, FColumn);
        FTree.EndEditNode;
        Key:= 0;
      end;

      VK_UP, VK_DOWN: begin
        FTree.EndEditNode;
        // **Navigate to previous/next property**
        if Key = VK_UP then
          FTree.FocusedNode := FTree.GetPrevious(FNode)
        else
          FTree.FocusedNode := FTree.GetNext(FNode);
        FTree.EditNode(FTree.FocusedNode, FColumn);
        Key:= 0;
      end;

    end;
  except
    on E: Exception do begin
      //TODO
    end;
  end;
end;

function TVTTextEditLink.PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean; stdcall;
var
  Data: PPropertyItem;
begin
  FTree := Tree;
  FNode := Node;
  FColumn := Column;
  FEdit.Parent := TWinControl(Tree);

  Data := FTree.GetNodeData(FNode);
  if Assigned(Data) then
    FEdit.Text := Data^.Value;

  Result := True;
end;

function TVTTextEditLink.BeginEdit: Boolean; stdcall;
begin
  FEdit.Show;
  FEdit.SetFocus;
  Result := True;
end;

function TVTTextEditLink.EndEdit: Boolean; stdcall;
var
  Data: PPropertyItem;
begin
  FEdit.Hide;
  Data := FTree.GetNodeData(FNode);
  if Assigned(Data) then begin
    Data^.Value := FEdit.Text;

  end;
  Result := True;
end;

function TVTTextEditLink.CancelEdit: Boolean; stdcall;
begin
  FEdit.Hide;
  Result := True;
end;

procedure TVTTextEditLink.SetBounds(Rect: TRect); stdcall;
begin
  Rect.Width := FTree.Header.Columns[FColumn].Width; // ✅ Match column width
  FEdit.BoundsRect := Rect;
end;

function TVTTextEditLink.GetBounds: TRect; stdcall;
begin
  Result := FEdit.BoundsRect;
end;

procedure TVTTextEditLink.ProcessMessage(var Message: TMessage); stdcall;
begin
  FEdit.Perform(Message.Msg, Message.WParam, Message.LParam);
end;

{ TVTComboBoxEditLink }

type
  TVTComboBoxEditLink = class(TInterfacedObject, IVTEditLink)
  private
    FCombo: TComboBox;
    FTree: TBaseVirtualTree;
    FNode: PVirtualNode;
    FColumn: Integer;
    FItems: TStringList;
  public
    constructor Create(Items: TStringList);
    destructor Destroy; override;
    function PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean; stdcall;
    function BeginEdit: Boolean; stdcall;
    function EndEdit: Boolean; stdcall;
    function CancelEdit: Boolean; stdcall;
    function GetBounds: TRect; stdcall;
    procedure SetBounds(Rect: TRect); stdcall;
    procedure ProcessMessage(var Message: TMessage); stdcall;
  end;

constructor TVTComboBoxEditLink.Create(Items: TStringList);
begin
  inherited Create;
  FCombo := TComboBox.Create(nil);
  FItems:= TStringList.Create;
  FItems.Assign(Items);
end;

destructor TVTComboBoxEditLink.Destroy;
begin
  FreeAndNil(FItems);
  FCombo.Free;
  inherited Destroy;
end;

function TVTComboBoxEditLink.PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean; stdcall;
var
  Data: PPropertyItem;
begin
  FTree := Tree;
  FNode := Node;
  FColumn := Column;

  FCombo.Parent := TWinControl(Tree);
  FCombo.Visible := True;
  FCombo.Items.Assign(FItems);

  Data := FTree.GetNodeData(FNode);
  if Assigned(Data) then
    FCombo.Text := Data^.Value;

  Result := True;
end;

function TVTComboBoxEditLink.BeginEdit: Boolean; stdcall;
begin
  FCombo.Show;
  FCombo.SetFocus;
  Result := True;
end;

function TVTComboBoxEditLink.EndEdit: Boolean; stdcall;
var
  Data: PPropertyItem;
begin
  FCombo.Hide;
  Data := FTree.GetNodeData(FNode);
  if Assigned(Data) then
    Data^.Value := FCombo.Text;
  Result := True;
end;

function TVTComboBoxEditLink.CancelEdit: Boolean; stdcall;
begin
  FCombo.Hide;
  Result := True;
end;

procedure TVTComboBoxEditLink.SetBounds(Rect: TRect); stdcall;
begin
  Rect.Width := FTree.Header.Columns[FColumn].Width; // ✅ Match column width
  FCombo.BoundsRect := Rect;
end;

function TVTComboBoxEditLink.GetBounds: TRect; stdcall;
begin
  Result := FCombo.BoundsRect;
end;

procedure TVTComboBoxEditLink.ProcessMessage(var Message: TMessage); stdcall;
begin
  case Message.Msg of
    WM_KEYDOWN:
      case Message.WParam of
        VK_RETURN:
        begin
          // **Confirm edit immediately when Enter is pressed**
          TVirtualStringTree(FTree).OnEdited(FTree, FNode, FColumn);
          FTree.EndEditNode;
        end;

        VK_UP, VK_DOWN:
        begin
          // **Navigate to previous/next property**
          FTree.EndEditNode;
          if Message.WParam = VK_UP then
            FTree.FocusedNode := FTree.GetPrevious(FNode)
          else
            FTree.FocusedNode := FTree.GetNext(FNode);
          FTree.EditNode(FTree.FocusedNode, FColumn);
        end;
      end;
  end;

  FCombo.Perform(Message.Msg, Message.WParam, Message.LParam);
end;

{ TVTCheckListEditLink }

type
  TVTCheckListEditLink = class(TInterfacedObject, IVTEditLink)
  private
    FCheckList: TCheckListBox;
    FTree: TBaseVirtualTree;
    FNode: PVirtualNode;
    FColumn: Integer;
  public
    constructor Create(Items: TStringList);
    destructor Destroy; override;
    function PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean; stdcall;
    function BeginEdit: Boolean; stdcall;
    function EndEdit: Boolean; stdcall;
    function CancelEdit: Boolean; stdcall;
    function GetBounds: TRect; stdcall;
    procedure SetBounds(Rect: TRect); stdcall;
    procedure ProcessMessage(var Message: TMessage); stdcall;
  end;

constructor TVTCheckListEditLink.Create(Items: TStringList);
begin
  inherited Create;
  FCheckList := TCheckListBox.Create(nil);
  FCheckList.Items.Assign(Items);
end;

destructor TVTCheckListEditLink.Destroy;
begin
  FCheckList.Free;
  inherited Destroy;
end;

function TVTCheckListEditLink.PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean; stdcall;
begin
  FTree := Tree;
  FNode := Node;
  FColumn := Column;
  FCheckList.Parent := TWinControl(Tree);
  Result := True;
end;

function TVTCheckListEditLink.BeginEdit: Boolean; stdcall;
begin
  FCheckList.Show;
  FCheckList.SetFocus;
  Result := True;
end;

function TVTCheckListEditLink.EndEdit: Boolean; stdcall;
begin
  FCheckList.Hide;
  Result := True;
end;

function TVTCheckListEditLink.CancelEdit: Boolean; stdcall;
begin
  FCheckList.Hide;
  Result := True;
end;

procedure TVTCheckListEditLink.SetBounds(Rect: TRect); stdcall;
begin
  Rect.Width := FTree.Header.Columns[FColumn].Width; // ✅ Match column width
  FCheckList.BoundsRect := Rect;
end;

function TVTCheckListEditLink.GetBounds: TRect; stdcall;
begin
  Result := FCheckList.BoundsRect;
end;

procedure TVTCheckListEditLink.ProcessMessage(var Message: TMessage); stdcall;
begin
  case Message.Msg of
    WM_KEYDOWN:
      case Message.WParam of
        VK_RETURN:
        begin
          // **Confirm edit immediately when Enter is pressed**
          TVirtualStringTree(FTree).OnEdited(FTree, FNode, FColumn);
          FTree.EndEditNode;
        end;

        VK_UP, VK_DOWN:
        begin
          // **Navigate to previous/next property**
          FTree.EndEditNode;
          if Message.WParam = VK_UP then
            FTree.FocusedNode := FTree.GetPrevious(FNode)
          else
            FTree.FocusedNode := FTree.GetNext(FNode);
          FTree.EditNode(FTree.FocusedNode, FColumn);
        end;
      end;
  end;

  FCheckList.Perform(Message.Msg, Message.WParam, Message.LParam);
end;






{ TfrmJDVectorEditor }

procedure TfrmJDVectorEditor.FormCreate(Sender: TObject);
begin
  ColorManager.BaseColor:= clBlack;

  Dock.Align:= alClient;

  SB.Align:= alClient;
  Img.Top:= 0;
  Img.Left:= 0;
  Img.Height:= Img.Width;

  SetupVirtualTree;
  PopulateValEdit(nil);

  var G:= TJDVectorGraphic.Create(nil);
  try
    G.Assign(Img.Graphic);
    LoadGraphic(G);
  finally
    G.Free;
  end;
end;

procedure TfrmJDVectorEditor.SetupVirtualTree;
begin
  tvProps.NodeDataSize := SizeOf(TPropertyItem);
  tvProps.TreeOptions.SelectionOptions := tvProps.TreeOptions.SelectionOptions + [toFullRowSelect];

  tvStructure.NodeDataSize := SizeOf(TVectorNode);
  tvStructure.TreeOptions.SelectionOptions := tvStructure.TreeOptions.SelectionOptions + [toFullRowSelect];
end;

procedure TfrmJDVectorEditor.LoadGraphic(AGraphic: TJDVectorGraphic);
begin
  Img.Graphic.Assign(AGraphic);
  Img.Invalidate;

  tvStructure.Clear;
  LoadStructureNode(nil, Img.Graphic);
  tvStructure.FullExpand;
end;

procedure TfrmJDVectorEditor.LoadStructureNode(Parent: PVirtualNode;
  Obj: TPersistent);
var
  Data: PVectorNode;
  function A(const AParent: PVirtualNode; const AObj: TPersistent): PVirtualNode;
  begin
    Result := tvStructure.AddChild(AParent);
    Data := tvStructure.GetNodeData(Result);
    Data^.Obj:= AObj;
  end;
begin
  if Obj is TJDVectorGraphic then begin
    var G:= TJDVectorGraphic(Obj);
    var N:= A(Parent, G);
    for var X := 0 to G.Parts.Count-1 do begin
      var P:= G.Parts[X];
      LoadStructureNode(N, P);
    end;
  end else
  if Obj is TJDVectorPart then begin
    var P:= TJDVectorPart(Obj);
    var N:= A(Parent, P);
    for var X := 0 to P.Parts.Count-1 do begin
      var P2:= P.Parts[X];
      LoadStructureNode(N, P2);
    end;
  end else begin
    //TODO
  end;
end;

procedure TfrmJDVectorEditor.ImgExit(Sender: TObject);
begin
  Stat.Panels[0].Text:= '';
end;

procedure TfrmJDVectorEditor.ImgMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  var R: TJDRect:= Img.DrawRect;
  var P:= Point(X, Y);
  if R.ContainsPoint(P) then begin
    var Percs: TJDPoint;
    Percs.X:= ((X - R.Left) / R.Width) * 100;
    Percs.Y:= ((Y - R.Top) / R.Height) * 100;
    Stat.Panels[0].Text:= Percs.AsText(True, '0.##%');
  end else begin
    Stat.Panels[0].Text:= '';
  end;
end;

procedure TfrmJDVectorEditor.actEditCopyExecute(Sender: TObject);
begin
  Clipboard.AsText:= Img.Graphic.SaveToString;
  //TODO: Copy selected part node...
end;

procedure TfrmJDVectorEditor.actGraphicDeleteExecute(Sender: TObject);
begin
  //TODO: Delete part / graphic...

end;

procedure TfrmJDVectorEditor.actEditCutExecute(Sender: TObject);
begin
  Clipboard.AsText:= Img.Graphic.SaveToString;
  Img.Graphic.Parts.Clear;
  //TODO: Cut selected part node...
end;

procedure TfrmJDVectorEditor.actNewExecute(Sender: TObject);
begin
  if MessageDlg('Are you sure you wish to clear image and start a new one?',
    mtConfirmation, [mbYes,mbNo], 0) = mrYes then
  begin
    Img.Graphic.Parts.Clear;
  end;
end;

procedure TfrmJDVectorEditor.actGraphicNewExecute(Sender: TObject);
begin
  //TODO: Create new graphic object...

  //TODO: Open in new tab...

  //TODO: Add to structure tree...

end;

procedure TfrmJDVectorEditor.actGraphicNewPartExecute(Sender: TObject);
begin
  //TODO: Create a new part nested beneath selected parent...

end;

procedure TfrmJDVectorEditor.actOpenExecute(Sender: TObject);
begin
  //TODO: Execute open dialog to open file...

end;

procedure TfrmJDVectorEditor.actPasteExecute(Sender: TObject);
begin
  Img.Graphic.LoadFromString(Clipboard.AsText);
  Self.LoadGraphic(Img.Graphic);
end;

constructor TfrmJDVectorEditor.Create(AOwner: TComponent);
begin
  inherited;
  FMode:= TEditorMode.emFile;
  ApplyMode;
end;

constructor TfrmJDVectorEditor.CreateIDE;
begin
  inherited Create(nil);
  FMode:= TEditorMode.emIntegrated;
  ApplyMode;
end;

procedure TfrmJDVectorEditor.ApplyMode;
begin
  case FMode of
    emFile: begin
      //Setup file file editing...

    end;
    emIntegrated: begin
      //Setup for Delphi IDE editing...

    end;
  end;
end;

procedure TfrmJDVectorEditor.actFileSaveAsExecute(Sender: TObject);
begin
  //TODO: Save vector image as new file...

end;

procedure TfrmJDVectorEditor.actFileSaveExecute(Sender: TObject);
begin
  //TODO: Save vector image...

end;

procedure TfrmJDVectorEditor.SBMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  Amt: Integer;
begin
  if WheelDelta > 0 then
    Amt:= 20
  else if WheelDelta < 0 then
    Amt:= -20
  else
    Amt:= 0;
  if ssCtrl in Shift then begin
    //Zoom in and out...
    if WheelDelta > 0 then begin
      Img.Width:= Img.Width + Amt;
      Img.Height:= Img.Width;
    end else
    if WheelDelta < 0 then begin
      if Img.Width >= 50 then begin
        Img.Width:= Img.Width + Amt;
        Img.Height:= Img.Width;
      end;
    end;
  end else
  if ssShift in Shift then begin
    //Scroll left and right...
    SB.HorzScrollBar.Position:= SB.HorzScrollBar.Position + -Amt;
  end else begin
    //Scroll up and down...
    SB.VertScrollBar.Position:= SB.VertScrollBar.Position + -Amt;
  end;
end;

procedure TfrmJDVectorEditor.tvPropsCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; out EditLink: IVTEditLink);
var
  Data: PPropertyItem;
begin
  Data := Sender.GetNodeData(Node);
  if Assigned(Data) and (Column = 1) then
  begin
    case Data^.PropertyType of
      ptString, ptInteger, ptFloat:
        EditLink := TVTTextEditLink.Create;
      ptBoolean, ptEnum:
        EditLink := TVTComboBoxEditLink.Create(Data^.EnumValues);
      ptSet:
        EditLink := TVTCheckListEditLink.Create(Data^.EnumValues);
      ptButton:
        ShowMessage('Button-Triggered Editor Needed');
    end;
  end;
end;

procedure TfrmJDVectorEditor.tvPropsEdited(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
var
  Data: PPropertyItem;
begin
  Data := Sender.GetNodeData(Node);
  if Assigned(Data) and (Column = 1) then
  begin
    // Update the actual property in the object instead of just the reference
    SetPropValue(Data^.Owner, Data^.Name, Data^.Value);
  end;
end;

procedure TfrmJDVectorEditor.tvPropsEditing(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
var
  Data: PPropertyItem;
begin
  Allowed := (Column = 1);
  if Allowed then begin
    Data := Sender.GetNodeData(Node);
    if Assigned(Data) then begin
      if Assigned(Data.PersistentObject) then
        Allowed:= False;
    end;
  end;
end;

procedure TfrmJDVectorEditor.tvPropsFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  if Assigned(tvProps.FocusedNode) then
    tvProps.EditNode(tvProps.FocusedNode, 1); // Start editing in column 1
end;

procedure TfrmJDVectorEditor.tvPropsGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  Data: PPropertyItem;
begin
  Data := Sender.GetNodeData(Node);
  if Assigned(Data) then
  begin
    case Column of
      0: CellText := Data^.Name;
      1: CellText := Data^.Value;
    end;
  end;
end;

procedure TfrmJDVectorEditor.tvPropsNewText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; NewText: string);
//var
  //Data: PPropertyItem;
  //PropInfo: PPropInfo;
begin
  {
  Data := Sender.GetNodeData(Node);
  if Assigned(Data) and (Column = 1) then begin
    Data^.Value := Text;
    //TODO: Update actual value, not just the reference...

    // **Find the actual property from the owner object**
    PropInfo := GetPropInfo(Data^.Owner.ClassType, Data^.Name);
    if Assigned(PropInfo) then begin
      // **Update the actual property value**
      SetPropValue(Data^.Owner, Data^.Name, NewText);
    end;

  end;
  }
end;

procedure TfrmJDVectorEditor.tvStructureFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  if Node = nil then
    Exit;

  var Data: PVectorNode:= Node.GetData;
  PopulateValEdit(Data);

  //TODO: Highlight selection in image...

end;

procedure TfrmJDVectorEditor.PopulateValEdit(Node: PVectorNode);
var
  //N1, N2, N3, N4: PVirtualNode;
  Data: PPropertyItem;
  function A(const Parent: PVirtualNode; const Name, Value: String): PVirtualNode;
  begin
    Result := tvProps.AddChild(Parent); // Add a root-level node
    Data := tvProps.GetNodeData(Result);
    Data^.Name := Name;
    Data^.Value := Value;
  end;
begin
  tvProps.Clear;

  if Node = nil then
    Exit;

  if tvStructure.SelectedCount = 0 then
    Exit;

  PopulateTreeFromObject(Node.Obj, nil);

end;

function GetEnumNames(TypeInfo: PTypeInfo): TStringList;
var
  TypeData: PTypeData;
  i: Integer;
begin
  Result := TStringList.Create;
  if Assigned(TypeInfo) and (TypeInfo^.Kind = tkEnumeration) then
  begin
    TypeData := GetTypeData(TypeInfo);
    for i := TypeData^.MinValue to TypeData^.MaxValue do
      Result.Add(GetEnumName(TypeInfo, i)); // Corrected: Using TypeInfo directly
  end;
end;

function GetSetNames(TypeInfo: PTypeInfo): TStringList;
var
  TypeData: PTypeData;
  EnumType: PTypeInfo;
  i: Integer;
begin
  Result := TStringList.Create;
  if Assigned(TypeInfo) and (TypeInfo^.Kind = tkSet) then
  begin
    TypeData := GetTypeData(TypeInfo);
    EnumType := TypeData^.CompType^; // Properly accessing the underlying enum type

    if Assigned(EnumType) and (EnumType^.Kind = tkEnumeration) then
    begin
      for i := GetTypeData(EnumType)^.MinValue to GetTypeData(EnumType)^.MaxValue do
        Result.Add(GetEnumName(EnumType, i)); // Corrected: Using EnumType directly
    end;
  end;
end;

procedure TfrmJDVectorEditor.PopulateTreeFromObject(Obj: TPersistent; ParentNode: PVirtualNode);
var
  Node: PVirtualNode;
  Data: PPropertyItem;
  PropList: PPropList;
  PropCount, i: Integer;
  PropObj: TObject;
begin
  if Obj = nil then Exit;

  // Get published properties count
  PropCount := GetPropList(Obj.ClassInfo, tkProperties, nil);
  if PropCount = 0 then Exit;

  GetMem(PropList, PropCount * SizeOf(PPropInfo));
  try
    GetPropList(Obj.ClassInfo, tkProperties, PropList);

    for i := 0 to PropCount - 1 do begin
      Node := tvProps.AddChild(ParentNode);
      Data := tvProps.GetNodeData(Node);

      if Assigned(Data) then begin
        Data^.Name := string(PropList[i]^.Name);
        Data^.Value := VarToStr(GetPropValue(Obj, String(PropList[i]^.Name)));

        Data.Owner:= Obj;

        // Detect Property Type
        case PropList[i]^.PropType^.Kind of
          tkInteger, tkInt64:
            Data^.PropertyType := ptInteger;

          tkFloat:
            Data^.PropertyType := ptFloat;

          tkEnumeration:
          begin
            Data^.PropertyType := ptEnum;
            Data^.EnumValues := GetEnumNames(PropList[i]^.PropType^);
          end;

          tkSet:
          begin
            Data^.PropertyType := ptSet;
            Data^.EnumValues := GetSetNames(PropList[i]^.PropType^);
          end;

          tkClass:
          begin
            PropObj := GetObjectProp(Obj, String(PropList[i]^.Name));
            if PropObj is TPersistent then
            begin
              Data^.PropertyType := ptObject;
              Data^.PersistentObject := TPersistent(PropObj);
              Data^.Value:= PropObj.ClassName;
              PopulateTreeFromObject(TPersistent(PropObj), Node);
            end;
          end;

          tkUString, tkLString, tkWString, tkString:
          begin
            if SameText(Data^.Name, 'FilePath') then
              Data^.PropertyType := ptButton;
            if SameText(Data^.Name, 'Color') then
              Data^.PropertyType := ptButton;
          end;

          else
            Data^.PropertyType := ptString;
        end;
      end;
    end;
  finally
    FreeMem(PropList); // Free memory
  end;
end;

procedure TfrmJDVectorEditor.tvStructureGetImageIndexEx(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: TImageIndex;
  var ImageList: TCustomImageList);
var
  Data: PVectorNode;
begin
  if not (Kind in [ikNormal,ikSelected]) then
    Exit;

  Data := Sender.GetNodeData(Node);
  if Assigned(Data) then begin
    if Data^.IsList then
      ImageIndex:= 2
    else if Data^.IsGraphic then
      ImageIndex:= 0
    else if Data^.IsPart then
      ImageIndex:= 1;
  end;
end;

procedure TfrmJDVectorEditor.tvStructureGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  Data: PVectorNode;
begin
  Data := Sender.GetNodeData(Node);
  try
    if Assigned(Data) then begin
      if Data^.IsGraphic then begin
        var G:= Data^.GetGraphic;
        CellText:= G.Caption;
        if CellText = '' then
          CellText:= 'Unnamed Graphic';
      end else
      if Data^.IsPart then begin
        var P:= Data^.GetPart;
        CellText:= P.Caption;
        if CellText = '' then
          CellText:= 'Unnamed Part';
      end else begin
        //TODO
      end;
    end;
  except
    on E: Exception do begin
      //TODO
    end;
  end;
end;

{ TVectorNode }

function TVectorNode.GetGraphic: TJDVectorGraphic;
begin
  Result:= TJDVectorGraphic(Obj);
end;

function TVectorNode.GetPart: TJDVectorPart;
begin
  Result:= TJDVectorPart(Obj);
end;

function TVectorNode.IsGraphic: Boolean;
begin
  Result:= Obj is TJDVectorGraphic;
end;

function TVectorNode.IsList: Boolean;
begin
  Result:= False; //TODO
end;

function TVectorNode.IsPart: Boolean;
begin
  Result:= Obj is TJDVectorPart;
end;

end.
