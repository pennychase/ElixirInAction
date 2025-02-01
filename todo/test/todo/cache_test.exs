defmodule CacheTest do
  use ExUnit.Case

  test "server_process" do
    {:ok, cache} = Todo.Cache.start()
    bob_pid = Todo.Cache.server_process(cache, "Bob's list")

    assert bob_pid != Todo.Cache.server_process(cache, "Alice's list")
    assert bob_pid == Todo.Cache.server_process(cache, "Bob's list")
  end

  test "todo operations" do
    {:ok, cache} = Todo.Cache.start()

    bob_pid = Todo.Cache.server_process(cache, "Bob's list")
    Todo.Server.add_entry(bob_pid, %{date: ~D[2025-01-31], title: "Dentist"})

    entries = Todo.Server.entries(bob_pid, ~D[2025-01-31])
    assert [%{date: ~D[2025-01-31], title: "Dentist"}] = entries

  end
  
end