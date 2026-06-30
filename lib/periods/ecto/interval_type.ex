if Code.ensure_loaded?(Ecto.Type) and Code.ensure_loaded?(Postgrex.Interval) do
  defmodule Periods.Ecto.IntervalType do
    @moduledoc """
    Provides a type for Ecto to store a Period using the native PostgreSQL
    `interval` type (via `Postgrex.Interval`).

    Use this when you want intervals you can operate on inside the database
    (`now() + duration`, ordering, `EXTRACT`, etc). If you only need to round-trip
    a Period without database-side date math, `Periods.Ecto.MapType` preserves the
    original unit exactly and works on any JSON-capable database.

    ## Migration

        create table(:timers) do
          add :timer_period, :interval
        end

    ## Schema

        schema "timers" do
          field :timer_period, Periods.Ecto.IntervalType
        end

    ## Normalization on load

    A native `interval` has only three buckets: `months`, `days`, and microseconds.
    It cannot record whether a value was originally a `:week` or seven `:day`s, so the
    unit label does not always round-trip. On `dump` a Period maps to a single bucket;
    on `load` the interval is normalized back to a single Period:

      - months only -> `:month`
      - days (+ time) -> `:day` or, when seconds/microseconds are present, `:second`/`:millisecond`
      - time only -> `:second`, or `:millisecond` when sub-second precision exists

    Because `:month` cannot be converted to a fixed number of smaller units, an interval
    that mixes `months` with `days`/seconds (e.g. `1 mon 5 days`) cannot be represented
    as a single Period and `load` returns `:error`. If you store mixed intervals from
    outside this library, use `Periods.Ecto.MapType` instead.
    """

    alias Periods.Period

    if macro_exported?(Ecto.Type, :__using__, 1) do
      use Ecto.Type
    else
      @behaviour Ecto.Type
    end

    def cast(%Period{} = period), do: {:ok, period}

    def cast(value), do: Periods.new(value)

    @spec dump(any()) :: :error | {:ok, Postgrex.Interval.t()}
    def dump(%Period{amount: amount, unit: :millisecond}) do
      {:ok, %Postgrex.Interval{secs: div(amount, 1000), microsecs: rem(amount, 1000) * 1000}}
    end

    def dump(%Period{amount: amount, unit: :second}) do
      {:ok, %Postgrex.Interval{secs: amount}}
    end

    def dump(%Period{amount: amount, unit: :minute}) do
      {:ok, %Postgrex.Interval{secs: amount * 60}}
    end

    def dump(%Period{amount: amount, unit: :hour}) do
      {:ok, %Postgrex.Interval{secs: amount * 3_600}}
    end

    def dump(%Period{amount: amount, unit: :day}) do
      {:ok, %Postgrex.Interval{days: amount}}
    end

    def dump(%Period{amount: amount, unit: :week}) do
      {:ok, %Postgrex.Interval{days: amount * 7}}
    end

    def dump(%Period{amount: amount, unit: :month}) do
      {:ok, %Postgrex.Interval{months: amount}}
    end

    def dump(%Period{amount: amount, unit: :year}) do
      {:ok, %Postgrex.Interval{months: amount * 12}}
    end

    def dump(%Period{amount: amount, unit: :decade}) do
      {:ok, %Postgrex.Interval{months: amount * 120}}
    end

    def dump(_), do: :error

    def embed_as(_), do: :dump

    @spec load(any()) :: :error | {:ok, Period.t()}
    def load(%Postgrex.Interval{months: months, days: days, secs: secs, microsecs: microsecs}) do
      to_period(months, days, secs, microsecs)
    end

    def load(_), do: :error

    @spec type() :: :interval
    def type, do: :interval

    defp to_period(months, days, secs, microsecs)
         when months != 0 and (days != 0 or secs != 0 or microsecs != 0) do
      :error
    end

    defp to_period(months, 0, 0, 0) when months != 0 do
      {:ok, %Period{amount: months, unit: :month}}
    end

    defp to_period(0, days, secs, microsecs) when microsecs != 0 do
      amount = days * 86_400_000 + secs * 1000 + div(microsecs, 1000)
      {:ok, %Period{amount: amount, unit: :millisecond}}
    end

    defp to_period(0, days, secs, 0) when secs != 0 do
      {:ok, %Period{amount: days * 86_400 + secs, unit: :second}}
    end

    defp to_period(0, days, 0, 0) when days != 0 do
      {:ok, %Period{amount: days, unit: :day}}
    end

    defp to_period(0, 0, 0, 0) do
      {:ok, %Period{amount: 0, unit: Periods.default_unit()}}
    end
  end
end
