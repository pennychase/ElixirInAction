defmodule Todo.Server do
  use GenServer, restart: :temporary

  # Client API
  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: global_name(name))
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def delete_entry(todo_server, entry_id) do
    GenServer.cast(todo_server, {:delete_entry, entry_id})
  end

  def update_entry(todo_server, entry_id, field_name, new_value) do
    GenServer.cast(todo_server, {:update_entry, entry_id, field_name, new_value})
  end

  # Utilities
  defp global_name(name) do
    {:global, {__MODULE__, name}}
  end

  def whereis(name) do
    case :global.whereis_name({__MODULE__, name}) do
      :undefined -> nil
      pid -> pid
    end
  end

  # Callbacks
  def init(name) do
    IO.puts("Starting todo server: #{name}")
    {:ok, {name, nil}, {:continue, :init} }
  end

  def handle_continue(:init, {name, nil}) do
    todo_list = Todo.Database.get(name) || Todo.List.new()
    {:noreply, {name, todo_list}, expiry_idle_timeout()}
  end

  def handle_info(:timeout, {name, todo_list}) do
    IO.puts("Stopping todo server: #{name}")
    {:stop, :normal, {name, todo_list}}  
  end

  def handle_call({:entries, date}, _, {name, todo_list}) do
    {:reply, Todo.List.entries(todo_list, date), {name, todo_list}, expiry_idle_timeout()}
  end

  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}, expiry_idle_timeout()}
  end

  def handle_cast({:delete_entry, entry_id}, {name, todo_list}) do
    new_list = Todo.List.delete_entry(todo_list, entry_id)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}, expiry_idle_timeout()}
  end

  def handle_cast({:update_entry, entry_id, field_name, new_value}, {name, todo_list}) do
    new_list = Todo.List.update_entry(todo_list, entry_id, field_name, new_value)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}, expiry_idle_timeout()}
  end

  defp expiry_idle_timeout(), do: Application.fetch_env!(:todo, :todo_server_expiry)

end