defmodule ComputationTest do
  use ExUnit.Case

  alias Periods.Computation
  alias Periods.Period

  describe "add/2" do
    test "Periods: with the same unit returns the total" do
      {:ok, period_1} = Periods.new(100)
      {:ok, period_2} = Periods.new(300)
      assert %Period{amount: 400, unit: :second} == Computation.add(period_1, period_2)
    end

    test "Periods: with different units returns the lowest unit" do
      {:ok, period_1} = Periods.new({10, :day})
      {:ok, period_2} = Periods.new({300, :hour})

      assert %Period{amount: 540, unit: :hour} == Computation.add(period_1, period_2)
    end

    test "Periods: month addition restrictions returns error" do
      for bad_unit <- [:millisecond, :second, :minute, :hour, :week] do
        {:ok, period_1} = Periods.new({100, bad_unit})
        {:ok, period_2} = Periods.new({300, :month})

        assert {:error, :invalid_month_addition} == Computation.add(period_1, period_2)
      end
    end

    test "Periods: adds months with years" do
      {:ok, period_1} = Periods.new({2, :year})
      {:ok, period_2} = Periods.new({10, :month})
      assert %Period{amount: 34, unit: :month} == Computation.add(period_1, period_2)
    end

    test "Periods: adds months with decades" do
      {:ok, period_1} = Periods.new({2, :decade})
      {:ok, period_2} = Periods.new({10, :month})
      assert %Period{amount: 250, unit: :month} == Computation.add(period_1, period_2)
    end

    test "Time: with a valid unit adds the period to a Time" do
      {:ok, time} = Time.from_iso8601("23:50:07")
      {:ok, period} = Periods.new({10, :hour})

      result = Computation.add(time, period)
      assert result == ~T[09:50:07]
    end

    test "Time: with a negative value subtracts the period from a Time" do
      {:ok, time} = Time.from_iso8601("23:50:07")
      {:ok, period} = Periods.new({-10, :hour})

      result = Computation.add(time, period)
      assert result == ~T[13:50:07]
    end

    test "Time: with a month restricted value returns error when trying to add to a Time" do
      {:ok, time} = Time.from_iso8601("23:50:07")

      for bad_unit <- [:day, :week, :month, :year, :decade] do
        {:ok, period} = Periods.new({10, bad_unit})
        assert {:error, :invalid_time_addition} == Computation.add(time, period)
      end
    end

    test "Date: with a valid unit adds the period to a Date" do
      {:ok, time} = Date.new(2000, 1, 1)
      {:ok, period} = Periods.new({100, :hour})

      result = Computation.add(time, period)
      assert result == ~D[2000-01-05]
    end

    test "Date: with a negative value subtracts the period from a Date" do
      {:ok, time} = Date.new(2000, 1, 1)
      {:ok, period} = Periods.new({-100, :hour})

      result = Computation.add(time, period)
      assert result == ~D[1999-12-28]
    end

    test "Date: a month returns error when trying to add to a Date" do
      {:ok, time} = Date.new(2000, 1, 1)

      {:ok, period} = Periods.new({10, :month})
      assert {:error, :invalid_date_addition} == Computation.add(time, period)
    end

    test "DateTime: with a non month value adds the period to a DateTime" do
      {:ok, datetime, 0} = DateTime.from_iso8601("2023-01-03T23:50:07Z")
      {:ok, period} = Periods.new({10, :day})

      result = Computation.add(datetime, period)
      assert result == ~U[2023-01-13 23:50:07Z]
    end

    test "DateTime: with a negative value subtracts the period from a DateTime" do
      {:ok, datetime, 0} = DateTime.from_iso8601("2023-01-23T23:50:07Z")
      {:ok, period} = Periods.new({-10, :day})

      result = Computation.add(datetime, period)
      assert result == ~U[2023-01-13 23:50:07Z]
    end

    test "DateTime: with a month restricted value returns error when trying to add to a DateTime" do
      {:ok, datetime, 0} = DateTime.from_iso8601("2023-01-03T23:50:07Z")

      for bad_unit <- [:millisecond, :second, :minute, :hour, :week, :month] do
        {:ok, period} = Periods.new({10, bad_unit})
        assert {:error, :invalid_month_addition} == Computation.add(datetime, period)
      end
    end

    test "NaiveDateTime: with a non month value adds the period to a NaiveDateTime" do
      {:ok, datetime} = NaiveDateTime.from_iso8601("2015-01-03 23:50:07")
      {:ok, period} = Periods.new({10, :day})

      result = Computation.add(datetime, period)
      assert result == ~N[2015-01-13 23:50:07]
    end

    test "NaiveDateTime: with a negative value subtracts the period from a NaiveDateTime" do
      {:ok, datetime} = NaiveDateTime.from_iso8601("2015-01-23 23:50:07")
      {:ok, period} = Periods.new({-10, :day})

      result = Computation.add(datetime, period)
      assert result == ~N[2015-01-13 23:50:07]
    end

    test "NaiveDateTime: with a month restricted value returns error when trying to add to a NaiveDateTime" do
      {:ok, datetime} = NaiveDateTime.from_iso8601("2015-01-23 23:50:07")

      for bad_unit <- [:millisecond, :second, :minute, :hour, :week, :month] do
        {:ok, period} = Periods.new({10, bad_unit})
        assert {:error, :invalid_month_addition} == Computation.add(datetime, period)
      end
    end
  end

  describe "subtract/2" do
    test "Periods: with the same unit returns the total" do
      {:ok, period_1} = Periods.new(300)
      {:ok, period_2} = Periods.new(100)

      assert %Period{amount: 200, unit: :second} == Computation.subtract(period_1, period_2)
    end

    test "Periods: with the same unit allows a negative total" do
      {:ok, period_1} = Periods.new(100)
      {:ok, period_2} = Periods.new(400)

      assert %Period{amount: -300, unit: :second} == Computation.subtract(period_1, period_2)
    end

    test "Periods: month subtraction restrictions returns error" do
      for bad_unit <- [:millisecond, :second, :minute, :hour, :week] do
        {:ok, period_1} = Periods.new({100, bad_unit})
        {:ok, period_2} = Periods.new({300, :month})

        assert {:error, :invalid_month_subtraction} == Computation.subtract(period_1, period_2)
      end
    end

    test "Periods: subtracts months with years" do
      {:ok, period_1} = Periods.new({2, :year})
      {:ok, period_2} = Periods.new({10, :month})
      assert %Period{amount: 14, unit: :month} == Computation.subtract(period_1, period_2)
    end

    test "Periods: subtracts months with decades" do
      {:ok, period_1} = Periods.new({2, :decade})
      {:ok, period_2} = Periods.new({10, :month})
      assert %Period{amount: 230, unit: :month} == Computation.subtract(period_1, period_2)
    end

    test "Time: with a valid unit subtracts the period from a Time" do
      {:ok, time} = Time.from_iso8601("12:50:07")
      {:ok, period} = Periods.new({10, :hour})

      result = Computation.subtract(time, period)
      assert result == ~T[02:50:07]
    end

    test "Time: with a negative value adds the period from a Time" do
      {:ok, time} = Time.from_iso8601("13:50:07")
      {:ok, period} = Periods.new({-10, :hour})

      result = Computation.subtract(time, period)
      assert result == ~T[23:50:07]
    end

    test "Time: with a month restricted value returns error when trying to add to a Time" do
      {:ok, time} = Time.from_iso8601("23:50:07")

      for bad_unit <- [:day, :week, :month, :year, :decade] do
        {:ok, period} = Periods.new({10, bad_unit})
        assert {:error, :invalid_time_subtraction} == Computation.subtract(time, period)
      end
    end

    test "Date: with a valid unit subtracts the period from a Date" do
      {:ok, time} = Date.new(2000, 1, 1)
      {:ok, period} = Periods.new({100, :hour})

      result = Computation.subtract(time, period)
      assert result == ~D[1999-12-28]
    end

    test "Date: with a negative value adds the period from a Date" do
      {:ok, time} = Date.new(2000, 1, 1)
      {:ok, period} = Periods.new({-100, :hour})

      result = Computation.subtract(time, period)
      assert result == ~D[2000-01-05]
    end

    test "Date: a month returns error when trying to subtract from a Date" do
      {:ok, time} = Date.new(2000, 1, 1)

      {:ok, period} = Periods.new({10, :month})
      assert {:error, :invalid_date_addition} == Computation.subtract(time, period)
    end

    test "DateTime: with a non month value subtracts the period to a DateTime" do
      {:ok, datetime, 0} = DateTime.from_iso8601("2023-01-23T23:50:07Z")
      {:ok, period} = Periods.new({10, :day})

      result = Computation.subtract(datetime, period)
      assert result == ~U[2023-01-13 23:50:07Z]
    end

    test "DateTime: with a negative value adds the period from a DateTime" do
      {:ok, datetime, 0} = DateTime.from_iso8601("2023-01-03T23:50:07Z")
      {:ok, period} = Periods.new({-10, :day})

      result = Computation.subtract(datetime, period)
      assert result == ~U[2023-01-13 23:50:07Z]
    end

    test "DateTime: with a month restricted value returns error when trying to add to a DateTime" do
      {:ok, datetime, 0} = DateTime.from_iso8601("2023-01-03T23:50:07Z")

      for bad_unit <- [:millisecond, :second, :minute, :hour, :week, :month] do
        {:ok, period} = Periods.new({10, bad_unit})
        assert {:error, :invalid_month_subtraction} == Computation.subtract(datetime, period)
      end
    end

    test "NaiveDateTime: with a non month value subtracts the period from a NaiveDateTime" do
      {:ok, datetime} = NaiveDateTime.from_iso8601("2015-01-13 23:50:07")
      {:ok, period} = Periods.new({10, :day})

      result = Computation.subtract(datetime, period)
      assert result == ~N[2015-01-03 23:50:07]
    end

    test "NaiveDateTime: with a negative value adds the period to a NaiveDateTime" do
      {:ok, datetime} = NaiveDateTime.from_iso8601("2015-01-03 23:50:07")
      {:ok, period} = Periods.new({-10, :day})

      result = Computation.subtract(datetime, period)
      assert result == ~N[2015-01-13 23:50:07]
    end

    test "NaiveDateTime: with a month restricted value returns error when trying to subtract from a NaiveDateTime" do
      {:ok, datetime} = NaiveDateTime.from_iso8601("2015-01-23 23:50:07")

      for bad_unit <- [:millisecond, :second, :minute, :hour, :week, :month] do
        {:ok, period} = Periods.new({10, bad_unit})
        assert {:error, :invalid_month_addition} == Computation.subtract(datetime, period)
      end
    end
  end
end
