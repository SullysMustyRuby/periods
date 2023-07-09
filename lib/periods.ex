defmodule Periods do
  @moduledoc """
  Documentation for `Periods`.
  """

  alias Periods.Conversion
  alias Periods.Parser

  @units [:milisecond, :second, :minute, :hour, :day, :week, :month, :year, :decade]

  defdelegate convert(period, unit), to: Conversion

  defdelegate new(value), to: Parser

  def all_units, do: @units
end
