defmodule Periods.Period do
  @default_unit Periods.default_unit()

  @enforce_keys [:amount, :unit]

  @type t() :: %__MODULE__{
    amount: integer(),
    unit: atom()
  }

  defstruct amount: 0, unit: @default_unit
end
