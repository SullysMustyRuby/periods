defmodule Periods.Computation do
  import Periods.Conversion

  alias Periods.Period

  @index_units Enum.with_index(Periods.all_units())
  @month_restrictions [:millisecond, :second, :minute, :hour, :week]

  def add(%Period{unit: :month}, %Period{unit: unit}) when unit in @month_restrictions do
    {:error, :invalid_month_addition}
  end

  def add(%Period{unit: unit}, %Period{unit: :month}) when unit in @month_restrictions do
    {:error, :invalid_month_addition}
  end

  def add(%Period{unit: unit} = period_1, %Period{unit: unit} = period_2) do
    total = period_1.amount + period_2.amount
    %Period{amount: total, unit: unit}
  end

  def add(%Period{} = period_1, %Period{} = period_2) do
    unit = lowest_unit(period_1.unit, period_2.unit)
    add(convert(period_1, unit), convert(period_2, unit))
  end

  def add(%Time{}, %Period{unit: unit}) when unit in [:day, :week, :month, :year, :decade] do
    {:error, :invalid_time_addition}
  end

  def add(%Time{} = time, period) do
    case convert(period, :second) do
      %Period{unit: :second} = converted -> Time.add(time, converted.amount, :second)
      {:error, message} ->  {:error, message}
    end
  end

  def add(%Date{}, %Period{unit: :month}) do
    {:error, :invalid_date_addition}
  end

  def add(%Date{} = date, period) do
    case convert(period, :day) do
      %Period{unit: :day} = converted -> Date.add(date, converted.amount)
      {:error, message} ->  {:error, message}
    end
  end

  def add(%DateTime{}, %Period{unit: :month}) do
    {:error, :invalid_month_addition}
  end

  def add(%DateTime{} = date_time, %Period{unit: unit} = period) when unit not in @month_restrictions do
    case convert(period, :second) do
      %Period{unit: :second} = converted -> DateTime.add(date_time, converted.amount, :second)
      {:error, message} ->  {:error, message}
    end
  end

  def add(%DateTime{}, %Period{}) do
    {:error, :invalid_month_addition}
  end

  def add(%NaiveDateTime{}, %Period{unit: :month}) do
    {:error, :invalid_month_addition}
  end

  def add(%NaiveDateTime{} = date_time, %Period{unit: unit} = period) when unit not in @month_restrictions do
    case convert(period, :second) do
      %Period{unit: :second} = converted -> NaiveDateTime.add(date_time, converted.amount, :second)
      {:error, message} ->  {:error, message}
    end
  end

  def add(%NaiveDateTime{}, %Period{}) do
    {:error, :invalid_month_addition}
  end

  def subtract(%Period{unit: :month}, %Period{unit: unit}) when unit in @month_restrictions do
    {:error, :invalid_month_subtraction}
  end

  def subtract(%Period{unit: unit}, %Period{unit: :month}) when unit in @month_restrictions do
    {:error, :invalid_month_subtraction}
  end

  def subtract(%Period{unit: unit} = period_1, %Period{unit: unit} = period_2) do
    total = period_1.amount - period_2.amount
    %Period{amount: total, unit: unit}
  end

  def subtract(%Period{} = period_1, %Period{} = period_2) do
    unit = lowest_unit(period_1.unit, period_2.unit)
    subtract(convert(period_1, unit), convert(period_2, unit))
  end

  def subtract(%Time{}, %Period{unit: unit}) when unit in [:day, :week, :month, :year, :decade] do
    {:error, :invalid_time_subtraction}
  end

  def subtract(%Time{} = time, period) do
    case convert(period, :second) do
      %Period{unit: :second} = converted -> Time.add(time, -converted.amount)
      {:error, message} ->  {:error, message}
    end
  end

  def subtract(%Date{}, %Period{unit: :month}) do
    {:error, :invalid_date_addition}
  end

  def subtract(%Date{} = date, period) do
    case convert(period, :day) do
      %Period{unit: :day} = converted -> Date.add(date, -converted.amount)
      {:error, message} ->  {:error, message}
    end
  end

  def subtract(%DateTime{}, %Period{unit: :month}) do
    {:error, :invalid_month_subtraction}
  end

  def subtract(%DateTime{} = date_time, %Period{unit: unit} = period) when unit not in @month_restrictions do
    case convert(period, :second) do
      %Period{unit: :second} = converted -> DateTime.add(date_time, -converted.amount, :second)
      {:error, message} ->  {:error, message}
    end
  end

  def subtract(%DateTime{}, %Period{unit: unit}) when unit in @month_restrictions do
    {:error, :invalid_month_subtraction}
  end

  def subtract(%NaiveDateTime{}, %Period{unit: :month}) do
    {:error, :invalid_month_addition}
  end

  def subtract(%NaiveDateTime{} = date_time, %Period{unit: unit} = period) when unit not in @month_restrictions do
    case convert(period, :second) do
      %Period{unit: :second} = converted -> NaiveDateTime.add(date_time, -converted.amount, :second)
      {:error, message} ->  {:error, message}
    end
  end

  def subtract(%NaiveDateTime{}, %Period{}) do
    {:error, :invalid_month_addition}
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
