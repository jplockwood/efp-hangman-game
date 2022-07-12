defmodule Hangman.Impl.Game do
  alias Hangman.Type

  @type t :: %__MODULE__{
          turns_left: integer,
          game_state: Type.state(),
          letters: list(String.t()),
          used: MapSet.t(String.t())
        }

  defstruct(
    turns_left: 7,
    game_state: :initializing,
    letters: [],
    used: MapSet.new()
  )

  @spec new_game() :: t
  def new_game(), do: new_game(Dictionary.random_word())

  @spec new_game(String.t()) :: t
  def new_game(word) when is_binary(word) do
    word
    |> String.codepoints()
    |> new_game()
  end

  @spec new_game(List.t()) :: t
  def new_game([first | _] = letters) when is_list(letters) and is_binary(first) do
    %__MODULE__{
      letters: Enum.map(letters, fn letter -> String.downcase(letter) end)
    }
  end

  @spec make_move(t, String.t()) :: {t, Type.tally()}
  def make_move(game = %{game_state: state}, _guess) when state in [:won, :lost],
    do: return_with_tally(game)

  def make_move(game, guess) do
    downcased_guess = String.downcase(guess)

    game
    |> accept_guess(guess, MapSet.member?(game.used, downcased_guess))
    |> return_with_tally()
  end

  defp accept_guess(game, guess, _already_used = true) do
    %{game | game_state: :already_used}
  end

  defp accept_guess(game, guess, _already_used) do
    downcased_guess = String.downcase(guess)

    %{game | used: MapSet.put(game.used, downcased_guess)}
    |> score_guess(Enum.member?(game.letters, downcased_guess))
  end

  defp score_guess(game, _good_guess = true) do
    new_state =
      game.letters
      |> MapSet.new()
      |> MapSet.subset?(game.used)
      |> maybe_won()

    %{game | game_state: new_state}
  end

  defp score_guess(game = %{turns_left: 1}, _bad_guess) do
    %{game | game_state: :lost, turns_left: 0}
  end

  defp score_guess(game, _bad_guess) do
    %{game | game_state: :bad_guess, turns_left: game.turns_left - 1}
  end

  defp return_with_tally(game), do: {game, tally(game)}

  defp tally(game) do
    %{
      turns_left: game.turns_left,
      game_state: game.game_state,
      letters: reveal_guessed_letters(game),
      used: game.used |> MapSet.to_list() |> Enum.sort()
    }
  end

  defp reveal_guessed_letters(game) do
    game.letters
    |> Enum.map(fn letter ->
      game.used
      |> MapSet.member?(letter)
      |> maybe_reveal(letter)
    end)
  end

  defp maybe_won(true), do: :won
  defp maybe_won(_), do: :good_guess

  defp maybe_reveal(true, letter), do: letter
  defp maybe_reveal(_, _letter), do: "_"
end
