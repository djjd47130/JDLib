# TJDGauge Control

### About
- Dynamic and customizable gauge control, painted with GDI+.
- One control, many looks: the appearance is driven by the `GaugeType` property, which picks a gauge renderer class. New gauge types can be added by descending from `TJDGaugeBase` and registering the class with `JDRegisterGaugeType` — no changes to `TJDGauge` itself are needed.
- Each gauge shows one or more values from its `Values` collection, each with its own Min/Max, caption, color, ticks, and peak marker.
- Supports an optional font glyph (via `TJDFontGlyphs`), captions/sub-captions, crosshairs, and click events per value, caption, or glyph.
- Demo project: `JDGaugeTest` (gauges, SysMon gauges, and volume gauges).

### Related Units
- JD.Ctrls.Gauges.pas
- JD.Ctrls.Gauges.Objects.pas

## Gauge Types

`GaugeType` is a string, matched against each type's caption. The built-in types (all in `JD.Ctrls.Gauges.Objects.pas`) are:

- `Circle` (`TJDGaugeCircle`) - Circle gauge (full 360 arc).
- `Horizontal Bar` (`TJDGaugeHorzBar`) - Horizontal bar gauge (left to right).
- `Vertical Bar` (`TJDGaugeVertBar`) - Vertical bar gauge (top to bottom).
- `Pie` (`TJDGaugePie`) - Pie gauge (full 360 pie chart).
- `Needle` (`TJDGaugeNeedle`) - Needle gauge (full 360 arc).

## Properties

- GaugeType [String] - Which gauge renderer to use (see the list above).
- Values [TJDGaugeValues] - Collection of values to display. Each `TJDGaugeValue` has:
  - Value / Min / Max [Double] - The current value and its range.
  - Caption / SubCaption [String] - Text shown for the value.
  - Color [TJDColorRef] - Color of the value.
  - Peak [TJDGaugePeak] - Peak marker, with a decay thread that lets the peak fall back over time.
  - TicksMajor / TicksMinor [TJDGaugeTicks] - Tick marks (with labels).
  - Glyph [TJDFontGlyph] - Optional glyph for the value.
- MainValue [TJDGaugeValue] - Shortcut to the first value in the collection (created automatically if there is none).
- ColorMain [TJDColorRef] - Main color of the gauge.
- Thickness [Single] - Thickness of the gauge arc/bar.
- ShowValue / ShowCaption / ShowSubCaption / ShowGlyph / ShowBase / ShowRect [Boolean] - What to draw.
- ValueFormat [String] - Format string for the displayed value.
- Glyph [TJDFontGlyph] - Glyph shown in the middle of the gauge.
- Crosshairs [TJDGaugeCrosshairs] - Crosshair lines shown on hover.
- Grouping [TJDGaugeGrouping] - How multiple values are grouped/laid out.
- Split [Boolean] - Split display mode.

## Events

- OnValueClick - Fired when a value is clicked.
- OnCaptionClick - Fired when a caption is clicked.
- OnGlyphClick - Fired when the glyph is clicked.

## Basic Usage

```pascal
//Pick a gauge type (string, matched against the type's caption)...
Gauge1.GaugeType := 'Circle';

//...then drive the value. MainValue is the first value in Values,
//created automatically if the collection is empty.
Gauge1.MainValue.Min := 0;
Gauge1.MainValue.Max := 100;
Gauge1.MainValue.Value := 42;
Gauge1.MainValue.Caption := 'CPU';
```

To show more than one value, add items to the `Values` collection in the Object Inspector (or in code) and set each one's `Value`, `Min`, `Max`, `Caption`, and `Color`.

## Notes

- Fixed in the review-fixes branch: `TJDGaugeTickLabels` used to leak its `TFont` (created in the constructor, never freed in the destructor), and the peak-decay thread (`TJDGaugePeakDecayThread`) had validation and lifecycle issues (e.g. a negative delay became a ~49-day `Sleep`). Both are fixed there — see the 2026-11-13 code review (§3.25, §3.44).
