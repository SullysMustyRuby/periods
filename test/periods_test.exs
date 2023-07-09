defmodule PeriodsTest do
  use ExUnit.Case,  async: false
  # doctest Periods

  alias Periods.Period

  describe "new/1" do
    test "map: with an integer amount and proper unit returns a struct" do
      assert {:ok, %Period{amount: 100, unit: :day}} == Period.new(%{amount: 100, unit: :day})
    end

    test "map: with an binary amount and proper unit returns a struct" do
      assert {:ok, %Period{amount: 100, unit: :day}} == Period.new(%{amount: "100", unit: :day})
    end

    test "map: with an invalid amount returns error" do
      for bad_amount <- [1.23, "1.23", %{}, [], {}] do
        {:error, message} = Period.new(%{amount: bad_amount, unit: :second})
        assert message == :amount_must_be_an_integer
      end
    end

    test "map: with invalid unit returns error" do
      for bad_unit <- [2, 1.23, "decimal", :decimal, %{}, [], {}] do
        {:error, message} = Period.new(%{amount: 1, unit: bad_unit})
        assert message == :bad_unit_type
      end
    end

    test "tuple: with an integer amount and proper unit returns a struct" do
      assert {:ok, %Period{amount: 100, unit: :day}} == Period.new({100, :day})
    end

    test "tuple: with an binary amount and proper unit returns a struct" do
      assert {:ok, %Period{amount: 100, unit: :day}} == Period.new({"100", :day})
    end

    test "tuple: with an invalid amount returns error" do
      for bad_amount <- [1.23, "1.23", %{}, [], {}] do
        {:error, message} = Period.new({bad_amount, :day})
        assert message == :amount_must_be_an_integer
      end
    end

    test "tuple: with invalid unit returns error" do
      for bad_unit <- [2, 1.23, "decimal", :decimal, %{}, [], {}] do
        {:error, message} = Period.new(%{amount: 1, unit: bad_unit})
        assert message == :bad_unit_type
      end
    end

    test "amount: with valid integer sets default unit" do
      assert {:ok, %Period{amount: 100, unit: :second}} == Period.new(100)
    end

    test "amount: with binary integer sets default unit" do
      assert {:ok, %Period{amount: 100, unit: :second}} == Period.new("100")
    end

    test "amount: with application env sets amount" do
      Application.put_env(Periods, :default_unit, :day)
      assert {:ok, %Period{amount: 100, unit: :day}} == Period.new(100)
      Application.delete_env(Periods, :default_unit)
    end

    test "amount: with invalid amount returns error" do
      for bad_amount <- [1.23, "1.23", %{}, [], {}] do
        {:error, message} = Period.new(bad_amount)
        assert message == :amount_must_be_an_integer
      end
    end
  end

end
