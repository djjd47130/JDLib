# JDLib Documentation

### Components

The following components are available:

- **[TJDFontButton](/Docs/TJDFontButton.md)** Control - A button which supports a font glyph instead of a graphic image.
-  **[TJDSmoothMove](/Docs/TJDSmoothMove.md)** Component - Event-driven component to manage the movement of controls or values in general. 
    - Comparable to the "Float Animations" available in Firemonkey.
- **TJDPageMenu** Control - A custom control to switch between pages. 
    - Similar to, but far different from, a THeaderControl.
- **TJDImageGrid** Control - A custom control to display a list of custom-drawn images.
- **TJDSideMenu** Control - A custom control to display a main menu on the left side.
- **[TJDGauge](/Docs/TJDGauge.md)** Control - A dynamic and customizable gauge control.
- **TJDFontGlyph** Property - A character representing a glyph in a specific font.
- **TJDFontGlyphs** Component - Collection of glyphs to be rendered into a collection of image lists.
- **TJDSystemMonitor** Component - Detects and reports system information such as CPU, RAM, and Storage.
- **TJDVolumeControls** Component - Provides direct access to system Volume and Mute controls.
- **[TJDPlotChart](/Docs/TJDPlotChart.md)** Control - A custom control allowing users to create and manage plot points to generate data.
- **TJDLogger / TJDFileLogger / TJDConsoleLogger** Component - Threaded logging engine: log entries are queued on a background thread and dispatched to logger components (file, console, or custom).
- **TJDFavicons** Component - Fetches and caches website favicons (directly, or via the Google s2 API) into image lists.
- **TJDVectorImage** Control - Renders a vector graphic (`TJDVectorGraphic`: shapes built from points/parts, loadable from JSON) to a control canvas.
- **TJDChipList** Control - A custom control to display a list of "chips" (small tag-like items).
- **TJDListBox** Control - A custom-drawn list box control.

### Building the design-time package

The runtime package (`JDLibComponents.dpk`) builds with the RTL/VCL plus Indy and XSuperObject. (The old `dwsLibRuntime` requirement was dropped in the review-fixes branch — nothing in the package used DWScript.) The design-time package (`DclJDLibComponents.dpk`) additionally requires **commercial LMD components** (`lmdrtl`, `lmdrtdocking`, `lmdrtrtlx`, `lmdrtcore`, `lmdrtelcore`, `lmdrtinspector`, `lmdrtdesign`, `lmdrtide`) and **VirtualTreeview** (`VirtualTreesR`) to be installed — a fresh checkout cannot build the design-time package without them.
