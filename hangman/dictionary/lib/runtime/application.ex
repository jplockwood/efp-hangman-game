defmodule Dictionary.Runtime.Application do
  use Application

  alias Dictionary.Runtime.Server

  def start(_type, _args) do
    Server.start_link()
  end
end
