# JDLib
JD Library of Custom Components and Controls, written by Jerry Dodge.

### NOTE:
This library is under active development, and is in no way complete until further notice. Some things are fully functional, while other things are completely unmaintained prototypes. 

### Prerequisites

JDLib is optimized for VCL in Delphi 10.4, and uses / requires the following:

- GDI+ (Built into Delphi)
- Indy (Built into Delphi)


## Custom Color System

It's important to note that various components / controls across JDLib make use of a centralized color management mechanism. This includes a set of standardized color values which can be customized in the different light/dark color modes. For example, when in light mode, `fcYellow` would be a darker yellow, whereas in dark mode, it would be a lighter yellow. What's important is to maintain a contrast of colors depending on the current base color.

Please refer to `TJDColorManager` for more information.


### Documentation

[New documentation being written here](/Docs/JDLib%20Docs.md)




# JDLib Contents

### Status Labels

Note how each item listed below has a [BOLD STATUS] by it. The meanings are:

- [FULLY FUNCTIONAL] - Tested and used in production projects. Does not mean bug-free or complete, however. 
- [MOSTLY FUNCTIONAL] - Functional for the most part, but not suitable for any production use yet.
- [ACTIVE PROJECT] - Currently in active development, and not suitable for production. 
- [PROTOTYPE] - A concept which has been started but put on the side, and is far from production.


## Font Button Control
**[TJDFontButton](/Docs/TJDFontButton.md)** [MOSTLY FUNCTIONAL]

A button which supports a font glyph instead of a graphic image, among other unique features.

- Completely custom, not inheriting from any existing button control.
- Options for where and how to display the glyph, if at all.
- Transparent background options.
- Optional overlay glyph.
- Optional sub-caption.
- Supports VCL styles.


## Plot Chart Control
**[TJDPlotChart](/Docs/TJDPlotChart.md)** [ACTIVE PROJECT]

A custom control allowing users to create and manage plot points to generate data.

- Run-time UI control of plot points by dragging plot points.
- Uses GDI+ for smooth graphics.
- Several UI/UX options to control behavior.
- Ultimately calculate Y-axis value based on any given X-axis value.
- Used for variable control, such as fan speed, volume, etc.
- Not necessarily intended for general display of data - instead geared towards user data input.

![image](https://github.com/user-attachments/assets/c714ec12-9d92-4fc1-8172-56fe0d3b1d4f)


## Gauge Control
**[TJDGauge](/Docs/TJDGauge.md)** [ACTIVE PROJECT]

A dynamic and customizable gauge control.

- Variety of gauge types to choose from for different appearances. For example, Horizontal Bar, Vertical Bar, Arc...
- Uses GDI+ for smooth graphics.
- Supports importing third-party gauge implementations on the same backbone.
- Supports more than 1 value, with options for how to combine values together.
- Several options to control UI/UX.
- Used to provide enhanced UI display of one or a few data points.
- One big goal is to also treat it as a track bar of sorts.

![image](https://github.com/user-attachments/assets/2e56bd3b-1f4a-47ff-8e6e-f6e1867f585a)


## Smooth Move Component
 **[TJDSmoothMove](/Docs/TJDSmoothMove.md)** [FULLY FUNCTIONAL]
 
Event-driven component to manage the movement of controls or values in general. Comparable to the "Float Animations" available in Firemonkey.

- Entirely stand-alone - is not linked with any components or properties.
- Background thread to perform calculations and trigger events.
- Options for smooth "snap" movements.


## Font Glyphs Component
**TJDFontGlyphs** [FULLY FUNCTIONAL]

Collection of glyphs to be rendered into a collection of image lists.

- Attaches to one or more `TImageList` components.
- Generate collection of `TJDGlyphRef`s with font and color controls.
- Attached image lists automatically synchronized with registered glyphs.
- Same glyphs easily replicated among different size image lists.


## Page Menu Control
**TJDPageMenu** [PROTOTYPE]

A custom control to switch between pages. 

- Similar to, but far different from, a THeaderControl.
- Inspired by the TChromeTabs control, but intended to be much more light-weight.


## Image Grid Control
**TJDImageGrid** [PROTOTYPE]

A custom control to display a list of custom-drawn images.


## Side Menu Control
**TJDSideMenu** [PROTOTYPE]

A custom control to display a main menu on the left side.


## System Monitor Component
**TJDSystemMonitor** [MOSTLY FUNCTIONAL]

Detects and reports system information such as CPU, RAM, and Storage.


## Volume Controls Component
**TJDVolumeControls** [MOSTLY FUNCTIONAL]

Provides direct access to system Volume and Mute controls.

- Directly read and write system volume and mute state.
- Events instantly triggered upon system volume or mute state changes.
- Allows you to implement third-party system volume and mute control.


## Font Glyph Property
**TJDFontGlyph** [FULLY FUNCTIONAL]

A character representing a glyph in a specific font.

- Used as property on components to devine a font glyph.
- Integrates custom property editor to browse glyphs in a given font.


## Color Manager
**[TJDColorManager](/Docs/TJDColorManager.md)** [MOSTLY FUNCTIONAL]

A central class to manage colors in light and dark modes application-wide.

- Detects dark/light color mode based on current VCL style.
- Implements several standardized colors which vary depending on color mode.
- Broadcasts color and style changes to any registered components or controls.


## Color Record
`TJDColor` [FULLY FUNCTIONAL]

A flexible record type with class operators to cast between RGB, HSV, CMYK, and custom color management.

- Implicitly cast to and from `TColor`.
- Direct RGB value support.
- Direct HSV value support.
- Direct CMYK value support.
- Alpha transparency support. [IN DEVELOPMENT]
- JD standard color support.

  

## Point and Rect Records
**TJDPoint** and **TJDRect** [FULLY FUNCTIONAL]

Flexible record types with class operators to cast between `TPoint`/`TRect`, `TPointF`/`TRectF`, and `TGPPoint`/`TGPRect`.

- `TJDPoint` and `TJDRect` naturally use Single for X/Y values.
- Implicitly cast `TJDPoint` to and from `TPoint`, `TPointF`, and `TGPPoint`.
- Implicitly cast `TJDRect` to and from `TRect`, `TRectF`, and `TGPRect`.
- Helpful control methods such as `Move`, `Inflate`, `Deflate`.
- Helpful referemce methods such as `TJDRect.TopRight` point.

