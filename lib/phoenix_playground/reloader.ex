defmodule PhoenixPlayground.Reloader do
  # @moduledoc false

  # use GenServer

  # def start_link(path) when is_binary(path) do
  #   GenServer.start_link(__MODULE__, path)
  # end

  # @impl true
  # def init(path) do
  #   :ok = Phoenix.PubSub.subscribe(PhoenixPlayground.PubSub, "phoenix_playground")
  #   :ok = FileSystem.subscribe(:phoenix_live_reload_file_monitor)
  #   {:ok, %{path: path, locked: false}}
  # end

  # @impl true
  # def handle_info(:unlock, state) do
  #   {:noreply, %{state | locked: false}}
  # end

  # @impl true
  # def handle_info({:phoenix_live_reload, _, _}, %{locked: true} = state) do
  #   {:noreply, state}
  # end

  # @impl true
  # def handle_info({:phoenix_live_reload, "phoenix_playground", _}, state) do
  #   recompile(state.path)
  #   {:noreply, %{state | locked: true}}
  # end

  # @impl true
  # def handle_info({:file_event, _, _}, %{locked: true} = state) do
  #   {:noreply, state}
  # end

  # @impl true
  # def handle_info({:file_event, _pid, {path, options}}, %{path: path} = state) do
  #   if :created in options or :modified in options do
  #     recompile(path)
  #     {:noreply, %{state | locked: true}}
  #   else
  #     {:noreply, state}
  #   end
  # end

  # @impl true
  # def handle_info({:file_event, _pid, _path}, state) do
  #   {:noreply, state}
  # end

  # defp recompile(path) do
  #   Process.send_after(self(), :unlock, 100)

  #   old = Code.get_compiler_option(:ignore_module_conflict) == true
  #   Code.put_compiler_option(:ignore_module_conflict, true)
  #   result = Code.eval_file(path)
  #   Code.put_compiler_option(:ignore_module_conflict, old)
  #   result
  # end
end
