# Periods
A helper for converting and performing math operations on values of Time, Date, DateTime, and NaiveDateTime along with storing in database with Ecto.Type.

Periods are designed to represent fractions of time from milliseconds to decades
in order to help make working with various time based structs easier.

Periods can be converted, added, and subtracted,

By default the base value is a `second` you can choose a different base for your
application by setting the `:default_value` in you Application config.

The only limitation are months. Due to the inconsistency of a period of a month from 28-31
days conversion and mathematical operations are limited.

Thank you to all the people working on Money and Ecto. Those projects inspired parts of this design.

## Examples
```elixir
  # Create a new Period
  iex> Periods.new({1000, :day})
  {:ok, %Periods.Period{amount: 1000, unit: :day}}

  # Convert from one unit to another easily
  iex> Periods.convert(%Period{amount: 10, unit: :day}, :second)
  %Periods.Period{amount: 864000, unit: :second}

  # Addition of periods to Time, Date, DateTime, and NaiveDateTime along with other Periods
  # Note will convert to lowest unit.
  iex> Periods.add(%Period{amount: 100, unit: :day}, %Period{amount: 1000, unit: :second})
  %Periods.Period{amount: 8641000, unit: :second}

  iex> DateTime.utc_now() |> Periods.add(%Period{amount: 100, unit: :day})
  ~U[2023-10-18 02:15:58.766819Z]

  # Subtraction of Periods from Time, Date, DateTime, and NaiveDateTime along with other Periods
  # Note here Date only accepts days for add/subtract thus Period auto converts.
  iex> today = Date.utc_today()
  ~D[2023-07-10]
  iex> Periods.subtract(today, %Period{amount: 1, unit: :millisecond})
  ~D[2023-07-10]

```
## Ecto Type
For easy database storage and application use.
```elixir
  # Migration
  create table(:timers) do
    add :timer_period, :map
  end

  # In Module Schema
  schema "timers" do
    field :timer_period, Periods.Ecto.MapType
  end
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `periods` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:periods, "~> 0.0.2"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/periods>.

