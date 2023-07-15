defmodule Periods.FormatterTest do
  use ExUnit.Case

  alias Periods.Formatter

  describe "to_integer/2" do
    test "when given a period without a conversion outputs an integer" do
      {:ok, period} = Periods.new({1000, :hour})
      assert Periods.to_integer(period) == 1000
    end

    test "when given a period with a conversion outputs an integer in converted unit" do
      {:ok, period} = Periods.new({1000, :hour})
      assert Periods.to_integer(period, :second) == 3_600_000
    end

    test "when given a period with a conversion with an invalid unit returns error" do
      {:ok, period} = Periods.new({1000, :hour})
      assert Periods.to_integer(period, :month) == {:error, {:cannot_convert_to_month, :hour}}
    end
  end

  describe "to_string/2" do
    test "when given a period without a conversion outputs string" do
      {:ok, period} = Periods.new({1000, :hour})
      assert Formatter.to_string(period) == "1000 hours"
    end

    test "when given a period with a conversion outputs a string in converted unit" do
      {:ok, period} = Periods.new({1000, :hour})
      assert Periods.to_string(period, :second) == "3600000 seconds"
    end

    test "when conversion results a single unit returns singular unit" do
      {:ok, period} = Periods.new({60, :second})
      assert Periods.to_string(period, :minute) == "1 minute"

      {:ok, period} = Periods.new({60, :minute})
      assert Periods.to_string(period, :hour) == "1 hour"

      {:ok, period} = Periods.new({365, :day})
      assert Periods.to_string(period, :year) == "1 year"
    end

    test "when given a period with a conversion with an invalid unit returns error" do
      {:ok, period} = Periods.new({1000, :hour})
      assert Periods.to_string(period, :month) == {:error, {:cannot_convert_to_month, :hour}}
    end
  end
end
