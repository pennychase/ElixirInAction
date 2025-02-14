defmodule CacheTest do
  use ExUnit.Case

  test "server_process" do
    bob_pid = Todo.Cache.server_process("Bob's list")

    assert bob_pid != Todo.Cache.server_process("Alice's list")
    assert bob_pid == Todo.Cache.server_process("Bob's list")
  end

  test "todo operations" do

    bob_pid = Todo.Cache.server_process("Bob's list")
    Todo.Server.add_entry(bob_pid, %{date: ~D[2025-01-31], title: "Dentist"})

    entries = Todo.Server.entries(bob_pid, ~D[2025-01-31])
    assert [%{date: ~D[2025-01-31], title: "Dentist"}] = entries

  end
  
end