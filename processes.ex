# Copy definitions into IEx
# Either run the lambdas, or copy the Enum.map and Enum.each calls

# Simulate long database queries (each takes 2 seconds)

# iex> run_query.("Query 1")
# Returns "Query 1 result" in 2 seconds
run_query = 
  fn query_def -> 
    Process.sleep(2000)
    "#{query_def} result"
  end

# returns ["Query 1 result", "Query 2 result", "Query 3 result", "Query 4 result",
# "Query 5 result"] in 10 seconds
Enum.map(
    1 .. 5,
    fn n ->
      query_def = "Query #{n}"
      run_query.(query_def)
    end
  )

# Spawn one process
# Returns PID immediatley, waits 2 seconds to print "Query 1 result"
spawn(fn ->
  query_result = run_query.("Query 1")
  IO.puts(query_result)
end
)

# Concurrent processes
# Run once: 
#   iex> async_query.("Query 1")
# Returns PID immediately and prints "Query 1 result" in 2 seconds
async_query =
  fn query_def ->
    spawn(fn -> async_query.("Query 1") 
      query_result = run_query.(query_def)
      IO.puts(query_result)
    end)
  end

# Run 5 asynchronous queries: prints the 5 results in 2 seconds
Enum.each(1 .. 5, &async_query.("Query #{&1}"))



# Collect query results using message passing

# send query
async_query =
  fn query_def ->

    caller = self()

    spawn(fn -> 
      query_result = run_query.(query_def)
      send(caller,{:query_result, query_result})
    end)
  end

# receive result
get_result =
  fn ->
    receive do
      {:query_result, result} -> result
    end
  end

# Parallel map to send multiple queries and collect results in a list, using a pipeline

1..5
|> Enum.map(&async_query.("query #{&1}"))
|> Enum.map(fn _ -> get_result.() end)

