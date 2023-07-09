defmodule Periods.Period do
  alias Periods.Parser

  defstruct amount: 0, unit: :second

  defdelegate new(value), to: Parser

end
