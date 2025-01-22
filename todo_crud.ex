defmodule TodoList do
alias ElixirLS.LanguageServer.Providers.FoldingRange.Token

  defstruct next_id: 1, entries: %{}

  def new, do: %TodoList{}

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

# todo_list = TodoList.new() |> 
#   TodoList.add_entry(%{date: ~D[2025-01-21], title: "Tai Chi"}) |> 
#   TodoList.add_entry(%{date: ~D[2025-01-21], title: "Concert"}) |>
#   TodoList.add_entry(%{date: ~D[2025-01-25], title: "Museum"})

# todo_list = TodoList.update_entry(todo_list, 3, &Map.put(&1, :date, ~D[2025-01-30])) 