defmodule Periods.Period do
  @units [:milisecond, :second, :minute, :hour, :day, :week, :month, :year, :decade]

  defstruct amount: 0, unit: :second

  def new(%{amount: amount, unit: unit}) when is_integer(amount) and unit in @units do
    {:ok, %__MODULE__{amount: amount, unit: unit}}
  end

  def new(%{amount: amount, unit: unit}) when is_binary(amount) and unit in @units do
    case parse_amount(amount) do
      {:ok, integer} -> new(%{amount: integer, unit: unit})
      {:error, message} -> {:error, message}
    end
  end

  def new(%{amount: _, unit: unit}) when unit in @units do
    {:error, :amount_must_be_an_integer}
  end

  def new(%{amount: _, unit: unit}) when unit not in @units do
    {:error, :bad_unit_type}
  end

  def new({amount, unit}) when is_integer(amount) and unit in @units do
    new(%{amount: amount, unit: unit})
  end

  def new({amount, unit}) when is_binary(amount) and unit in @units do
    case parse_amount(amount) do
      {:ok, integer} -> new(%{amount: integer, unit: unit})
      {:error, message} -> {:error, message}
    end
  end

  def new(amount) when is_integer(amount) do
    new(%{amount: amount, unit: default_unit()})
  end

  def new(amount) when is_binary(amount) do
    case parse_amount(amount) do
      {:ok, integer} -> new(%{amount: integer, unit: default_unit()})
      {:error, message} -> {:error, message}
    end
  end

  def new(_amount), do: {:error, :amount_must_be_an_integer}

  defp default_unit do
    Application.get_env(Periods, :default_unit, :second)
  end

  defp parse_amount(amount) do
    case Integer.parse(amount) do
      {integer, ""} -> {:ok, integer}
      {_integer, remainder} when remainder != "" -> {:error, :amount_must_be_an_integer}
      _ -> {:error, :cannot_parse_amount}
    end
  end
end
