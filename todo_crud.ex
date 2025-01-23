defmodule TodoList do

# TodoList Struct and functions

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

  def update_entry(todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error -> todo_list
      {:ok, old_entry} ->
        new_entry = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def update_entry_field(todo_list, entry_id, field, new_value) do
    new_entries = put_in(todo_list.entries, [entry_id, field], new_value)
    %TodoList{todo_list | entries: new_entries}
  end

  def delete_entry(todo_list, entry_id) do
    new_entries = Map.delete(todo_list.entries, entry_id)
    %TodoList{todo_list | entries: new_entries}
  end
end


# Import TodoList from CSV file

defmodule TodoList.CsvImporter do

  def import(filepath) do  
    File.stream!(filepath)
    |> Stream.map(&String.trim_trailing(&1, "\n"))
    |> Stream.map(&String.split(&1,","))
    |> Stream.map(&list_to_entry/1)
    |> TodoList.new   
  end

  defp list_to_entry([date,title]) do
    %{date: Date.from_iso8601!(date), title: title}
  end
end

# Implement protocols

defimpl String.Chars, for: TodoList do
  def to_string(_) do
    "#TodoList%{ next_id:, entries: }"
  end
end

defimpl Collectable, for: TodoList do
  def into(original) do
    {original, &into_callback/2}
  end

  defp into_callback(todo_list, {:cont, entry}) do
    TodoList.add_entry(todo_list, entry)
  end

  defp into_callback(todo_list, :done), do: todo_list

  defp into_callback(_todo_list, :halt), do: :ok
end


# todo_list = TodoList.new() |> 
#   TodoList.add_entry(%{date: ~D[2025-01-21], title: "Tai Chi"}) |> 
#   TodoList.add_entry(%{date: ~D[2025-01-21], title: "Concert"}) |>
#   TodoList.add_entry(%{date: ~D[2025-01-25], title: "Museum"})

# todo_list = TodoList.update_entry(todo_list, 3, &Map.put(&1, :date, ~D[2025-01-30])) 

# IO.puts totdo_list

# entries = [ %{date: ~D[2025-01-21], title: "Tai Chi"}, %{date: ~D[2025-01-21], title: "Concert"}]
# Enum.into(entries, TodoList.new