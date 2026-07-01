defmodule Periods.Period do
  @moduledoc """
  A struct representing an increment of time as an integer `amount` of a `unit`.

  The `unit` is one of `Periods.all_units/0` (`:millisecond` through `:decade`) and the
  `amount` is always an integer, which may be negative. Build Periods with `Periods.new/1`,
  `Periods.new/2`, or their raising variants rather than constructing the struct directly.

  Periods implement the `Inspect` and `String.Chars` protocols:

      iex> inspect(%Periods.Period{amount: 10, unit: :day})
      "#Periods.Period<10 day>"

      iex> to_string(%Periods.Period{amount: 1, unit: :day})
      "1 day"
  """

  @default_unit Periods.default_unit()

  @enforce_keys [:amount, :unit]

  defstruct amount: 0, unit: @default_unit

  @type t :: %__MODULE__{amount: integer(), unit: atom()}

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%{amount: amount, unit: unit}, _opts) do
      concat(["#Periods.Period<", Kernel.to_string(amount), " ", Kernel.to_string(unit), ">"])
    end
  end

  defimpl String.Chars do
    def to_string(period), do: Periods.Formatter.to_string(period)
  end
end
