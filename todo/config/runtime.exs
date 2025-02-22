import Config

http_port = 
  if config_env() != :test,
    do: System.get_env("TODO_HTTP_PORT", "5454"),
    else: System.get_env("TODO_TEST_HTTP_PORT", "5455")

config :todo, http_port: String.to_integer(http_port)

db_folder =
  if config_env() != :test,
    do: System.get_env("TODO_DB_FOLDER", "./persist"),
    else: System.get_env("TODO_TEST_DB_FOLDER", "./test_persist")

config :todo, :database, db_folder: db_folder

# Shorter server timeout in local dev
todo_server_expiry =
  if config_env() != :dev,
    do: System.get_env("TODO_SERVER_EXPIRY", "6000"),
    else: System.get_env("TODO_SERVER_EXPIRY", "1000")

config :todo, todo_server_expiry: :timer.seconds(String.to_integer(todo_server_expiry))

# Measure metrics more frequently in local dev
todo_metrics_interval = 
  if config_env() != :dev,
    do: System.get_env("TODO_METRICS_INTERVAL", "60"),
    else: System.get_env("TODO_METRICS_INTERVAL", "10")

config :todo, todo_metrics_interval: :timer.seconds(String.to_integer(todo_metrics_interval))