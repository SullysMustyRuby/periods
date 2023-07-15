defmodule Periods.Formatter do
  import Kernel, except: [to_string: 1]
  @moduledoc false

  alias Periods.Period

  @units Periods.all_units()

  def to_integer(period, convert_unit \\ nil)

  def to_integer(%Period{amount: amount}, nil), do: amount

  def to_integer(%Period{} = period, convert_unit) when convert_unit in @units do
    period
    |> Periods.convert(convert_unit)
    |> to_integer()
  end

  def to_integer({:error, message}, _unit), do: {:error, message}

  def to_string(period, convert_unit \\ nil)

  def to_string(%Period{amount: 1, unit: unit}, nil) do
    "1 #{unit}"
  end

  def to_string(%Period{amount: amount, unit: unit}, nil) do
    "#{amount} #{unit}s"
  end

  def to_string(%Period{} = period, convert_unit) when convert_unit in @units do
    period
    |> Periods.convert(convert_unit)
    |> to_string()
  end

  def to_string({:error, message}, _unit), do: {:error, message}
end
