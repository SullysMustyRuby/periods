defmodule Periods.Parser do
  @moduledoc false

  alias Periods.Period

  @units Periods.all_units()

  defmodule ParserError do
    use Periods.Errors
  end

  def new(%{amount: amount, unit: unit}) when is_integer(amount) and unit in @units do
    {:ok, %Period{amount: amount, unit: unit}}
  end

  def new(%{amount: amount, unit: unit}) when is_binary(amount) and unit in @units do
    case parse_amount(amount) do
      {:ok, integer} -> new({integer, unit})
      {:error, message} -> {:error, message}
    end
  end

  def new(%{amount: amount, unit: unit}) when is_binary(unit) do
    case parse_unit(unit) do
      {:ok, parsed_unit} -> new(%{amount: amount, unit: parsed_unit})
      {:error, message} -> {:error, message}
    end
  end

  def new(%{amount: _, unit: unit}) when unit in @units do
    {:error, :amount_must_be_integer}
  end

  def new(%{amount: _, unit: unit}) when unit not in @units do
    {:error, :invalid_unit_type}
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

  def new({amount, unit}) when is_binary(unit) do
    case parse_unit(unit) do
      {:ok, parsed_unit} -> new(%{amount: amount, unit: parsed_unit})
      {:error, message} -> {:error, message}
    end
  end

  def new({_amount, unit}) when unit in @units do
    {:error, :amount_must_be_integer}
  end

  def new({_amount, unit}) when unit not in @units do
    {:error, :invalid_unit_type}
  end

  def new(amount) when is_integer(amount) do
    new(%{amount: amount, unit: Periods.default_unit()})
  end

  def new(amount) when is_binary(amount) do
    case parse_amount(amount) do
      {:ok, integer} -> new(%{amount: integer, unit: Periods.default_unit()})
      {:error, message} -> {:error, message}
    end
  end

  def new(_amount), do: {:error, :amount_must_be_integer}

  def new!(params) do
    case new(params) do
      {:ok, period} -> period
      {:error, message} -> raise ParserError.exception(message)
    end
  end

  def new(amount, unit), do: new({amount, unit})

  @spec parse_unit(binary()) :: {:ok, atom()} | {:error, atom()}
  def parse_unit(unit) when is_binary(unit) do
    case String.to_existing_atom(unit) do
      parsed_unit when parsed_unit in @units -> {:ok, parsed_unit}
      _ -> {:error, :invalid_unit_type}
    end
  end

  def parse_unit(_unit), do: {:error, :invalid_unit_type}

  defp parse_amount(amount) do
    case Integer.parse(amount) do
      {integer, ""} -> {:ok, integer}
      _ -> {:error, :amount_must_be_integer}
    end
  end
end
