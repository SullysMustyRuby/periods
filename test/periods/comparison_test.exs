defmodule Periods.ComparisonTest do
  use ExUnit.Case

  alias Periods.Comparison

  describe "compare/2" do
    test "same unit: returns :lt when the first is smaller" do
      {:ok, period_1} = Periods.new({100, :second})
      {:ok, period_2} = Periods.new({300, :second})
      assert Comparison.compare(period_1, period_2) == :lt
    end

    test "same unit: returns :gt when the first is larger" do
      {:ok, period_1} = Periods.new({300, :second})
      {:ok, period_2} = Periods.new({100, :second})
      assert Comparison.compare(period_1, period_2) == :gt
    end

    test "same unit: returns :eq when equal" do
      {:ok, period_1} = Periods.new({100, :second})
      {:ok, period_2} = Periods.new({100, :second})
      assert Comparison.compare(period_1, period_2) == :eq
    end

    test "different units: converts to the lowest common unit before comparing" do
      {:ok, day} = Periods.new({1, :day})
      {:ok, second} = Periods.new({1000, :second})
      assert Comparison.compare(day, second) == :gt
      assert Comparison.compare(second, day) == :lt
    end

    test "different units: returns :eq across equivalent magnitudes" do
      {:ok, minute} = Periods.new({1, :minute})
      {:ok, second} = Periods.new({60, :second})
      assert Comparison.compare(minute, second) == :eq
    end

    test "compares months with years" do
      {:ok, year} = Periods.new({1, :year})
      {:ok, month} = Periods.new({13, :month})
      assert Comparison.compare(year, month) == :lt
    end

    test "returns error when a month cannot be compared with a smaller unit" do
      {:ok, month} = Periods.new({1, :month})
      {:ok, second} = Periods.new({1, :second})
      assert Comparison.compare(second, month) == {:error, :invalid_unit_type}
    end

    test "is usable as an Enum.sort/2 sorter" do
      {:ok, day} = Periods.new({1, :day})
      {:ok, hour} = Periods.new({5, :hour})
      {:ok, second} = Periods.new({1000, :second})

      assert Enum.sort([day, second, hour], Comparison) == [second, hour, day]
    end

    test "returns error for non-Period arguments" do
      assert Comparison.compare(:foo, :bar) == {:error, :invalid_arguments}
    end
  end
end
