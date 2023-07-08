defmodule Periods.Period do
  @units [:milisecond, :second, :minute, :hour, :day, :week, :month, :year, :decade]

  defstruct amount: 0, unit: :second

  def new(%{amount: amount, unit: unit}) when is_integer(amount) and unit in @units do
    {:ok, %__MODULE__{amount: amount, unit: unit}}
  end

  def new(%{amount: amount, unit: unit}) when is_binary(amount) and unit in @units do
    case parse_binary_amount(amount) do
      {:ok, integer} -> new(%{amount: integer, unit: unit})
      {:error, message} -> {:error, message}
    end
  end

  def new(amount) when is_integer(amount) do
    new(%{amount: amount, unit: default_unit()})
  end

  def new(amount) when is_binary(amount) do
    case parse_binary_amount(amount) do
      {:ok, integer} -> new(%{amount: integer, unit: default_unit()})
      {:error, message} -> {:error, message}
    end
  end

  def new({amount, unit}) when is_integer(amount) and unit in @units do
    new(%{amount: amount, unit: unit})
  end

  def new(_), do: {:error, :cannot_parse}

  defp default_unit do
    Application.get_env(Periods, :default_unit, :second)
  end

  defp parse_binary_amount(amount) do
    case Integer.parse(amount) do
      {integer, ""} -> {:ok, integer}
      {_integer, remainder} when remainder != "" -> {:error, :amounts_must_be_integers}
      _ -> {:error, :cannot_parse_amount}
    end
  end
end
