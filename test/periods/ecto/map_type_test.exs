defmodule Periods.Ecto.MapTypeTest do
  use ExUnit.Case

  alias Periods.Ecto.MapType
  alias Periods.Period

  test "type/0" do
    assert MapType.type() == :map
  end

  describe "cast/1" do
    test "with a map returns ok and a Period" do
      assert MapType.cast(%{amount: 100, unit: :day}) ==
               {:ok, %Periods.Period{amount: 100, unit: :day}}
    end

    test "with a tuple returns ok and a Period" do
      assert MapType.cast({100, :day}) == {:ok, %Period{amount: 100, unit: :day}}
    end

    test "with an integer returns ok and a Period with default seconds" do
      assert MapType.cast(100) == {:ok, %Period{amount: 100, unit: :second}}
    end

    test "with an invalid value returns error" do
      assert MapType.cast(1.23) == {:error, [amount: "must be an integer"]}
    end
  end

  describe "load/1" do
    test "load/1 map with integer amount" do
      assert MapType.load(%{"amount" => 100, "unit" => "hour"}) ==
               {:ok, %Period{amount: 100, unit: :hour}}
    end

    test "load/1 map with binary amount" do
      assert MapType.load(%{"amount" => "100", "unit" => "hour"}) ==
               {:ok, %Period{amount: 100, unit: :hour}}
    end
  end

  describe "dump/1" do
    test "converts into proper map" do
      assert MapType.dump(%Period{amount: 100, unit: :week}) ==
               {:ok, %{"amount" => 100, "unit" => "week"}}
    end

    test "dump/1 other" do
      assert MapType.dump([]) == :error
    end
  end
end
