# TJDColorManager

Centralized object to manage standardized colors in light and dar color modes.

## ColorManager Access

There is a global variable in `JD.Graphics.pas` named `ColorManager`, of type `TJDColorManager`. It's actually more of an auto-creating centralized component, with global controls over the JD color system. It's not intended to create multiple instances anywhere else - just accessing through this global `ColorManager`.

## Color Mode

The property `ColorMode` is of type `TJDColorMode`, which is one of the following enum values:

- cmLight
- cmMedium
- cmDark

## Base Color

## Standard Colors

## VCL Styles

## New Named Color Concept
