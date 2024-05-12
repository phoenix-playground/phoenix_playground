defmodule PhoenixPlayground.CodeReloader do
  @moduledoc false

  def reload(_endpoint, _options \\ []) do
    if path = Application.get_env(:phoenix_playground, :file) do
      old = Code.get_compiler_option(:ignore_module_conflict) == true
      Code.put_compiler_option(:ignore_module_conflict, true)
      Code.eval_file(path)
      Code.put_compiler_option(:ignore_module_conflict, old)
      :ok
    else
      # in Livebook, path is nil
      :ok
    end
  end
end
