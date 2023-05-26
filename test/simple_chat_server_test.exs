defmodule SimpleChatServerTest do
  use ExUnit.Case
  doctest SimpleChatServer

  test "greets the world" do
    assert SimpleChatServer.hello() == :world
  end
end
