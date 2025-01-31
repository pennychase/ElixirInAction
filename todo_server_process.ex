# CRUD TodoList Server implemented with a generic server process

# Generic Server Process
defmodule ServerProcess do

  # Public functions for server
  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init()
      loop(callback_module, initial_state)
    end)
  end
  
  def call(server_pid, request) do
    send(server_pid, {:call, request, self()})

    receive do
      {:response, response} -> response
    end
  end

  def cast(server_pid, request) do
    send(server_pid, {:cast, request})
  end

  # Server Implementation
  defp loop(callback_module, current_state) do
    new_state = receive do

      {:call, request, caller} ->
        {response, new_state} =
          callback_module.handle_call(request, current_state)
        send(caller, {:response, response})
        new_state

      {:cast, request} ->
        callback_module.handle_cast(request, current_state)     
    end

    loop(callback_module, new_state)
  end

end

# Callback Module for TodoServer
defmodule TodoServer do

  # Callback Implementation
  def init do
    TodoList.new()
  end

  def handle_call({:entries, date}, state) do
    {TodoList.entries(state, date), state}
  end
  
  def handle_cast({:add_entry, new_entry}, state) do
    TodoList.add_entry(state, new_entry)
  end

  def handle_cast({:delete_entry, entry_id}, state) do
    TodoList.delete_entry(state, entry_id)
  end

  def handle_cast({:update_entry, entry_id, field_name, new_value}, state) do
    TodoList.update_entry(state, entry_id, field_name, new_value)
  end

  # Callback API
  def start do
    ServerProcess.start(TodoServer)
  end

  def entries(pid, date) do
    ServerProcess.call(pid, {:entries, date})
  end

  def add_entry(pid, new_entry) do
    ServerProcess.cast(pid, {:add_entry, new_entry})
  end

  def delete_entry(pid, entry_id) do
    ServerProcess.cast(pid, {:delete_entry, entry_id})
  end

  def update_entry(pid, entry_id, field_name, new_value) do
    ServerProcess.cast(pid, {:update_entry, entry_id, field_name, new_value})
  end

end

# TodoList Implementation (Struct and Functions)
defmodule TodoList do

  defstruct next_id: 1, entries: %{}

  def new(entries\\[]) do
    Enum.reduce(entries,%TodoList{},&add_entry(&2,&1))
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.next_id)

    new_entries = Map.put(
      todo_list.entries,
      todo_list.next_id,
      entry
    )

    %TodoList{ todo_list | 
      entries: new_entries,
      next_id: todo_list.next_id + 1
      }
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Map.values()
    |> Enum.filter(fn entry -> entry.date == date end)  
  end

  def update_entry(todo_list, entry_id, field, new_value) do
    new_entries = put_in(todo_list.entries, [entry_id, field], new_value)
    %TodoList{todo_list | entries: new_entries}
  end

  def delete_entry(todo_list, entry_id) do
    new_entries = Map.delete(todo_list.entries, entry_id)
    %TodoList{todo_list | entries: new_entries}
  end
end

