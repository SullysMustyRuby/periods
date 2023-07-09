defmodule Periods do
  @moduledoc """
  Documentation for `Periods`.
  """

  alias Periods.Parser

  defdelegate new(value), to: Parser
end
