defmodule Periods do
  @moduledoc """
  Documentation for `Periods`.
  """

  alias Periods.Parser

  @units [:milisecond, :second, :minute, :hour, :day, :week, :month, :year, :decade]

  defdelegate new(value), to: Parser

  def all_units, do: @units
end
