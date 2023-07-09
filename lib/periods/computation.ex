defmodule Periods.Computation do
  alias Periods.Period

  @index_units Enum.with_index(Periods.all_units())

  def add(%Period{unit: unit} = period_1, %Period{unit: unit} = period_2) do
    total = period_1.amount + period_2.amount
    %Period{amount: total, unit: unit}
  end

  def add(%Period{} = period_1, %Period{} = period_2) do
    unit = lowest_unit(period_1.unit, period_2.unit)
  end

  defp lowest_unit(unit_1, unit_2) do
    unit_1_index = Keyword.get(@index_units, unit_1)
    unit_2_index = Keyword.get(@index_units, unit_2)

    case unit_1_index < unit_2_index do
      true -> unit_1
      false -> unit_2
    end
  end
end
