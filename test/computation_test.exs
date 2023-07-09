defmodule ComputationTest do
  use ExUnit.Case

  alias Periods.Computation
  alias Periods.Period

  describe "add/2" do
    test "periods: with the same unit returns the total" do
      {:ok, period_1} = Periods.new(100)
      {:ok, period_2} = Periods.new(300)
      assert %Period{amount: 400, unit: :second} == Computation.add(period_1, period_2)
    end

    @tag :skip
    test "with different units returns the lowest unit" do
      {:ok, period_1} = Periods.new({10, :day})
      {:ok, period_2} = Periods.new({300, :hour})

      assert %Period{amount: 540, unit: :hour} == Computation.add(period_1, period_2)
    end
  end
end
