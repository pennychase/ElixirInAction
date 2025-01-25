defmodule DatabaseServer do

  # Client API

  def start do
    spawn(fn ->
      connection = :random.uniform(1000)      # Sinulates connection that server maintains in its state
      loop(connection)
    end
  )
  end
  
  def run_async(server_pid, query_def) do
    send(server_pid, {:run_query, self(), query_def})
  end

  def get_result do
    receive do
      {:query_result, result} -> result
    after
      5000 -> {:error, :timeout}
    end
  end

  # Server Implementation

  defp loop(connection) do
    receive do
      {:run_query, from_pid, query_def} ->
        query_result = run_query(connection, query_def)
        send(from_pid, {:query_result, query_result})
    end

    loop(connection)
  end

  defp run_query(connection, query_def) do
    Process.sleep(2000)
    "Connection #{connection}: #{query_def} result"
  end

end

# # Server Pool

# # Store pool of servers in a map
# pool = for n <- 1 .. 100, into: %{}, do: {n, DatabaseServer.start}

# # Randomly select 5 servers and send message
# Enum.each(
#   1..5,
#   fn query_def ->
#     server_pid = Map.fetch!(pool, :rand.uniform(100) -1)
#     DatabaseServer.run_async(server_pid, query_def)
# end
# )

# # Receive the 5 messages
# Enum.map(1..5, fn _ -> DatabaseServer.get_result() end) 