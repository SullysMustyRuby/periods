defmodule Periods.PeriodTest do
  use ExUnit.Case

  alias Periods.Period

  describe "Inspect" do
    test "renders a compact, unambiguous representation" do
      assert inspect(%Period{amount: 10, unit: :day}) == "#Periods.Period<10 day>"
    end

    test "renders negative amounts" do
      assert inspect(%Period{amount: -5, unit: :second}) == "#Periods.Period<-5 second>"
    end
  end

  describe "String.Chars" do
    test "interpolates a pluralized amount" do
      assert "#{%Period{amount: 10, unit: :day}}" == "10 days"
    end

    test "interpolates a singular amount" do
      assert "#{%Period{amount: 1, unit: :day}}" == "1 day"
    end

    test "to_string/1 returns the same string" do
      assert to_string(%Period{amount: 3, unit: :hour}) == "3 hours"
    end
  end
end
