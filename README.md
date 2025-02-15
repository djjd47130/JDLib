# JDLib
JD Library of Custom Components and Controls, written by Jerry Dodge.

### NOTE:
This library is under active development, and is in no way complete until further notice. Some things are fully functional, while other things are completely unmaintained prototypes. 

### Prerequisites

JDLib is optimized for VCL in Delphi 10.4, and uses / requires the following:

- GDI+ (Built into Delphi)
- Indy (Built into Delphi)



### Documentation

[New documentation being written here](/Docs/JDLib%20Docs.md)



# JDLib Contents


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

![image](https://github.com/user-attachments/assets/c714ec12-9d92-4fc1-8172-56fe0d3b1d4f)


## Gauge Control
**[TJDGauge](/Docs/TJDGauge.md)** [ACTIVE PROJECT]

A dynamic and customizable gauge control.

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


## Color Manager
**TJDColorManager** [MOSTLY FUNCTIONAL]

A central class to manage colors in light and dark modes application-wide.


## Color Record
**TJDColor** [FULLY FUNCTIONAL]

A flexible record type with class operators to cast between RGB, HSV, CMYK, and custom color management.


## Point and Rect Records
**TJDPoint** and **TJDRect** [FULLY FUNCTIONAL]

Flexible record types with class operators to cast between `TPoint`/`TRect`, `TPointF`/`TRectF`, and `TGPPoint`/`TGPRect`.


