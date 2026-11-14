# TJDFontButton Control

### About
1. Completely custom, inherits from `TCustomControl`.
2. Comparable to a `TBitBtn` control.
3. Uses a font glyph instead of other image types for a glyph.
4. Glyph can be scaled and colored as desired.
5. Button makes use of the VCL Styles, and is themed accordingly.

### Related Units
1. **JD.Ctrls.FontButton.pas** - Contains everything related to the control itself.
2. **JD.Graphics.pas** - Contains common code related to graphics.
3. **JD.Ctrls.FontButtonEdit.pas** - Contains a component editor for the `TFontButton`
4. **JD.Ctrls.FontButtonEditCtrl** - Contains a component editor to convert other buttons to `TFontButton`

## Properties
- Cancel
- Color
- Default
- DownSize
- DrawStyle
- Font
- Image
  - AutoSize
  - Font
  - GrowSize
  - StandardColor
  - Text
  - UseStandardColor
- ImagePosition
- Kind
- Margin
- ModalResult
- Overlay
  - Font
  - Margin
  - Position
  - StandardColor
  - Text
  - UseStandardColor
- ParentColorOverride
- ShowFocusRect
- ShowGuides
- Spacing
- StyleColors
  - scCaption
  - scImage
  - scBack
  - scFrame
- SubText
- SubTextFont
- SubTextStyle
- Text

## Notes
- The button is keyboard-operable: Space activates it on release,
  Return activates it when it is the default button (or has focus),
  and Escape activates it when Cancel is set. Mnemonics (`&` in Text)
  work through CMDialogChar.
- `Image.GrowSize` controls the hover grow: set it to 0 to disable
  the grow entirely.
- `SubText` is a secondary caption drawn centered under the main
  caption (`fsBelow`), or on the opposite side of the image from the
  caption (`fsOpposite`).
- `Overlay` is a second, smaller glyph (1/3 the main glyph size)
  drawn at a corner or the center of the main glyph.
- With `ParentColorOverride` set, the caption and glyph colors are
  picked to contrast with the parent control's background (white on
  dark parents, black on light ones) instead of using the style or
  standard colors.
- Action support is implemented (`Action` property, `ActionChange`
  copies Caption, Enabled, Visible and HelpContext from the action).
- Theme handling uses VCL Styles when a style other than Windows is
  active, and the Windows UxTheme button background otherwise.
  The theme handle is opened lazily, so buttons created at runtime
  (not streamed from a form) get a themed background too.

