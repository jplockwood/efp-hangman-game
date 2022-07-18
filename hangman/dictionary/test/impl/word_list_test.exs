defmodule Dictionary.Impl.WordListTest do
  use ExUnit.Case

  alias Dictionary.Impl.WordList

  describe "word_list/0" do
    test "returns word list" do
      word_list = WordList.word_list()

      assert is_list(word_list)
      assert Enum.count(word_list) == 8879
    end
  end

  describe "random_word/1" do
    test "returns a single word from the word list" do
      assert WordList.random_word(["a", "b", "c"]) in ["a", "b", "c"]
    end
  end
end