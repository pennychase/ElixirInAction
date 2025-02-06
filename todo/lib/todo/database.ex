defmodule Todo.Database do

  use GenServer

  @db_folder "./persist"

  # Client API

  def start() do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  defp choose_worker(key) do
    GenServer.call(__MODULE__, {:choose_worker, key})
  end

  # Callbacks

  @impl GenServer
  def init(_) do
    IO.puts("Starting database server")
    File.mkdir_p!(@db_folder)
    {:ok, start_workers(@db_folder)}
  end

  @impl GenServer
  def handle_call({:choose_worker, key}, _, workers) do
    worker_id = :erlang.phash2(key, 3)
    {:reply, Map.get(workers, worker_id), workers}
  end

  defp start_workers(db_folder) do
    for i <- 0..2, into: %{} do
      {:ok, worker_pid} = Todo.DatabaseWorker.start(db_folder)
      {i, worker_pid}
    end
  end
  
end