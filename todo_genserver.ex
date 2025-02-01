# CRUD TodoList Server implemented with GenServer

defmodule TodoListServer do
  use GenServer

  # Client API
  def start() do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def entries(date) do
    GenServer.call(__MODULE__, {:entries, date})
  end

  def add_entry(new_entry) do
    GenServer.cast(__MODULE__, {:add_entry, new_entry})
  end

  def delete_entry(entry_id) do
    GenServer.cast(__MODULE__, {:delete_entry, entry_id})
  end

  def update_entry(entry_id, field_name, new_value) do
    GenServer.cast(__MODULE__, {:update_entry, entry_id, field_name, new_value})
  end

  # Callbacks
  def init(_) do
    {:ok, TodoList.new()}
  end

  def handle_call({:entries, date}, _, state) do
    {:reply, TodoList.entries(state, date), state}
  end

  def handle_cast({:add_entry, new_entry}, state) do
    {:noreply, TodoList.add_entry(state, new_entry)}
  end

  def handle_cast({:delete_entry, entry_id}, state) do
    {:noreply, TodoList.delete_entry(state, entry_id)}
  end

  def handle_cast({:update_entry, entry_id, field_name, new_value}, state) do
    {:noreply, TodoList.update_entry(state, entry_id, field_name, new_value)}
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

