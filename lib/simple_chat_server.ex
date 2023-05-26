defmodule SimpleChatServer do
  use Agent

  def start()do
    Agent.start_link(fn -> %{users: [], messages: []} end, name: __MODULE__)
    name = IO.gets("Enter your name to connect: ")
    |> String.trim()
    |> String.trim_trailing("\n")
    |> connect()
    |> user_action()
  end

  def connect(name) do
   valid_name = is_binary(name)

   result = cond do
    valid_name == true and String.trim(name) != "" -> add_user(name)
    valid_name == false ->IO.puts "Please enter a valid name"
    true -> IO.puts "You did not enter a valid name"
   end
  end

  defp add_user(name) do
    Agent.update(__MODULE__, fn state ->
       %{state | users: [name | state.users]}
    end)
    IO.puts("You are connected!")
    name
  end

  #Command-line interface
  def user_action(name)do
    IO.puts "Enter exit if you want to disconnect"
    IO.puts "Enter write if you want to send message to all the users"

    action = IO.gets("")|>String.trim() |> String.trim_trailing("\n")
    case action do
      "exit" -> disconnect(name)
      "write" ->
        message = IO.gets("Write a message ") |>String.trim() |> String.trim_trailing("\n")
        broadcast(message)
      _ -> IO.puts "You did not enter a valid command"
    end
 end

  #All the connected users
  def get_users()do
    Agent.get(__MODULE__, fn state -> state.users end)
  end

  #Message sending functions
  def broadcast(msg)do
    valid_msg = is_binary(msg)

    cond do
      valid_msg == true and String.trim(msg) != "" -> send_message(msg)
      valid_msg == false ->IO.puts "Please enter a valid message"
      true -> IO.puts "You did not enter a valid message"
    end
  end

  defp send_message(msg)do
    Agent.update(__MODULE__, fn state -> %{state | messages: [msg | state.messages]}end)
    send_to_all_users(msg)
  end

  defp send_to_all_users(msg)do
    Task.async_stream(get_users(), fn user -> IO.puts("Message: #{msg} sent to #{user}")end)
    |>Stream.run()
  end

  #Disconnecting the user
  def disconnect(user_name)do
    Agent.update(__MODULE__, fn state -> %{state | users: List.delete(state.users, user_name)}end)
    IO.puts("Goodbye!")
  end

end

SimpleChatServer.start()
