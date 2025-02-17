# Assume there's a single command line argument of the form node@hostname -> convert to an atom
# Invoke: elixir --sname terminator@localhost stop_node.exs todo_system@localhost

node = :"#{hd(System.argv())}"

if Node.connect(node) == true do
  :rpc.call(node, System, :stop, [])
  IO.puts("Node #{node} terminated")
else
  IO.puts("Can't connect to remote node #{node}")
end