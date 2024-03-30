defmodule Examples do
  def run(path) do
    {:ok, quoted} =
      path
      |> File.read!()
      |> Code.string_to_quoted()

    quoted
    |> remove_mix_install()
    |> Code.eval_quoted([], file: path)
  end

  defp remove_mix_install(quoted) do
    Macro.prewalk(quoted, fn
      {{:., _, [{:__aliases__, _, [:Mix]}, :install]}, _, _} ->
        nil

      ast ->
        ast
    end)
  end
end

Examples.run("#{__DIR__}/../examples/demo_controller_test.exs")
Examples.run("#{__DIR__}/../examples/demo_live_test.exs")
