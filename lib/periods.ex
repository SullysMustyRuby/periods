defmodule Periods do
  @moduledoc """
  Documentation for `Periods`.
  """

  alias Periods.Computation
  alias Periods.Conversion
  alias Periods.Parser

  @units [:millisecond, :second, :minute, :hour, :day, :week, :month, :year, :decade]

  defdelegate add(value_1, value_2), to: Computation

  defdelegate convert(period, unit), to: Conversion

  def default_unit, do: Application.get_env(Periods, :default_unit, :second)

  defdelegate new(value), to: Parser

  defdelegate subtract(value_1, value_2), to: Computation

  def all_units, do: @units
end
