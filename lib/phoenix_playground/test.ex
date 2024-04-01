defmodule PhoenixPlayground.Test do
  # TODO
  # @moduledoc """
  # """

  defmacro __using__([{type, module}]) do
    module = Macro.expand(module, __ENV__)

    imports =
      if type == :live do
        quote do
          import(Phoenix.LiveViewTest)
        end
      end

    quote do
      import Phoenix.ConnTest
      module = unquote(module)
      type = unquote(type)
      unquote(imports)

      @endpoint PhoenixPlayground.Endpoint
      @options [type: type, module: module]

      setup do
        start_supervised!({@endpoint, @options})
        :ok
      end
    end
  end
end
