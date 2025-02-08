defmodule Todo.Server do
  use GenServer

  # Client API
  def start_link(name) do
    GenServer.start_link(__MODULE__, name)
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

  # Callbacks
  def init(name) do
    IO.puts("Starting todo server: #{name}")
    {:ok, {name, nil}, {:continue, :init} }
  end

  def handle_continue(:init, {name, nil}) do
    todo_list = Todo.Database.get(name) || Todo.List.new()
    {:noreply, {name, todo_list}}
  end

  def handle_call({:entries, date}, _, {name, todo_list}) do
    {:reply, Todo.List.entries(todo_list, date), {name, todo_list}}
  end

  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  def handle_cast({:delete_entry, entry_id}, {name, todo_list}) do
    new_list = Todo.List.delete_entry(todo_list, entry_id)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  def handle_cast({:update_entry, entry_id, field_name, new_value}, {name, todo_list}) do
    new_list = Todo.List.update_entry(todo_list, entry_id, field_name, new_value)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

end