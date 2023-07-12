defmodule Periods do
  @moduledoc """
  Periods increments of time.

  Periods are designed to represent fractions of time from milliseconds to decades
  in order to help make working with various time based structs easier.

  Periods can be converted, added, and subtracted,

  By default the base value is a `second` you can choose a different base for your
  application by setting the `:default_value` in you Application config.

  The only limitation are months. Due to the inconsistency of a period of a month from 28-31
  days conversion and mathematical operations are limited.
  """

  alias Periods.Computation
  alias Periods.Conversion
  alias Periods.Parser
  alias Periods.Period

  @type computation :: Period.t() | Time.t() | Date.t() | DateTime.t() | NaiveDateTime.t()
  @type amount :: integer() | String.t()
  @type unit :: atom() | String.t()
  @type parse_type ::
          %{amount: amount(), unit: unit()}
          | {amount(), unit()}
          | amount()

  @units [:millisecond, :second, :minute, :hour, :day, :week, :month, :year, :decade]

  @doc """
  Add a Period to a Period, Time, Date, DateTime, or NaiveDateTime.

  Note: `Months` have limited additive properties

  When performing addition of periods all values will be converted to the lowest
  unit value. For example if you add a Period of days to a Period of seconds then
  the result will be seconds.

  When adding a period to an Elixir date/time struct the return will be the Elixir
  date/time struct.

  Note: Since there is conversion involved you may loose fractional values such as
  adding 1 millisecond to a Date.

  ## Examples

      iex> Periods.add(%Period{amount: 10, unit: :day}, %Period{amount: 1000, unit: :second})
      %Period(amount: 865000, unit: :second)

      iex> DateTime.utc_now() |> Periods.add(%Period{amount: 1000, unit: :second})
      ~U[2023-07-09 14:14:50.896089Z]

      iex> Time.utc_now() |> Periods.add(%Period{amount: 1000, unit: :second})
      ~T[14:17:04.932992]

      iex> today = Date.utc_today()
      ~D[2023-07-09]
      iex> Periods.add(today, %Period{amount: 1, unit: :millisecond})
      ~D[2023-07-09]
  """
  @spec add(computation(), Period.t()) :: computation() | {:error, atom()}
  defdelegate add(value_1, value_2), to: Computation

  @doc """
  Convert a Period from one unit to another unit.

  Note: `Months` have limited conversion properties

  When converting from a lower unit such as milliseconds to a higher unit such as seconds,
  since all return values are integers, you will loose precision due to rounding. In some
  conversion scenarios you may get a 0 value.

  ## Examples

      iex> Periods.convert(%Period{amount: 10, unit: :day}, :second)
      %Periods.Period{amount: 864000, unit: :second}

      iex> Periods.convert(%Period{amount: 864000, unit: :second}, :day)
      %Period{amount: 10, unit: :day}

      iex> Periods.convert(%Period{amount: 10, unit: :year}, :month)
      %Periods.Period{amount: 120, unit: :month}

      iex> Periods.convert(%Period{amount: 10, unit: :second}, :week)
      %Periods.Period{amount: 0, unit: :week}

      iex> Periods.convert(%Period{amount: 1000, unit: :second}, :month)
      {:error, :cannot_convert_to_month}
  """
  @spec convert(Period.t(), atom() | String.t()) :: Period.t() | {:error, atom()}
  defdelegate convert(period, unit), to: Conversion

  @doc """
  Returns the value set by your Application environment or the default :second

  ## Examples

      iex> Periods.default_unit()
      :second
  """
  @spec default_unit() :: atom()
  def default_unit, do: Application.get_env(Periods, :default_unit, :second)

  @doc """
  Create a new Period through a variety of input types.

  ## Examples

      iex> Periods.new(%{amount: 100, unit: :second})
      {:ok, %Periods.Period{amount: 100, unit: :second}}

      iex> Periods.new(%{amount: 100, unit: "second"})
      {:ok, %Periods.Period{amount: 100, unit: :second}}

      iex> Periods.new({100, "second"})
      {:ok, %Periods.Period{amount: 100, unit: :second}}

      iex> Periods.new(100)
      {:ok, %Periods.Period{amount: 100, unit: :second}}
  """
  @spec new(parse_type()) :: {:ok, Period.t()} | {:error, Keyword.t()}
  defdelegate new(value), to: Parser

  @doc """
  Subtract a Period from a Time, Date, DateTime, or NaiveDateTime.

  Note: `Months` have limited subtracting properties

  When performing subtraction of periods all values will be converted to the lowest
  unit value. For example if you subtract a Period of days from a Period of seconds then
  the result will be seconds.

  When subtracting a period from an Elixir date/time struct the return will be the Elixir
  date/time struct.

  Note: Since there is conversion involved you may loose fractional values such as
  subtracting 1 millisecond from a Date.

  ## Examples

      iex> Periods.subtract(%Period{amount: 10, unit: :day}, %Period{amount: 1000, unit: :second})
      %Periods.Period{amount: 863000, unit: :second}

      iex> DateTime.utc_now() |> Periods.subtract(%Period{amount: 1000, unit: :second})
      ~U[2023-07-09 14:08:32.916532Z]

      iex> Time.utc_now() |> Periods.subtract(%Period{amount: 1000, unit: :second})
      ~T[14:08:45.831176]

      iex> today = Date.utc_today()
      ~D[2023-07-10]
      iex> Periods.subtract(today, %Period{amount: 10000000000000, unit: :millisecond})
      ~D[1706-08-21]
      iex> Periods.subtract(today, %Period{amount: 3, unit: :year})
      ~D[2020-07-10]
  """
  @spec subtract(computation(), Period.t()) :: computation() | {:error, atom()}
  defdelegate subtract(value_1, value_2), to: Computation

  @doc """
  Returns a list of all the current values Periods supports

  ## Examples

      iex> Periods.all_units()
      [:millisecond, :second, :minute, :hour, :day, :week, :month, :year, :decade]
  """
  @spec all_units() :: list(atom())
  def all_units, do: @units
end
