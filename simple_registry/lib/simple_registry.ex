defmodule SimpleRegistry do
  use GenServer

  # Client API

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def register(process_key) do
    GenServer.call(__MODULE__, {:register, process_key, self()})
  end

  def whereis(process_key) do
    GenServer.call(__MODULE__, {:whereis, process_key})
  end

  # Callbacks

  @impl GenServer
  def init(_) do
    Process.flag(:trap_exit, true)
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:register, process_key, pid}, _, registry) do
    case Map.get(registry, process_key) do
      nil ->  {:reply, :ok, Map.put(registry, process_key, pid)}
      _ -> {:reply, :error, registry}
    end
   
  end

  @impl GenServer
  def handle_call({:whereis, process_key}, _, registry) do
    {:reply, Map.get(registry, process_key), registry}
  end

  @impl GenServer
  def handle_info({:EXIT, pid, _reason}, registry) do
    IO.puts("trap #{pid}")
    {:noreply, deregister_pid(registry, pid)}
  end

  defp deregister_pid(registry, pid) do
    registry
    |> Map.reject(fn {_key, registered_process} -> registered_process == pid end)
  end
end
