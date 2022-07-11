defmodule Hangman.Impl.GameTest do
  use ExUnit.Case

  alias Hangman.Impl.Game

  describe "new_game/0" do
    test "returns expected structure" do
      game = Game.new_game()

      assert game.turns_left == 7
      assert game.game_state == :initializing
      assert length(game.letters) > 0
    end

    test "new game return correct word" do
      game = Game.new_game("wombat")

      assert game.letters == ["w", "o", "m", "b", "a", "t"]
    end

    test "should ensure that all letters are read in as lower case" do
      game = Game.new_game("WombAt")

      for letter <- game.letters do
        assert letter == String.downcase(letter)
      end

      assert game.letters == ["w", "o", "m", "b", "a", "t"]
    end
  end

  describe "make_move/2" do
    test "state doesn't change if state is won or lost" do
      for state <- [:won, :lost] do
        game =
          "wombat"
          |> Game.new_game()
          |> Map.put(:game_state, state)

        {new_game, _tally} = Game.make_move(game, "x")
        assert new_game == game
      end
    end

    test "a duplicate letter is reported" do
      game = Game.new_game()

      {game, _tally} = Game.make_move(game, "x")
      refute game.game_state == :already_used

      {game, _tally} = Game.make_move(game, "y")
      refute game.game_state == :already_used

      {game, _tally} = Game.make_move(game, "x")
      assert game.game_state == :already_used
    end

    test "letters used are recorded" do
      game = Game.new_game()

      {game, _tally} = Game.make_move(game, "x")
      {game, _tally} = Game.make_move(game, "y")
      {game, _tally} = Game.make_move(game, "x")

      assert MapSet.equal?(game.used, MapSet.new(["x", "y"]))
    end

    test "recognizes a letter in the word" do
      game = Game.new_game("wombat")

      {game, tally} = Game.make_move(game, "m")
      assert tally.game_state == :good_guess

      {game, tally} = Game.make_move(game, "t")
      assert tally.game_state == :good_guess
    end

    test "recognizes a letter not in the word" do
      game = Game.new_game("wombat")

      {game, tally} = Game.make_move(game, "x")
      assert tally.game_state == :bad_guess

      {game, tally} = Game.make_move(game, "t")
      assert tally.game_state == :good_guess

      {game, tally} = Game.make_move(game, "y")
      assert tally.game_state == :bad_guess
    end
  end

  test "can handle a winning game" do
    [
      # guess | state | turns left | letters | letters used
      ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["a", :already_used, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["e", :good_guess, 6, ["_", "e", "_", "_", "_"], ["a", "e"]],
      ["x", :bad_guess, 5, ["_", "e", "_", "_", "_"], ["a", "e", "x"]],
      ["l", :good_guess, 5, ["_", "e", "l", "l", "_"], ["a", "e", "l", "x"]],
      ["o", :good_guess, 5, ["_", "e", "l", "l", "o"], ["a", "e", "l", "o", "x"]],
      ["y", :bad_guess, 4, ["_", "e", "l", "l", "o"], ["a", "e", "l", "o", "x", "y"]],
      ["h", :won, 4, ["h", "e", "l", "l", "o"], ["a", "e", "h", "l", "o", "x", "y"]]
    ]
    |> test_sequence_of_moves()
  end

  test "can handle a losing game" do
    [
      # guess | state | turns left | letters | letters used
      ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["a", :already_used, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["e", :good_guess, 6, ["_", "e", "_", "_", "_"], ["a", "e"]],
      ["x", :bad_guess, 5, ["_", "e", "_", "_", "_"], ["a", "e", "x"]],
      ["z", :bad_guess, 4, ["_", "e", "_", "_", "_"], ["a", "e", "x", "z"]],
      ["q", :bad_guess, 3, ["_", "e", "_", "_", "_"], ["a", "e", "q", "x", "z"]],
      ["b", :bad_guess, 2, ["_", "e", "_", "_", "_"], ["a", "b", "e", "q", "x", "z"]],
      ["c", :bad_guess, 1, ["_", "e", "_", "_", "_"], ["a", "b", "c", "e", "q", "x", "z"]],
      ["d", :lost, 0, ["_", "e", "_", "_", "_"], ["a", "b", "c", "d", "e", "q", "x", "z"]]
    ]
    |> test_sequence_of_moves()
  end

  def test_sequence_of_moves(moves) do
    game = Game.new_game("hello")

    Enum.reduce(moves, game, &check_one_move/2)
  end

  defp check_one_move([guess, state, turns, letters, used], game) do
    {game, tally} = Game.make_move(game, guess)

    assert tally.game_state == state
    assert tally.turns_left == turns
    assert tally.letters == letters
    assert tally.used == used

    game
  end
end
