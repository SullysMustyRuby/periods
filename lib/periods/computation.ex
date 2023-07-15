defmodule Periods.Computation do
  @moduledoc false

  import Periods.Conversion
  import Periods.Parser, only: [parse_unit: 1]

  alias Periods.Period

  @month_restrictions [:millisecond, :second, :minute, :hour, :week]
  @units Periods.all_units()
  @non_month_units List.delete(@units, :month)

  defmodule ComputationError do
    use Periods.Errors

    def exception({:invalid_month_addition, unit}) do
      %ComputationError{message: "cannot add #{unit} to month"}
    end

    def exception({:invalid_time_addition, unit}) do
      %ComputationError{message: "cannot add #{unit} to Time"}
    end

    def exception({:invalid_month_subtraction, unit}) do
      %ComputationError{message: "cannot subtract #{unit} with a month"}
    end

    def exception({:invalid_time_subtraction, unit}) do
      %ComputationError{message: "cannot subtract #{unit} with Time"}
    end
  end

  def add(%Period{unit: :month}, %Period{unit: unit}) when unit in @month_restrictions do
    {:error, {:invalid_month_addition, unit}}
  end

  def add(%Period{unit: unit}, %Period{unit: :month}) when unit in @month_restrictions do
    {:error, {:invalid_month_addition, unit}}
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
    {:error, {:invalid_time_addition, unit}}
  end

  def add(%Time{} = time, period) do
    case convert(period, :second) do
      %Period{unit: :second} = converted -> Time.add(time, converted.amount, :second)
      {:error, message} -> {:error, message}
    end
  end

  def add(%Date{}, %Period{unit: :month}) do
    {:error, {:invalid_month_addition, Date}}
  end

  def add(%Date{} = date, period) do
    case convert(period, :day) do
      %Period{unit: :day} = converted -> Date.add(date, converted.amount)
      {:error, message} -> {:error, message}
    end
  end

  def add(%DateTime{}, %Period{unit: :month}) do
    {:error, {:invalid_month_addition, DateTime}}
  end

  def add(%DateTime{} = date_time, %Period{} = period) do
    case convert(period, :second) do
      %Period{unit: :second} = converted -> DateTime.add(date_time, converted.amount, :second)
      {:error, message} -> {:error, message}
    end
  end

  def add(%NaiveDateTime{}, %Period{unit: :month}) do
    {:error, {:invalid_month_addition, NaiveDateTime}}
  end

  def add(%NaiveDateTime{} = date_time, %Period{unit: unit} = period)
      when unit not in @month_restrictions do
    case convert(period, :second) do
      %Period{unit: :second} = converted ->
        NaiveDateTime.add(date_time, converted.amount, :second)

      {:error, message} ->
        {:error, message}
    end
  end

  def add(%NaiveDateTime{}, %Period{}) do
    {:error, {:invalid_month_addition, NaiveDateTime}}
  end

  def add(%Period{} = period, other), do: add(other, period)

  def diff(computation_type_1, computation_type_2, unit \\ nil)

  def diff(%Time{} = time_1, %Time{} = time_2, nil) do
    time_1
    |> Time.diff(time_2)
    |> Periods.new(:second)
  end

  def diff(%Time{} = time_1, %Time{} = time_2, unit) when unit in [:millisecond, :second] do
    time_1
    |> Time.diff(time_2, unit)
    |> Periods.new(unit)
  end

  def diff(%Time{}, %Time{}, _unit), do: {:error, :invalid_unit_type}

  def diff(%Date{} = date_1, %Date{} = date_2, nil) do
    date_1
    |> Date.diff(date_2)
    |> Periods.new(:day)
  end

  def diff(%Date{} = date_1, %Date{} = date_2, unit) when unit in @non_month_units do
    case diff(date_1, date_2) do
      {:ok, period} -> {:ok, convert(period, unit)}
      {:error, message} -> {:error, message}
    end
  end

  def diff(%Date{month: month_1, year: year_1}, %Date{month: month_2, year: year_2}, :month) do
    month_diff({year_1, month_1}, {year_2, month_2})
  end

  def diff(
        %DateTime{time_zone: time_zone} = datetime_1,
        %DateTime{time_zone: time_zone} = datetime_2,
        nil
      ) do
    datetime_1
    |> DateTime.diff(datetime_2)
    |> Periods.new(:second)
  end

  def diff(
        %DateTime{time_zone: time_zone} = datetime_1,
        %DateTime{time_zone: time_zone} = datetime_2,
        :millisecond
      ) do
    datetime_1
    |> DateTime.diff(datetime_2, :millisecond)
    |> Periods.new(:millisecond)
  end

  def diff(
        %DateTime{month: month_1, year: year_1, time_zone: time_zone},
        %DateTime{month: month_2, year: year_2, time_zone: time_zone},
        :month
      ) do
    month_diff({year_1, month_1}, {year_2, month_2})
  end

  def diff(
        %DateTime{time_zone: time_zone} = datetime_1,
        %DateTime{time_zone: time_zone} = datetime_2,
        unit
      )
      when unit in @non_month_units do
    case diff(datetime_1, datetime_2) do
      {:ok, period} -> {:ok, convert(period, unit)}
      {:error, message} -> {:error, message}
    end
  end

  def diff(
        %DateTime{time_zone: _time_zone_1} = datetime_1,
        %DateTime{time_zone: _time_zone_2} = datetime_2,
        unit
      )
      when unit in @units or unit == nil do
    {:ok, utc_datetime_1} = DateTime.shift_zone(datetime_1, "Etc/UTC")
    {:ok, utc_datetime_2} = DateTime.shift_zone(datetime_2, "Etc/UTC")
    diff(utc_datetime_1, utc_datetime_2, unit)
  end

  def diff(%NaiveDateTime{} = naive_datetime_1, %NaiveDateTime{} = naive_datetime_2, nil) do
    naive_datetime_1
    |> NaiveDateTime.diff(naive_datetime_2)
    |> Periods.new(:second)
  end

  def diff(%NaiveDateTime{} = naive_datetime_1, %NaiveDateTime{} = naive_datetime_2, :millisecond) do
    naive_datetime_1
    |> NaiveDateTime.diff(naive_datetime_2, :millisecond)
    |> Periods.new(:millisecond)
  end

  def diff(
        %NaiveDateTime{month: month_1, year: year_1},
        %NaiveDateTime{month: month_2, year: year_2},
        :month
      ) do
    month_diff({year_1, month_1}, {year_2, month_2})
  end

  def diff(%NaiveDateTime{} = naive_datetime_1, %NaiveDateTime{} = naive_datetime_2, unit)
      when unit in @non_month_units do
    case diff(naive_datetime_1, naive_datetime_2) do
      {:ok, period} -> {:ok, convert(period, unit)}
      {:error, message} -> {:error, message}
    end
  end

  def diff(computation_type_1, computation_type_2, unit) when is_binary(unit) do
    case parse_unit(unit) do
      {:ok, unit} -> diff(computation_type_1, computation_type_2, unit)
      {:error, message} -> {:error, message}
    end
  end

  def diff(_computation_type_1, _computation_type_2, unit) when unit in @units,
    do: {:error, :invalid_arguments}

  def diff(_computation_type_1, _computation_type_2, _unit), do: {:error, :invalid_unit_type}

  defp month_diff({year_1, month_1}, {year_2, month_2}) do
    with {:ok, years} <- Periods.new(year_1 - year_2, :year),
         {:ok, months} <- Periods.new(month_1 - month_2, :month),
         %Period{} = period <- Periods.add(years, months) do
      {:ok, period}
    end
  end

  def subtract(%Period{unit: :month}, %Period{unit: unit}) when unit in @month_restrictions do
    {:error, {:invalid_month_subtraction, unit}}
  end

  def subtract(%Period{unit: unit}, %Period{unit: :month}) when unit in @month_restrictions do
    {:error, {:invalid_month_subtraction, unit}}
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
    {:error, {:invalid_time_subtraction, unit}}
  end

  def subtract(%Time{} = time, period) do
    case convert(period, :second) do
      %Period{unit: :second} = converted -> Time.add(time, -converted.amount)
      {:error, message} -> {:error, message}
    end
  end

  def subtract(%Date{}, %Period{unit: :month}) do
    {:error, {:invalid_month_subtraction, Date}}
  end

  def subtract(%Date{} = date, period) do
    case convert(period, :day) do
      %Period{unit: :day} = converted -> Date.add(date, -converted.amount)
      {:error, message} -> {:error, message}
    end
  end

  def subtract(%DateTime{}, %Period{unit: :month}) do
    {:error, {:invalid_month_subtraction, DateTime}}
  end

  def subtract(%DateTime{} = date_time, %Period{} = period) do
    case convert(period, :second) do
      %Period{unit: :second} = converted -> DateTime.add(date_time, -converted.amount, :second)
      {:error, message} -> {:error, message}
    end
  end

  def subtract(%NaiveDateTime{}, %Period{unit: :month}) do
    {:error, {:invalid_month_subtraction, NaiveDateTime}}
  end

  def subtract(%NaiveDateTime{} = date_time, %Period{unit: unit} = period)
      when unit not in @month_restrictions do
    case convert(period, :second) do
      %Period{unit: :second} = converted ->
        NaiveDateTime.add(date_time, -converted.amount, :second)

      {:error, message} ->
        {:error, message}
    end
  end

  def subtract(%Period{} = period, other), do: subtract(other, period)

  defp lowest_unit(unit_1, unit_2) do
    index_units = Enum.with_index(Periods.all_units())
    unit_1_index = Keyword.get(index_units, unit_1)
    unit_2_index = Keyword.get(index_units, unit_2)

    case unit_1_index < unit_2_index do
      true -> unit_1
      false -> unit_2
    end
  end
end
