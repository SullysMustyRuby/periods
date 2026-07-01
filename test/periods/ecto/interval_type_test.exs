defmodule Periods.Ecto.IntervalTypeTest do
  use ExUnit.Case

  alias Periods.Ecto.IntervalType
  alias Periods.Period

  test "type/0" do
    assert IntervalType.type() == :interval
  end

  describe "cast/1" do
    test "with a map returns ok and a Period" do
      assert IntervalType.cast(%{amount: 100, unit: :day}) ==
               {:ok, %Period{amount: 100, unit: :day}}
    end

    test "with a tuple returns ok and a Period" do
      assert IntervalType.cast({100, :day}) == {:ok, %Period{amount: 100, unit: :day}}
    end

    test "with an integer returns ok and a Period with the default unit" do
      assert IntervalType.cast(100) == {:ok, %Period{amount: 100, unit: :second}}
    end

    test "with an existing Period returns it unchanged" do
      period = %Period{amount: 5, unit: :hour}
      assert IntervalType.cast(period) == {:ok, period}
    end

    test "with an invalid value returns error" do
      assert IntervalType.cast(1.23) == {:error, :amount_must_be_integer}
    end
  end

  describe "dump/1" do
    test "milliseconds split into secs and microsecs" do
      assert IntervalType.dump(%Period{amount: 1500, unit: :millisecond}) ==
               {:ok, %Postgrex.Interval{secs: 1, microsecs: 500_000}}
    end

    test "seconds map to secs" do
      assert IntervalType.dump(%Period{amount: 90, unit: :second}) ==
               {:ok, %Postgrex.Interval{secs: 90}}
    end

    test "minutes and hours map to secs" do
      assert IntervalType.dump(%Period{amount: 2, unit: :minute}) ==
               {:ok, %Postgrex.Interval{secs: 120}}

      assert IntervalType.dump(%Period{amount: 2, unit: :hour}) ==
               {:ok, %Postgrex.Interval{secs: 7_200}}
    end

    test "days and weeks map to days" do
      assert IntervalType.dump(%Period{amount: 10, unit: :day}) ==
               {:ok, %Postgrex.Interval{days: 10}}

      assert IntervalType.dump(%Period{amount: 2, unit: :week}) ==
               {:ok, %Postgrex.Interval{days: 14}}
    end

    test "months, years, and decades map to months" do
      assert IntervalType.dump(%Period{amount: 3, unit: :month}) ==
               {:ok, %Postgrex.Interval{months: 3}}

      assert IntervalType.dump(%Period{amount: 2, unit: :year}) ==
               {:ok, %Postgrex.Interval{months: 24}}

      assert IntervalType.dump(%Period{amount: 1, unit: :decade}) ==
               {:ok, %Postgrex.Interval{months: 120}}
    end

    test "with an invalid value returns error" do
      assert IntervalType.dump([]) == :error
    end
  end

  describe "load/1" do
    test "months-only interval loads as a month Period" do
      assert IntervalType.load(%Postgrex.Interval{months: 5}) ==
               {:ok, %Period{amount: 5, unit: :month}}
    end

    test "days-only interval loads as a day Period" do
      assert IntervalType.load(%Postgrex.Interval{days: 10}) ==
               {:ok, %Period{amount: 10, unit: :day}}
    end

    test "seconds (with days) load as a second Period" do
      assert IntervalType.load(%Postgrex.Interval{days: 1, secs: 30}) ==
               {:ok, %Period{amount: 86_430, unit: :second}}
    end

    test "sub-second precision loads as a millisecond Period" do
      assert IntervalType.load(%Postgrex.Interval{secs: 1, microsecs: 500_000}) ==
               {:ok, %Period{amount: 1500, unit: :millisecond}}
    end

    test "an empty interval loads as a zero Period in the default unit" do
      assert IntervalType.load(%Postgrex.Interval{}) ==
               {:ok, %Period{amount: 0, unit: :second}}
    end

    test "a mixed month-and-time interval cannot be a single Period and returns error" do
      assert IntervalType.load(%Postgrex.Interval{months: 1, days: 5}) == :error
      assert IntervalType.load(%Postgrex.Interval{months: 1, secs: 30}) == :error
    end

    test "with an invalid value returns error" do
      assert IntervalType.load(%{}) == :error
    end
  end

  describe "round trip" do
    test "single-unit Periods survive dump then load (normalized to bucket unit)" do
      for {period, expected} <- [
            {%Period{amount: 90, unit: :second}, %Period{amount: 90, unit: :second}},
            {%Period{amount: 10, unit: :day}, %Period{amount: 10, unit: :day}},
            {%Period{amount: 3, unit: :month}, %Period{amount: 3, unit: :month}}
          ] do
        {:ok, interval} = IntervalType.dump(period)
        assert IntervalType.load(interval) == {:ok, expected}
      end
    end
  end
end
