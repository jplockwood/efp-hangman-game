defmodule DictionaryTest do
  use ExUnit.Case
  doctest Dictionary

  test "random_word/0" do
    assert is_binary(Dictionary.random_word())
  end
end
