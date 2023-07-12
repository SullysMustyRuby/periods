defmodule Periods.Formatter do
  import Kernel, except: [to_string: 1]
  @moduledoc false

  alias Periods.Period

  @units Periods.all_units()

  def to_string(period, convert_unit \\ nil)

  def to_string(%Period{} = period, convert_unit) when convert_unit in @units do
    period
    |> Periods.convert(convert_unit)
    |> to_string()
  end

  def to_string(%Period{amount: amount, unit: unit}, nil) when amount == 1 do
    "#{amount} #{unit}"
  end

  def to_string(%Period{amount: amount, unit: unit}, nil) do
    "#{amount} #{unit}s"
  end

  def to_string(%Period{} = period, convert_unit) when convert_unit in @units do
    period
    |> Periods.convert(convert_unit)
    |> to_string()
  end

  def to_integer(period, convert_unit \\ nil)

  def to_integer(%Period{amount: amount}, nil), do: amount

  def to_integer(%Period{} = period, convert_unit) when convert_unit in @units do
    period
    |> Periods.convert(convert_unit)
    |> to_integer()
  end
end
