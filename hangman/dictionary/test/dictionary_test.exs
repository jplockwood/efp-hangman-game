defmodule DictionaryTest do
  use ExUnit.Case
  doctest Dictionary

  test "start/0" do
    assert is_list(Dictionary.start())
  end
end
