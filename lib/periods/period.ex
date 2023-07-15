defmodule Periods.Period do
  @moduledoc false

  @default_unit Periods.default_unit()

  @enforce_keys [:amount, :unit]

  defstruct amount: 0, unit: @default_unit
end
