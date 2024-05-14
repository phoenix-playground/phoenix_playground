# Changelog

## HEAD

  * Use state-preserving live reload.

  * Initial support for displaying errors via Plug.Debugger (`debug_errors: true`).

## v0.1.2 (2024-04-29)

  * Deprecate setting `:router` in favour of `:plug`.

## v0.1.1 (2024-04-23)

  * Use local javascript assets.

  * Update secret key base.

  * Replace `PhoenixPlayground.start_link/1` with `start/1`.

  * Fix opening up component definition/caller: set `:debug_heex_annotations` on application boot.

  * Add `:child_specs` option to specify additional processes to run in the supervision tree.

  * Prevent VM from halting when playground is started.

## v0.1.0 (2024-04-18)

  * Initial release.
