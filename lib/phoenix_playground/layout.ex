defmodule PhoenixPlayground.Layout do
  @moduledoc """
  Built-in layout.

  This is the layout used by `PhoenixPlayground.start/1` with option `:live` or `:controller`

  To customize page title, set `:page_title` assign.

  You can customize LiveSocket hooks and uploaders by changing `window.hooks` and `window.uploaders`.
  """

  use Phoenix.Component

  @doc false
  def render(template, assigns)

  def render("root.html", assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en" class="h-full">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <.live_title>
          <%= assigns[:page_title] || "Phoenix Playground" %>
        </.live_title>
        <link rel="icon" href="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/wcAAgAB/ajN8ioAAAAASUVORK5CYII=">
      </head>
      <body>
        <script src="/assets/phoenix/phoenix.js"></script>
        <script src="/assets/phoenix_live_view/phoenix_live_view.js"></script>
        <script>
          // Set global hooks and uploaders objects to be used by the LiveSocket,
          // so they can be overwritten in user provided templates.
          window.hooks = {}
          window.uploaders = {}

          let liveSocket =
            new window.LiveView.LiveSocket(
              "/live",
              window.Phoenix.Socket,
              { hooks, uploaders }
            )
          liveSocket.connect()

          window.addEventListener("phx:live_reload:attached", ({detail: reloader}) => {
            // Enable server log streaming to client. Disable with reloader.disableServerLogs()
            reloader.enableServerLogs()

            // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
            //
            //   * click with "c" key pressed to open at caller location
            //   * click with "d" key pressed to open at function component definition location
            let keyDown
            window.addEventListener("keydown", e => keyDown = e.key)
            window.addEventListener("keyup", e => keyDown = null)
            window.addEventListener("click", e => {
              if(keyDown === "c"){
                e.preventDefault()
                e.stopImmediatePropagation()
                reloader.openEditorAtCaller(e.target)
              } else if(keyDown === "d"){
                e.preventDefault()
                e.stopImmediatePropagation()
                reloader.openEditorAtDef(e.target)
              }
            }, true)

            window.liveReloader = reloader
          })
        </script>

        <%= @inner_content %>
      </body>
    </html>
    """
  end
end
