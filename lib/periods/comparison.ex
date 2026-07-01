defmodule Periods.Comparison do
  @moduledoc false

  import Periods.Conversion, only: [convert: 2, lowest_unit: 2]

  alias Periods.Period

  def compare(%Period{unit: unit} = period_1, %Period{unit: unit} = period_2) do
    compare_amounts(period_1.amount, period_2.amount)
  end

  def compare(%Period{} = period_1, %Period{} = period_2) do
    unit = lowest_unit(period_1.unit, period_2.unit)

    with %Period{} = converted_1 <- convert(period_1, unit),
         %Period{} = converted_2 <- convert(period_2, unit) do
      compare_amounts(converted_1.amount, converted_2.amount)
    else
      {:error, message} -> {:error, message}
    end
  end

  def compare(_value_1, _value_2), do: {:error, :invalid_arguments}

  defp compare_amounts(amount_1, amount_2) when amount_1 < amount_2, do: :lt
  defp compare_amounts(amount_1, amount_2) when amount_1 > amount_2, do: :gt
  defp compare_amounts(_amount_1, _amount_2), do: :eq
end
