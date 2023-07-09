defmodule ComputationTest do
  use ExUnit.Case

  alias Periods.Computation
  alias Periods.Period

  describe "add/2" do
    test "with the same unit returns the total" do
      {:ok, period_1} = Periods.new(100)
      {:ok, period_2} = Periods.new(300)
      assert %Period{amount: 400, unit: :second} == Computation.add(period_1, period_2)
    end

    test "with different units returns the lowest unit" do
      {:ok, period_1} = Periods.new({10, :day})
      {:ok, period_2} = Periods.new({300, :hour})

      assert %Period{amount: 540, unit: :hour} == Computation.add(period_1, period_2)
    end

    test "month addition restrictions returns error" do
      for bad_unit <- [:millisecond, :second, :minute, :hour, :week] do
        {:ok, period_1} = Periods.new({100, bad_unit})
        {:ok, period_2} = Periods.new({300, :month})

        assert {:error, :invalid_month_addition} == Computation.add(period_1, period_2)
      end
    end

    test "adds months with years" do
      {:ok, period_1} = Periods.new({2, :year})
      {:ok, period_2} = Periods.new({10, :month})
      assert %Period{amount: 34, unit: :month} == Computation.add(period_1, period_2)
    end

    test "adds months with decades" do
      {:ok, period_1} = Periods.new({2, :decade})
      {:ok, period_2} = Periods.new({10, :month})
      assert %Period{amount: 250, unit: :month} == Computation.add(period_1, period_2)
    end
  end

  describe "subtract/2" do
    test "with the same unit returns the total" do
      {:ok, period_1} = Periods.new(300)
      {:ok, period_2} = Periods.new(100)

      assert %Period{amount: 200, unit: :second} == Computation.subtract(period_1, period_2)
    end

    test "with the same unit allows a negative total" do
      {:ok, period_1} = Periods.new(100)
      {:ok, period_2} = Periods.new(400)

      assert %Period{amount: -300, unit: :second} == Computation.subtract(period_1, period_2)
    end

    test "month subtraction restrictions returns error" do
      for bad_unit <- [:millisecond, :second, :minute, :hour, :week] do
        {:ok, period_1} = Periods.new({100, bad_unit})
        {:ok, period_2} = Periods.new({300, :month})

        assert {:error, :invalid_month_subtraction} == Computation.subtract(period_1, period_2)
      end
    end

    test "subtracts months with years" do
      {:ok, period_1} = Periods.new({2, :year})
      {:ok, period_2} = Periods.new({10, :month})
      assert %Period{amount: 14, unit: :month} == Computation.subtract(period_1, period_2)
    end

    test "subtracts months with decades" do
      {:ok, period_1} = Periods.new({2, :decade})
      {:ok, period_2} = Periods.new({10, :month})
      assert %Period{amount: 230, unit: :month} == Computation.subtract(period_1, period_2)
    end
  end
end
