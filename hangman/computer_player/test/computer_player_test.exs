defmodule ComputerPlayerTest do
  use ExUnit.Case
  doctest ComputerPlayer

  test "greets the world" do
    assert ComputerPlayer.hello() == :world
  end
end
