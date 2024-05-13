defmodule PhoenixPlayground.CodeReloader do
  @moduledoc false

  def reload(_endpoint, _options \\ []) do
    if path = Application.get_env(:phoenix_playground, :file) do
      case File.read(path) do
        {:ok, contents} ->
          old = Code.get_compiler_option(:ignore_module_conflict) == true
          Code.put_compiler_option(:ignore_module_conflict, true)
          Code.eval_string(contents)
          Code.put_compiler_option(:ignore_module_conflict, old)

        # ignore fs errors. (Seems like saving file in vim sometimes make it temp dissapear?)
        {:error, reason} ->
          :ok
      end
    else
      # in Livebook, path is nil
      :ok
    end
  end
end
