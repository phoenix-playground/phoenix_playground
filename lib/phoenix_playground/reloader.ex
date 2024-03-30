defmodule PhoenixPlayground.Reloader do
  @moduledoc false

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl true
  def init(_) do
    :ok = Phoenix.PubSub.subscribe(PhoenixPlayground.PubSub, "phoenix_playground")
    {:ok, nil}
  end

  @impl true
  def handle_info({:phoenix_live_reload, "phoenix_playground", path}, state) do
    recompile(path)
    {:noreply, state}
  end

  defp recompile(path) do
    {:ok, quoted} =
      path
      |> File.read!()
      |> Code.string_to_quoted()

    Macro.prewalk(quoted, fn
      {:defmodule, _, [mod, _]} = ast ->
        mod =
          case mod do
            {:__aliases__, _, parts} -> Module.concat(parts)
            mod when is_atom(mod) -> mod
          end

        :code.purge(mod)
        :code.delete(mod)
        Code.eval_quoted(ast, [], file: path)
        :ok

      ast ->
        ast
    end)
  end
end
