defmodule Periods.Parser do
  @moduledoc false

  alias Periods.Period

  @units Periods.all_units()

  defmodule ParserError do
    defexception [:message]

    @spec exception(Keyword.t()) :: %ParserError{}
    def exception([amount: error_message]) do
      %ParserError{message: "amount: #{error_message}"}
    end

    def exception([unit: error_message]) do
      %ParserError{message: "unit: #{error_message}"}
    end
  end

  def new!(params) do
    case new(params) do
      {:ok, period} -> period
      {:error, message} -> raise ParserError.exception(message)
    end
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
    {:error, [amount: "must be an integer"]}
  end

  def new(%{amount: _, unit: unit}) when unit not in @units do
    {:error, [unit: "bad type"]}
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
    {:error, [amount: "must be an integer"]}
  end

  def new({_amount, unit}) when unit not in @units do
    {:error, [unit: "bad type"]}
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

  def new(_amount), do: {:error, [amount: "must be an integer"]}

  @spec parse_unit(binary()) :: {:ok, atom()} | {:error, Keyword.t()}
  def parse_unit(unit) when is_binary(unit) do
    case String.to_existing_atom(unit) do
      parsed_unit when parsed_unit in @units -> {:ok, parsed_unit}
      _ -> {:error, [unit: "bad type"]}
    end
  end

  def parse_unit(_unit), do: {:error, [unit: "bad type"]}

  defp parse_amount(amount) do
    case Integer.parse(amount) do
      {integer, ""} -> {:ok, integer}
      {_integer, remainder} when remainder != "" -> {:error, [amount: "must be an integer"]}
      _ -> {:error, [amount: "cannot parse amount"]}
    end
  end
end
