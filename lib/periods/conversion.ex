defmodule Periods.Conversion do
  @moduledoc false

  alias Periods.Parser
  alias Periods.Period

  @units Periods.all_units()

  defmodule ConversionError do
    use Periods.Errors

    def exception({:cannot_convert_to_month, unit}) do
      %ConversionError{message: "cannot convert #{unit} to month"}
    end
  end

  def convert!(period, unit) do
    case convert(period, unit) do
      %Period{} = converted_period -> converted_period
      {:error, message} -> raise ConversionError.exception(message)
    end
  end

  def convert(%Period{unit: unit} = period, unit) when unit in @units, do: period

  def convert(%Period{unit: :millisecond} = period, :second) do
    new_amount = Decimal.div_int(period.amount, 1000) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :second}
  end

  def convert(%Period{unit: :millisecond} = period, :minute) do
    new_amount = Decimal.div_int(period.amount, 60_000) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :minute}
  end

  def convert(%Period{unit: :millisecond} = period, :hour) do
    new_amount = Decimal.div_int(period.amount, 3_600_000) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :hour}
  end

  def convert(%Period{unit: :millisecond} = period, :day) do
    new_amount = Decimal.div_int(period.amount, 86_400_000) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :day}
  end

  def convert(%Period{unit: :millisecond} = period, :week) do
    new_amount = Decimal.div_int(period.amount, 604_800_000) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :week}
  end

  def convert(%Period{unit: :millisecond} = period, :year) do
    new_amount = Decimal.div_int(period.amount, 31_536_000_000) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :year}
  end

  def convert(%Period{unit: :millisecond} = period, :decade) do
    new_amount = Decimal.div_int(period.amount, 315_360_000_000) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :decade}
  end

  def convert(%Period{unit: :second} = period, :millisecond) do
    new_amount = period.amount * 1000
    %Period{amount: new_amount, unit: :millisecond}
  end

  def convert(%Period{unit: :second} = period, :minute) do
    new_amount = Decimal.div_int(period.amount, 60) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :minute}
  end

  def convert(%Period{unit: :second} = period, :hour) do
    new_amount = Decimal.div_int(period.amount, 3_600) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :hour}
  end

  def convert(%Period{unit: :second} = period, :day) do
    new_amount = Decimal.div_int(period.amount, 86_400) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :day}
  end

  def convert(%Period{unit: :second} = period, :week) do
    new_amount = Decimal.div_int(period.amount, 604_800) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :week}
  end

  def convert(%Period{unit: :second} = period, :year) do
    new_amount = Decimal.div_int(period.amount, 31_536_000) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :year}
  end

  def convert(%Period{unit: :second} = period, :decade) do
    new_amount = Decimal.div_int(period.amount, 315_360_000) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :decade}
  end

  def convert(%Period{unit: :minute} = period, :millisecond) do
    new_amount = period.amount * 60_000
    %Period{amount: new_amount, unit: :millisecond}
  end

  def convert(%Period{unit: :minute} = period, :second) do
    new_amount = period.amount * 60
    %Period{amount: new_amount, unit: :second}
  end

  def convert(%Period{unit: :minute} = period, :hour) do
    new_amount = Decimal.div_int(period.amount, 60) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :hour}
  end

  def convert(%Period{unit: :minute} = period, :day) do
    new_amount = Decimal.div_int(period.amount, 1_440) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :day}
  end

  def convert(%Period{unit: :minute} = period, :week) do
    new_amount = Decimal.div_int(period.amount, 10_080) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :week}
  end

  def convert(%Period{unit: :minute} = period, :year) do
    new_amount = Decimal.div_int(period.amount, 525_600) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :year}
  end

  def convert(%Period{unit: :minute} = period, :decade) do
    new_amount = Decimal.div_int(period.amount, 5_256_000) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :decade}
  end

  def convert(%Period{unit: :hour} = period, :millisecond) do
    new_amount = period.amount * 3_600_000
    %Period{amount: new_amount, unit: :millisecond}
  end

  def convert(%Period{unit: :hour} = period, :second) do
    new_amount = period.amount * 3_600
    %Period{amount: new_amount, unit: :second}
  end

  def convert(%Period{unit: :hour} = period, :minute) do
    new_amount = period.amount * 60
    %Period{amount: new_amount, unit: :minute}
  end

  def convert(%Period{unit: :hour} = period, :day) do
    new_amount = Decimal.div_int(period.amount, 24) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :day}
  end

  def convert(%Period{unit: :hour} = period, :week) do
    new_amount = Decimal.div_int(period.amount, 168) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :week}
  end

  def convert(%Period{unit: :hour} = period, :year) do
    new_amount = Decimal.div_int(period.amount, 8_760) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :year}
  end

  def convert(%Period{unit: :hour} = period, :decade) do
    new_amount = Decimal.div_int(period.amount, 87_600) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :decade}
  end

  def convert(%Period{unit: :day} = period, :millisecond) do
    new_amount = period.amount * 86_400_000
    %Period{amount: new_amount, unit: :millisecond}
  end

  def convert(%Period{unit: :day} = period, :second) do
    new_amount = period.amount * 86_400
    %Period{amount: new_amount, unit: :second}
  end

  def convert(%Period{unit: :day} = period, :minute) do
    new_amount = period.amount * 1_440
    %Period{amount: new_amount, unit: :minute}
  end

  def convert(%Period{unit: :day} = period, :hour) do
    new_amount = period.amount * 24
    %Period{amount: new_amount, unit: :hour}
  end

  def convert(%Period{unit: :day} = period, :week) do
    new_amount = Decimal.div_int(period.amount, 7) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :week}
  end

  def convert(%Period{unit: :day} = period, :year) do
    new_amount = Decimal.div_int(period.amount, 365) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :year}
  end

  def convert(%Period{unit: :day} = period, :decade) do
    new_amount = Decimal.div_int(period.amount, 3_650) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :decade}
  end

  def convert(%Period{unit: :week} = period, :millisecond) do
    new_amount = period.amount * 604_800_000
    %Period{amount: new_amount, unit: :millisecond}
  end

  def convert(%Period{unit: :week} = period, :second) do
    new_amount = period.amount * 604_800
    %Period{amount: new_amount, unit: :second}
  end

  def convert(%Period{unit: :week} = period, :minute) do
    new_amount = period.amount * 10_080
    %Period{amount: new_amount, unit: :minute}
  end

  def convert(%Period{unit: :week} = period, :hour) do
    new_amount = period.amount * 168
    %Period{amount: new_amount, unit: :hour}
  end

  def convert(%Period{unit: :week} = period, :day) do
    new_amount = period.amount * 7
    %Period{amount: new_amount, unit: :day}
  end

  def convert(%Period{unit: :week} = period, :year) do
    new_amount = Decimal.div_int(period.amount, 52) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :year}
  end

  def convert(%Period{unit: :week} = period, :decade) do
    new_amount = Decimal.div_int(period.amount, 520) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :decade}
  end

  def convert(%Period{unit: :month} = period, :year) do
    new_amount = Decimal.div_int(period.amount, 12) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :year}
  end

  def convert(%Period{unit: :month} = period, :decade) do
    new_amount = Decimal.div_int(period.amount, 120) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :decade}
  end

  def convert(%Period{unit: :year} = period, :millisecond) do
    new_amount = period.amount * 31_536_000_000
    %Period{amount: new_amount, unit: :millisecond}
  end

  def convert(%Period{unit: :year} = period, :second) do
    new_amount = period.amount * 31_536_000
    %Period{amount: new_amount, unit: :second}
  end

  def convert(%Period{unit: :year} = period, :minute) do
    new_amount = period.amount * 525_600
    %Period{amount: new_amount, unit: :minute}
  end

  def convert(%Period{unit: :year} = period, :hour) do
    new_amount = period.amount * 8_760
    %Period{amount: new_amount, unit: :hour}
  end

  def convert(%Period{unit: :year} = period, :day) do
    new_amount = period.amount * 365
    %Period{amount: new_amount, unit: :day}
  end

  def convert(%Period{unit: :year} = period, :week) do
    new_amount = period.amount * 52
    %Period{amount: new_amount, unit: :week}
  end

  def convert(%Period{unit: :year} = period, :month) do
    new_amount = period.amount * 12
    %Period{amount: new_amount, unit: :month}
  end

  def convert(%Period{unit: :year} = period, :decade) do
    new_amount = Decimal.div_int(period.amount, 10) |> Decimal.to_integer()
    %Period{amount: new_amount, unit: :decade}
  end

  def convert(%Period{unit: :decade} = period, :millisecond) do
    new_amount = period.amount * 315_360_000_000
    %Period{amount: new_amount, unit: :millisecond}
  end

  def convert(%Period{unit: :decade} = period, :second) do
    new_amount = period.amount * 315_360_000
    %Period{amount: new_amount, unit: :second}
  end

  def convert(%Period{unit: :decade} = period, :minute) do
    new_amount = period.amount * 5_256_000
    %Period{amount: new_amount, unit: :minute}
  end

  def convert(%Period{unit: :decade} = period, :hour) do
    new_amount = period.amount * 87_600
    %Period{amount: new_amount, unit: :hour}
  end

  def convert(%Period{unit: :decade} = period, :day) do
    new_amount = period.amount * 3650
    %Period{amount: new_amount, unit: :day}
  end

  def convert(%Period{unit: :decade} = period, :week) do
    new_amount = period.amount * 520
    %Period{amount: new_amount, unit: :week}
  end

  def convert(%Period{unit: :decade} = period, :month) do
    new_amount = period.amount * 120
    %Period{amount: new_amount, unit: :month}
  end

  def convert(%Period{unit: :decade} = period, :year) do
    new_amount = period.amount * 10
    %Period{amount: new_amount, unit: :year}
  end

  def convert(%Period{unit: unit}, :month), do: {:error, {:cannot_convert_to_month, unit}}

  def convert(%Period{} = period, unit) do
    case Parser.parse_unit(unit) do
      {:ok, parsed_unit} -> convert(period, parsed_unit)
      {:error, message} -> {:error, message}
    end
  end

  def convert(_period, _unit), do: {:error, :invalid_arguments}
end
