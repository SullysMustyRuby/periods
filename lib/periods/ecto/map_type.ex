if Code.ensure_loaded?(Ecto.Type) do
  defmodule Periods.Ecto.MapType do
    @moduledoc """
    Provides a type for Ecto to store a Period of time.
    The underlying data type should be a map(JSON).
    Suitable for databases that do not support composite types,
    but support JSON (e.g. MySQL and versions of CockroachDB).

    ## Migration

        create table(:timers) do
          add :timer_period, :map
        end

    ## Schema

        schema "timers" do
          field :timer_period, Periods.Ecto.MapType
        end

    """

    alias Periods.Period

    if macro_exported?(Ecto.Type, :__using__, 1) do
      use Ecto.Type
    else
      @behaviour Ecto.Type
    end

    defdelegate cast(value), to: Periods, as: :new

    @spec type() :: :map
    def type, do: :map

    def embed_as(_), do: :dump

    @spec dump(any()) :: :error | {:ok, %{String.t() => String.t() | integer()}}
    def dump(%Period{} = period) do
      {:ok, %{"amount" => period.amount, "unit" => Atom.to_string(period.unit)}}
    end

    def dump(_), do: :error

    @spec load(map()) :: {:ok, Period.t()}
    def load(%{"amount" => amount, "unit" => unit}) do
      Periods.new({amount, unit})
    end
  end
end
