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
    old = Code.get_compiler_option(:ignore_module_conflict) == true
    Code.put_compiler_option(:ignore_module_conflict, true)
    result = Code.eval_file(path)
    Code.put_compiler_option(:ignore_module_conflict, old)
    result
  end
end
