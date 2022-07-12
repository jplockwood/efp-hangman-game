defmodule ComputerPlayer do
  @spec play_game() :: :ok
  defdelegate play_game(), to: ComputerPlayer.Game
end
