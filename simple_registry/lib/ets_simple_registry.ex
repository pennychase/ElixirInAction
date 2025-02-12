defmodule EtsSimpleRegistry do

  use GenServer

  # Client API

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def register(process_key) do
    Process.link(Process.whereis(__MODULE__))

    if :ets.insert_new(__MODULE__, {process_key, self()}) do
      :ok
    else
      :error
    end
  end

  def whereis(process_key) do
    case :ets.lookup(__MODULE__, process_key) do
      [{^process_key, pid}] -> pid
      [] -> nil
    end
  end

  # Callbacks

  @impl GenServer
  def init(_) do
    Process.flag(:trap_exit, true)
    :ets.new(__MODULE__, [:named_table, :public, write_concurrency: true, read_concurrency: true])
    {:ok, nil}
  end

  @impl GenServer
  def handle_info({:EXIT, pid, _reason}, registry) do
    :ets.match_delete(__MODULE__, {:_, pid})
    {:noreply, registry}
  end

end