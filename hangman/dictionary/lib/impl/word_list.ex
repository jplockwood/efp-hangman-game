defmodule Dictionary.Impl.WordList do
  @type t :: list(String.t())

  @spec word_list() :: t
  def word_list() do
    "../dictionary/assets/words.txt"
    |> File.read!()
    |> String.split(~r/\n/, trim: true)
  end

  @spec random_word(list(String.t())) :: t
  def random_word(word_list), do: Enum.random(word_list)
end
