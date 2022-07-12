defmodule TextClient.Impl.Player do
  alias Hangman

  @typep game :: Hangman.game()
  @typep tally :: Hangman.tally()
  @typep state :: {game, tally}

  @spec start() :: :ok
  def start() do
    game = Hangman.new_game()
    tally = Hangman.tally(game)
    interact({game, tally})
  end

  @spec interact(state) :: :ok

  def interact({_game, _tally = %{game_state: :won}}) do
    IO.puts([IO.ANSI.cyan(), "Congratulations! You've won!"])
  end

  def interact({_game = %{letters: letters}, _tally = %{game_state: :lost}}) do
    IO.puts("Sorry, you've lost ... the word was #{IO.ANSI.light_red()}#{Enum.join(letters)}")
  end

  def interact(_state = {game, tally}) do
    IO.puts(feedback_for(tally))
    IO.puts(current_word(tally))

    guess = get_guess()

    game
    |> Hangman.make_move(guess)
    |> interact()
  end

  def get_guess() do
    IO.gets("Next letter: ")
    |> String.trim()
    |> String.downcase()
  end

  def current_word(%{letters: letters, turns_left: turns_left, used: used}) do
    [
      "Word so far: ",
      Enum.join(letters, " "),
      IO.ANSI.green(),
      "  (turns left: ",
      IO.ANSI.magenta(),
      to_string(turns_left),
      IO.ANSI.green(),
      ",  used so far: ",
      IO.ANSI.yellow(),
      Enum.join(used, ","),
      IO.ANSI.green(),
      ")",
      IO.ANSI.reset()
    ]
  end

  defp feedback_for(%{letters: letters, game_state: :initializing}) do
    "Welcome! I'm thinking of a #{length(letters)} letter word."
  end

  defp feedback_for(%{game_state: :good_guess}), do: "Good guess!"
  defp feedback_for(%{game_state: :bad_guess}), do: "Sorry, that letter's not in the word."
  defp feedback_for(%{game_state: :already_used}), do: "You already used that letter."
end
