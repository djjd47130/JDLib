# _OLD — Archived units

These units were moved out of the active `Source/` tree during the
November 2026 code-review cleanup (branch `fix/review-fixes-2026-11-13`).
They are kept here for reference — nothing in the packages uses them anymore,
and they are not compiled into `JDLibComponents`.

- `JD.VolumeControls2.pas` — second, cross-platform attempt at the volume
  control. Broken on every platform it claims to support (setters ignore
  their Value parameter, per-app volume functions loop zero times, wrong
  COM vtable for IAudioSessionManager2, Android/macOS/iOS code doesn't
  compile). `JD.VolumeControls` (v1) is the one to use. If the per-app
  volume idea matters one day, reimplement it properly in v1.
- `JD.ImageGrid.pas` — older duplicate of `JD.Ctrls.ImageGrid.pas`.
  The `JD.Ctrls` copy is the live one.
- `JD.PageMenu.pas` — older duplicate of `JD.Ctrls.PageMenu.pas`.
  The `JD.Ctrls` copy is the live one.
- `JD.Ctrls.WinControlHelper.pas` — design-time selection-editor
  experiment, orphaned (in no package, used by nothing).
- `JD.Graphics.DWScript.pas` / `.dfm` — DWScript data module, orphaned
  (in no package, used by nothing). The `dwsLibRuntime` package
  requirement was removed along with it.
- `JD.Sockets.pas` — empty stub classes only (TCP socket concept,
  never implemented).
- `JD.Ctrls.Toolbar.pas` — empty stub classes only (toolbar concept,
  never implemented).

Nothing here is deleted from history — git still has every version.
If you ever want one of these back, move it out of `_OLD/` and add it
to the package again.
