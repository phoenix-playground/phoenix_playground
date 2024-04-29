defmodule PhoenixPlayground.Reloader do
  @moduledoc false

  use GenServer

  def start_link(path) when is_binary(path) do
    GenServer.start_link(__MODULE__, path)
  end

  @impl true
  def init(path) do
    :ok = Phoenix.PubSub.subscribe(PhoenixPlayground.PubSub, "phoenix_playground")
    :ok = FileSystem.subscribe(:phoenix_live_reload_file_monitor)
    {:ok, path}
  end

  @impl true
  def handle_info({:phoenix_live_reload, "phoenix_playground", path}, state) do
    recompile(path)
    {:noreply, state}
  end

  @impl true
  def handle_info({:file_event, _pid, {path, options}}, path) do
    if :created in options or :modified in options do
      recompile(path)
      debounce()
    end

    {:noreply, path}
  end

  @impl true
  def handle_info({:file_event, _pid, _path}, path) do
    {:noreply, path}
  end

  defp recompile(path) do
    old = Code.get_compiler_option(:ignore_module_conflict) == true
    Code.put_compiler_option(:ignore_module_conflict, true)
    result = Code.eval_file(path)
    Code.put_compiler_option(:ignore_module_conflict, old)
    result
  end

  defp debounce do
    Process.send_after(self(), :debounced, 100)
    do_debounce()
  end

  defp do_debounce do
    receive do
      :debounced ->
        :ok

      {:file_event, _, _} ->
        do_debounce()
    end
  end
end
