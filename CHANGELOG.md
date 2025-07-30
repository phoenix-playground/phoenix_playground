# Changelog

## v0.1.8 (2025-07-30)

  * Use Phoenix LiveView v1.1.

## v0.1.7 (2024-09-24)

  * Delegate LiveView `handle_async/3`.

## v0.1.6 (2024-09-03)

  * Always use PhoenixPlayground.CodeReloader

  * Add blank favicon to layout

  * Add `:endpoint` option

## v0.1.5 (2024-08-14)

  * Fix live reloading.

  * Add `:debug_errors` option.

  * Document `PhoenixPlayground.Layout`.

  * Add `examples/demo_router.exs`.

## v0.1.4 (2024-07-18)

  * Delegate LiveView `handle_params/3`.

  * Add support for LiveView hooks.

  * Add support for LiveView uploaders.

  * Add support for `:page_title` assign.

  * Add `:endpoint_options` option

## v0.1.3 (2024-05-16)

  * Use state-preserving live reload. (Requires Phoenix LiveView 1.0.0-rc.1+.)

  * Display errors using `Plug.Debugger`.

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
