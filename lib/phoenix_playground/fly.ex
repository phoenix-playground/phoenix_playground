defmodule PhoenixPlayground.Fly do
  @moduledoc false

  def deploy(file, _app) do
    suffix = file |> :erlang.md5() |> Base.encode32(case: :lower, padding: false)
    id = Path.basename(file, ".exs") <> "_" <> suffix
    dir = "/tmp/phoenix_playground_fly_apps/#{id}"
    File.mkdir_p!(dir)

    File.cd!(dir, fn ->
      # File.write!("fly.toml", """
      # app = '#{app}'
      # primary_region = 'waw'

      # [build]

      # [deploy]
      #   strategy = 'immediate'

      # [env]
      #   PORT = 8080
      #   PROD = true

      # [http_service]
      #   internal_port = 8080
      #   force_https = true
      #   auto_stop_machines = true
      #   auto_start_machines = true
      #   min_machines_running = 0
      #   processes = ['app']

      # [[vm]]
      #   size = 'shared-cpu-1x'
      # """)

      File.write!(
        "Dockerfile",
        """
        ARG ELIXIR_VERSION=1.17.2
        ARG OTP_VERSION=27.0.1
        ARG DEBIAN_VERSION=bookworm-20240701-slim

        ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"

        FROM ${BUILDER_IMAGE}

        # install build dependencies
        RUN apt-get update -y && apt-get install -y build-essential git \
            && apt-get clean && rm -f /var/lib/apt/lists/*_*

        # prepare build dir
        WORKDIR /app

        # install hex + rebar
        RUN mix local.hex --force && mix local.rebar --force

        # set build ENV
        ENV MIX_ENV="prod"
        ENV MIX_INSTALL_DIR="/app/.mix"
        ENV ERL_AFLAGS "-proto_dist inet6_tcp"

        COPY run.exs /app/run.exs
        CMD ["elixir", "/app/run.exs", "--no-open-browser", "--no-live-reload", "--port", "8080", "--host", "$FLY_APP_NAME.fly.dev"]
        """
      )

      File.copy!(file, "run.exs")

      # {_, 0} = System.shell("fly launch", into: IO.stream(), stderr_to_stdout: true)

      fly_cli = System.find_executable("fly") || raise "run: brew install flyctl"
      {:ok, _} = PhoenixPlayground.Fly.Port.start_link(fly_cli)

      receive do
        :done ->
          :ok
      end
    end)
  end
end

defmodule PhoenixPlayground.Fly.Port do
  use GenServer

  def start_link(fly_cli) do
    GenServer.start_link(__MODULE__, %{fly_cli: fly_cli, caller: self()})
  end

  @impl true
  def init(%{fly_cli: fly_cli, caller: caller}) do
    port =
      Port.open(
        {:spawn_executable, fly_cli},
        [
          :binary,
          :stderr_to_stdout,
          :exit_status,
          line: 2048,
          args: ~w[deploy]
        ]
      )

    {:ok, %{port: port, caller: caller}}
  end

  @impl true
  def handle_info({port, {:data, {:eol, line}}}, %{port: port} = state) do
    IO.puts(line)
    {:noreply, state}
  end

  def handle_info({port, {:exit_status, _}}, %{port: port, caller: caller} = state) do
    send(caller, :done)
    {:stop, :normal, state}
  end
end
