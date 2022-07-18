defmodule TextClient.Impl.PlayerTest do
  use ExUnit.Case

  alias TextClient.Impl.Player

  describe "interact/1" do
    test "won" do
      assert Player.interact({%{}, %{game_state: :won}}) == {:ok, :won}
    end

    test "lost" do
      assert Player.interact({%{letters: ["a", "b", "c"]}, %{game_state: :lost}}) == {:ok, :lost}
    end
  end
end
