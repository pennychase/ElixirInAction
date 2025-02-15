defmodule Todo.Metrics do
  use Task

  def start_link(_arg), do: Task.start_link(&loop/0)

  def loop() do
    Process.sleep(Application.fetch_env!(:todo, :todo_metrics_interval))
    IO.inspect(collect_metrics())
    loop()
  end
  
  defp collect_metrics() do
    [
      memory_usage: :erlang.memory(:total),
      process_count: :erlang.system_info(:process_count)
    ]
  end
end