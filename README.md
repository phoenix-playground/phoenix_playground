# Phoenix Playground

[![CI](https://github.com/phoenix-playground/phoenix_playground/actions/workflows/ci.yml/badge.svg)](https://github.com/phoenix-playground/phoenix_playground/actions/workflows/ci.yml)

Phoenix Playground makes it easy to create single-file [Phoenix](https://www.phoenixframework.org) applications.

## Examples

[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https%3A%2F%2Fgithub.com%2Fphoenix-playground%2Fphoenix_playground%2Fblob%2Fmain%2Fexamples%2Fdemo_live.livemd)

Create a `demo_live.exs` file:

```elixir
Mix.install([
  {:phoenix_playground, "~> 0.1.0"}
])

defmodule DemoLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0)}
  end

  def render(assigns) do
    ~H"""
    <span><%= @count %></span>
    <button phx-click="inc">+</button>
    <button phx-click="dec">-</button>

    <style type="text/css">
      body { padding: 1em; }
    </style>
    """
  end

  def handle_event("inc", _params, socket) do
    {:noreply, assign(socket, count: socket.assigns.count + 1)}
  end

  def handle_event("dec", _params, socket) do
    {:noreply, assign(socket, count: socket.assigns.count - 1)}
  end
end

PhoenixPlayground.start(live: DemoLive)
```

and run it:

```
$ iex demo_live.exs
```

<img width="1195" alt="image" src="demo.png">


See more examples below:

  * [`examples/demo_live.exs`]
  * [`examples/demo_live_test.exs`]
  * [`examples/demo_controller.exs`]
  * [`examples/demo_controller_test.exs`]
  * [`examples/demo_plug.exs`]
  * [`examples/demo_hooks.exs`]

## License

Copyright (c) 2024 Wojtek Mach

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

[`examples/demo_live.exs`]: examples/demo_live.exs
[`examples/demo_live_test.exs`]: examples/demo_live_test.exs
[`examples/demo_controller.exs`]: examples/demo_controller.exs
[`examples/demo_controller_test.exs`]: examples/demo_controller_test.exs
[`examples/demo_plug.exs`]: examples/demo_plug.exs
[`examples/demo_hooks.exs`]: examples/demo_hooks.exs
