defmodule Dictionary do
  alias Dictionary.Runtime.Server

  @opaque t :: WordList.t()

  @spec random_word() :: String.t()
  defdelegate random_word(), to: Server
end
