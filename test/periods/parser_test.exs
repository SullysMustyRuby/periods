defmodule Periods.ParserTest do
  use ExUnit.Case, async: false
  # doctest Periods

  alias Periods.Period

  describe "new/1" do
    test "map: with an integer amount and proper unit returns a struct" do
      assert {:ok, %Period{amount: 100, unit: :day}} == Periods.new(%{amount: 100, unit: :day})
    end

    test "map: with an binary amount and proper unit returns a struct" do
      assert {:ok, %Period{amount: 100, unit: :day}} == Periods.new(%{amount: "100", unit: :day})
    end

    test "map: with an invalid amount returns error" do
      for bad_amount <- [1.23, "1.23", %{}, [], {}] do
        {:error, message} = Periods.new(%{amount: bad_amount, unit: :second})
        assert message == [amount: "must be an integer"]
      end
    end

    test "map: with a binary unit parses into proper unit" do
      assert {:ok, %Period{amount: 100, unit: :day}} == Periods.new(%{amount: "100", unit: "day"})
    end

    test "map: with invalid unit returns error" do
      for bad_unit <- [2, 1.23, "decimal", :decimal, %{}, [], {}] do
        {:error, message} = Periods.new(%{amount: 1, unit: bad_unit})
        assert message == [unit: "bad type"]
      end
    end

    test "tuple: with an integer amount and proper unit returns a struct" do
      assert {:ok, %Period{amount: 100, unit: :day}} == Periods.new({100, :day})
    end

    test "tuple: with an binary amount and proper unit returns a struct" do
      assert {:ok, %Period{amount: 100, unit: :day}} == Periods.new({"100", :day})
    end

    test "tuple: with an invalid amount returns error" do
      for bad_amount <- [1.23, "1.23", %{}, [], {}] do
        {:error, message} = Periods.new({bad_amount, :day})
        assert message == [amount: "must be an integer"]
      end
    end

    test "tuple: with a binary unit parses into proper unit" do
      assert {:ok, %Period{amount: 100, unit: :day}} == Periods.new({"100", "day"})
    end

    test "tuple: with invalid unit returns error" do
      for bad_unit <- [2, 1.23, "decimal", :decimal, %{}, [], {}] do
        {:error, message} = Periods.new({1, bad_unit})
        assert message == [unit: "bad type"]
      end
    end

    test "amount: with valid integer sets default unit" do
      assert {:ok, %Period{amount: 100, unit: :second}} == Periods.new(100)
    end

    test "amount: with binary integer sets default unit" do
      assert {:ok, %Period{amount: 100, unit: :second}} == Periods.new("100")
    end

    test "amount: with application env sets amount" do
      Application.put_env(Periods, :default_unit, :day)
      assert {:ok, %Period{amount: 100, unit: :day}} == Periods.new(100)
      Application.delete_env(Periods, :default_unit)
    end

    test "amount: with invalid amount returns error" do
      for bad_amount <- [1.23, "1.23", %{}, [], {}] do
        {:error, message} = Periods.new(bad_amount)
        assert message == [amount: "must be an integer"]
      end
    end
  end
end
