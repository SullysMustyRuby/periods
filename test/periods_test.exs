defmodule PeriodsTest do
  use ExUnit.Case, async: false

  describe "all_units/0" do
    test "returns all the units registered" do
      assert Periods.all_units() == [
               :millisecond,
               :second,
               :minute,
               :hour,
               :day,
               :week,
               :month,
               :year,
               :decade
             ]
    end
  end

  describe "default_unit/0" do
    test "returns the application set default" do
      Application.put_env(Periods, :default_unit, :day)
      assert :day == Periods.default_unit()
      Application.delete_env(Periods, :default_unit)
    end

    test "with no default set returns seconds" do
      assert nil == Application.get_env(Periods, :default_unit)
      assert :second == Periods.default_unit()
    end
  end
end
