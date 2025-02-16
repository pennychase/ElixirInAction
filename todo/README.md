# Todo

The Todo Project is in a single repository, rather than creating multiple repos for the different versions in the book.

There are three branches:

- **main:** the main branch with all the major changes
- **agent-todo-server:** the excusion om chapter 10 to swap out GenServer for Agent
- **local-registry:** OTP Application with configuration, metrics, server timeout, and web server(through Chapter 11)

There are also tags representing major versions, so one could checkout the tag as a branch to easily review that version:

- **GenServer:** initial GenServer implementation (Chapter 6)
- **Cache:** initial Cache to maintain state for handling multiple todo lists (Chapter 7)
- **Pool:** initial home grown database worker pool (Chapter 7)
- **SupervisedTodoServer:** fully linked supervisor (Chapter 8)
- **SupervisionTree:** supervision tree of database workers and dynamic supervision of Todo.Server
- **TodoApplication:** OTP Application (Chapter 11)

