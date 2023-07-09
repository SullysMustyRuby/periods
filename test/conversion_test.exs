defmodule ConversionTest do
  use ExUnit.Case

  alias Periods.Conversion

  describe "convert/2" do
    test "a period with same unit returns the period" do
      {:ok, period} = Periods.new({100, :day})
      assert period == Conversion.convert(period, :day)
    end

    test "when the new unit is binary parses and converts" do
      {:ok, period} = Periods.new({100, "day"})
      assert period == Conversion.convert(period, :day)
    end

    test "when the new unit is invalid returns error" do
      for bad_unit <- [2, 1.23, "decimal", :decimal, %{}, [], {}] do
        {:ok, period} = Periods.new({100, :day})
        {:error, message} = Conversion.convert(period, bad_unit)
        assert message == :bad_unit_type
      end
    end

    test "with invalid arguments returns error tuple" do
      for bad_period <- [2, 1.23, "decimal", :decimal, %{}, [], {}] do
        assert {:error, :invalid_arguments} == Conversion.convert(bad_period, :second)
      end
    end

    test "millisecond: converts to second" do
      amount = 10 * 1000
      {:ok, period} = Periods.new({amount, :millisecond})
      period = Conversion.convert(period, :second)
      assert period.amount == 10
      assert period.unit == :second
    end

    test "millisecond: converts to minute" do
      amount = 15 * 60 * 1000
      {:ok, period} = Periods.new({amount, :millisecond})
      period = Conversion.convert(period, :minute)
      assert period.amount == 15
      assert period.unit == :minute
    end

    test "millisecond: converts to hour" do
      amount = 2 * 60 * 60 * 1000
      {:ok, period} = Periods.new({amount, :millisecond})
      period = Conversion.convert(period, :hour)
      assert period.amount == 2
      assert period.unit == :hour
    end

    test "millisecond: converts to day" do
      amount = 5 * 24 * 60 * 60 * 1000
      {:ok, period} = Periods.new({amount, :millisecond})
      period = Conversion.convert(period, :day)
      assert period.amount == 5
      assert period.unit == :day
    end

    test "millisecond: converts to week" do
      amount = 2 * 7 * 24 * 60 * 60 * 1000
      {:ok, period} = Periods.new({amount, :millisecond})
      period = Conversion.convert(period, :week)
      assert period.amount == 2
      assert period.unit == :week
    end

    test "millisecond: converts to year" do
      amount = 2 * 365 * 24 * 60 * 60 * 1000
      {:ok, period} = Periods.new({amount, :millisecond})
      period = Conversion.convert(period, :year)
      assert period.amount == 2
      assert period.unit == :year
    end

    test "millisecond: converts to decade" do
      amount = 2 * 10 * 365 * 24 * 60 * 60 * 1000
      {:ok, period} = Periods.new({amount, :millisecond})
      period = Conversion.convert(period, :decade)
      assert period.amount == 2
      assert period.unit == :decade
    end

    test "second: converts to millisecond" do
      {:ok, period} = Periods.new({10, :second})
      period = Conversion.convert(period, :millisecond)
      assert period.amount == 10 * 1000
      assert period.unit == :millisecond
    end

    test "second: converts to minute" do
      amount = 15 * 60
      {:ok, period} = Periods.new({amount, :second})
      period = Conversion.convert(period, :minute)
      assert period.amount == 15
      assert period.unit == :minute
    end

    test "second: converts to hour" do
      amount = 2 * 60 * 60
      {:ok, period} = Periods.new({amount, :second})
      period = Conversion.convert(period, :hour)
      assert period.amount == 2
      assert period.unit == :hour
    end

    test "second: converts to day" do
      amount = 5 * 24 * 60 * 60
      {:ok, period} = Periods.new({amount, :second})
      period = Conversion.convert(period, :day)
      assert period.amount == 5
      assert period.unit == :day
    end

    test "second: converts to week" do
      amount = 2 * 7 * 24 * 60 * 60
      {:ok, period} = Periods.new({amount, :second})
      period = Conversion.convert(period, :week)
      assert period.amount == 2
      assert period.unit == :week
    end

    test "second: converts to year" do
      amount = 2 * 365 * 24 * 60 * 60
      {:ok, period} = Periods.new({amount, :second})
      period = Conversion.convert(period, :year)
      assert period.amount == 2
      assert period.unit == :year
    end

    test "second: converts to decade" do
      amount = 2 * 10 * 365 * 24 * 60 * 60
      {:ok, period} = Periods.new({amount, :second})
      period = Conversion.convert(period, :decade)
      assert period.amount == 2
      assert period.unit == :decade
    end

    test "minute: converts to millisecond" do
      {:ok, period} = Periods.new({10, :minute})
      period = Conversion.convert(period, :millisecond)
      assert period.amount == 10 * 60 * 1000
      assert period.unit == :millisecond
    end

    test "minute: converts to second" do
      {:ok, period} = Periods.new({15, :minute})
      period = Conversion.convert(period, :second)
      assert period.amount == 15 * 60
      assert period.unit == :minute
    end

    test "minute: converts to hour" do
      amount = 2 * 60
      {:ok, period} = Periods.new({amount, :minute})
      period = Conversion.convert(period, :hour)
      assert period.amount == 2
      assert period.unit == :hour
    end

    test "minute: converts to day" do
      amount = 5 * 24 * 60
      {:ok, period} = Periods.new({amount, :minute})
      period = Conversion.convert(period, :day)
      assert period.amount == 5
      assert period.unit == :day
    end

    test "minute: converts to week" do
      amount = 2 * 7 * 24 * 60
      {:ok, period} = Periods.new({amount, :minute})
      period = Conversion.convert(period, :week)
      assert period.amount == 2
      assert period.unit == :week
    end

    test "minute: converts to year" do
      amount = 2 * 365 * 24 * 60
      {:ok, period} = Periods.new({amount, :minute})
      period = Conversion.convert(period, :year)
      assert period.amount == 2
      assert period.unit == :year
    end

    test "minute: converts to decade" do
      amount = 2 * 10 * 365 * 24 * 60
      {:ok, period} = Periods.new({amount, :minute})
      period = Conversion.convert(period, :decade)
      assert period.amount == 2
      assert period.unit == :decade
    end

    test "hour: converts to millisecond" do
      {:ok, period} = Periods.new({15, :hour})
      period = Conversion.convert(period, :millisecond)
      assert period.amount == 15 * 60 * 60 * 1000
      assert period.unit == :millisecond
    end

    test "hour: converts to second" do
      {:ok, period} = Periods.new({2, :hour})
      period = Conversion.convert(period, :second)
      assert period.amount == 2 * 60 * 60
      assert period.unit == :second
    end

    test "hour: converts to minute" do
      {:ok, period} = Periods.new({2, :hour})
      period = Conversion.convert(period, :minute)
      assert period.amount == 2 * 60
      assert period.unit == :minute
    end

    test "hour: converts to day" do
      amount = 5 * 24
      {:ok, period} = Periods.new({amount, :hour})
      period = Conversion.convert(period, :day)
      assert period.amount == 5
      assert period.unit == :day
    end

    test "hour: converts to week" do
      amount = 2 * 7 * 24
      {:ok, period} = Periods.new({amount, :hour})
      period = Conversion.convert(period, :week)
      assert period.amount == 2
      assert period.unit == :week
    end

    test "hour: converts to year" do
      amount = 2 * 365 * 24
      {:ok, period} = Periods.new({amount, :hour})
      period = Conversion.convert(period, :year)
      assert period.amount == 2
      assert period.unit == :year
    end

    test "hour: converts to decade" do
      amount = 2 * 10 * 365 * 24
      {:ok, period} = Periods.new({amount, :hour})
      period = Conversion.convert(period, :decade)
      assert period.amount == 2
      assert period.unit == :decade
    end

    test "day: converts to millisecond" do
      {:ok, period} = Periods.new({15, :day})
      period = Conversion.convert(period, :millisecond)
      assert period.amount == 15 * 24 * 60 * 60 * 1000
      assert period.unit == :millisecond
    end

    test "day: converts to second" do
      {:ok, period} = Periods.new({2, :day})
      period = Conversion.convert(period, :second)
      assert period.amount == 2 * 24 * 60 * 60
      assert period.unit == :second
    end

    test "day: converts to minute" do
      {:ok, period} = Periods.new({2, :day})
      period = Conversion.convert(period, :minute)
      assert period.amount == 2 * 24 * 60
      assert period.unit == :minute
    end

    test "day: converts to hour" do
      {:ok, period} = Periods.new({5, :day})
      period = Conversion.convert(period, :hour)
      assert period.amount == 5 * 24
      assert period.unit == :hour
    end

    test "day: converts to week" do
      amount = 2 * 7
      {:ok, period} = Periods.new({amount, :day})
      period = Conversion.convert(period, :week)
      assert period.amount == 2
      assert period.unit == :week
    end

    test "day: converts to year" do
      amount = 2 * 365
      {:ok, period} = Periods.new({amount, :day})
      period = Conversion.convert(period, :year)
      assert period.amount == 2
      assert period.unit == :year
    end

    test "day: converts to decade" do
      amount = 2 * 10 * 365
      {:ok, period} = Periods.new({amount, :day})
      period = Conversion.convert(period, :decade)
      assert period.amount == 2
      assert period.unit == :decade
    end

    test "week: converts to millisecond" do
      {:ok, period} = Periods.new({15, :week})
      period = Conversion.convert(period, :millisecond)
      assert period.amount == 15 * 7 * 24 * 60 * 60 * 1000
      assert period.unit == :millisecond
    end

    test "week: converts to second" do
      {:ok, period} = Periods.new({2, :week})
      period = Conversion.convert(period, :second)
      assert period.amount == 2 * 7 * 24 * 60 * 60
      assert period.unit == :second
    end

    test "week: converts to minute" do
      {:ok, period} = Periods.new({2, :week})
      period = Conversion.convert(period, :minute)
      assert period.amount == 2 * 7 * 24 * 60
      assert period.unit == :minute
    end

    test "week: converts to hour" do
      {:ok, period} = Periods.new({5, :week})
      period = Conversion.convert(period, :hour)
      assert period.amount == 5 * 7 * 24
      assert period.unit == :hour
    end

    test "week: converts to day" do
      {:ok, period} = Periods.new({2, :week})
      period = Conversion.convert(period, :day)
      assert period.amount == 2 * 7
      assert period.unit == :week
    end

    test "week: converts to year" do
      amount = 2 * 52
      {:ok, period} = Periods.new({amount, :week})
      period = Conversion.convert(period, :year)
      assert period.amount == 2
      assert period.unit == :year
    end

    test "week: converts to decade" do
      amount = 2 * 10 * 52
      {:ok, period} = Periods.new({amount, :week})
      period = Conversion.convert(period, :decade)
      assert period.amount == 2
      assert period.unit == :decade
    end

    test "month: returns error for milliseconds" do
      {:ok, period} = Periods.new({10 * 24 * 60 * 60 * 1000, :millisecond})
      assert {:error, :cannot_convert_to_month} = Conversion.convert(period, :month)
    end

    test "month: returns error for seconds" do
      {:ok, period} = Periods.new({100 * 24 * 60 * 60, :second})
      assert {:error, :cannot_convert_to_month} = Conversion.convert(period, :month)
    end

    test "month: returns error for minute" do
      {:ok, period} = Periods.new({100 * 60 * 60, :minute})
      assert {:error, :cannot_convert_to_month} = Conversion.convert(period, :month)
    end

    test "month: returns error for hour" do
      {:ok, period} = Periods.new({100 * 60, :hour})
      assert {:error, :cannot_convert_to_month} = Conversion.convert(period, :month)
    end

    test "month: converts to year" do
      amount = 2 * 12
      {:ok, period} = Periods.new({amount, :month})
      period = Conversion.convert(period, :year)
      assert period.amount == 2
      assert period.unit == :year
    end

    test "month: converts to decade" do
      amount = 2 * 10 * 12
      {:ok, period} = Periods.new({amount, :month})
      period = Conversion.convert(period, :decade)
      assert period.amount == 2
      assert period.unit == :decade
    end

    test "year: converts to millisecond" do
      {:ok, period} = Periods.new({2, :year})
      period = Conversion.convert(period, :millisecond)
      assert period.amount == 2 * 365 * 24 * 60 * 60 * 1000
      assert period.unit == :millisecond
    end

    test "year: converts to second" do
      {:ok, period} = Periods.new({2, :year})
      period = Conversion.convert(period, :second)
      assert period.amount == 2 * 365 * 24 * 60 * 60
      assert period.unit == :second
    end

    test "year: converts to minute" do
      {:ok, period} = Periods.new({2, :year})
      period = Conversion.convert(period, :minute)
      assert period.amount == 2 * 365 * 24 * 60
      assert period.unit == :minute
    end

    test "year: converts to hour" do
      {:ok, period} = Periods.new({5, :year})
      period = Conversion.convert(period, :hour)
      assert period.amount == 5 * 365 * 24
      assert period.unit == :hour
    end

    test "year: converts to day" do
      {:ok, period} = Periods.new({2, :year})
      period = Conversion.convert(period, :day)
      assert period.amount == 2 * 365
      assert period.unit == :day
    end

    test "year: converts to week" do
      {:ok, period} = Periods.new({2, :year})
      period = Conversion.convert(period, :week)
      assert period.amount == 2 * 52
      assert period.unit == :week
    end

    test "year: converts to decade" do
      amount = 2 * 10
      {:ok, period} = Periods.new({amount, :year})
      period = Conversion.convert(period, :decade)
      assert period.amount == 2
      assert period.unit == :decade
    end

    test "decade: converts to millisecond" do
      {:ok, period} = Periods.new({2, :decade})
      period = Conversion.convert(period, :millisecond)
      assert period.amount == 2 * 10 * 365 * 24 * 60 * 60 * 1000
      assert period.unit == :millisecond
    end

    test "decade: converts to second" do
      {:ok, period} = Periods.new({2, :decade})
      period = Conversion.convert(period, :second)
      assert period.amount == 2 * 10 * 365 * 24 * 60 * 60
      assert period.unit == :second
    end

    test "decade: converts to minute" do
      {:ok, period} = Periods.new({2, :decade})
      period = Conversion.convert(period, :minute)
      assert period.amount == 2 * 10 * 365 * 24 * 60
      assert period.unit == :minute
    end

    test "decade: converts to hour" do
      {:ok, period} = Periods.new({5, :decade})
      period = Conversion.convert(period, :hour)
      assert period.amount == 5 * 10 * 365 * 24
      assert period.unit == :hour
    end

    test "decade: converts to day" do
      {:ok, period} = Periods.new({2, :decade})
      period = Conversion.convert(period, :day)
      assert period.amount == 2 * 10 * 365
      assert period.unit == :day
    end

    test "decade: converts to week" do
      {:ok, period} = Periods.new({2, :decade})
      period = Conversion.convert(period, :week)
      assert period.amount == 2 * 10 * 52
      assert period.unit == :week
    end

    test "decade: converts to year" do
      {:ok, period} = Periods.new({2, :decade})
      period = Conversion.convert(period, :year)
      assert period.amount == 2 * 10
      assert period.unit == :year
    end
  end
end
