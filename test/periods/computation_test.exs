defmodule Periods.ComputationTest do
  use ExUnit.Case

  alias Periods.Computation
  alias Periods.Period

  setup_all do
    Calendar.put_time_zone_database(Tz.TimeZoneDatabase)
  end

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

        assert {:error, {:invalid_month_addition, bad_unit}} ==
                 Computation.add(period_1, period_2)
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

    test "Time: when Time is second argument adds the period to a Time" do
      {:ok, time} = Time.from_iso8601("23:50:07")
      {:ok, period} = Periods.new({10, :hour})

      result = Computation.add(period, time)
      assert result == ~T[09:50:07]
    end

    test "Time: with a negative value subtracts the period from a Time" do
      {:ok, time} = Time.from_iso8601("23:50:07")
      {:ok, period} = Periods.new({-10, :hour})

      result = Computation.add(time, period)
      assert result == ~T[13:50:07]
    end

    test "Time: with a non time value returns error when trying to add to a Time" do
      {:ok, time} = Time.from_iso8601("23:50:07")

      for bad_unit <- [:day, :week, :month, :year, :decade] do
        {:ok, period} = Periods.new({10, bad_unit})
        assert {:error, {:invalid_time_addition, bad_unit}} == Computation.add(time, period)
      end
    end

    test "Date: with a valid unit adds the period to a Date" do
      {:ok, date} = Date.new(2000, 1, 1)
      {:ok, period} = Periods.new({100, :hour})

      result = Computation.add(date, period)
      assert result == ~D[2000-01-05]
    end

    test "Date: when Date is second argument adds the period to a Date" do
      {:ok, date} = Date.new(2000, 1, 1)
      {:ok, period} = Periods.new({100, :hour})

      result = Computation.add(period, date)
      assert result == ~D[2000-01-05]
    end

    test "Date: with a negative value subtracts the period from a Date" do
      {:ok, date} = Date.new(2000, 1, 1)
      {:ok, period} = Periods.new({-100, :hour})

      result = Computation.add(date, period)
      assert result == ~D[1999-12-28]
    end

    test "Date: a month returns error when trying to add to a Date" do
      {:ok, date} = Date.new(2000, 1, 1)

      {:ok, period} = Periods.new({10, :month})
      assert {:error, {:invalid_month_addition, Date}} == Computation.add(date, period)
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

    test "DateTime: when DateTime is second argument adds the period to a DateTime" do
      {:ok, datetime, 0} = DateTime.from_iso8601("2023-01-03T23:50:07Z")
      {:ok, period} = Periods.new({10, :day})

      result = Computation.add(period, datetime)
      assert result == ~U[2023-01-13 23:50:07Z]
    end

    test "DateTime: with a month returns error when trying to add to a DateTime" do
      {:ok, datetime, 0} = DateTime.from_iso8601("2023-01-03T23:50:07Z")

      {:ok, period} = Periods.new({10, :month})
      assert {:error, {:invalid_month_addition, DateTime}} == Computation.add(datetime, period)
    end

    test "NaiveDateTime: with a non month value adds the period to a NaiveDateTime" do
      {:ok, naive_datetime} = NaiveDateTime.from_iso8601("2015-01-03 23:50:07")
      {:ok, period} = Periods.new({10, :day})

      result = Computation.add(naive_datetime, period)
      assert result == ~N[2015-01-13 23:50:07]
    end

    test "NaiveDateTime: with a negative value subtracts the period from a NaiveDateTime" do
      {:ok, naive_datetime} = NaiveDateTime.from_iso8601("2015-01-23 23:50:07")
      {:ok, period} = Periods.new({-10, :day})

      result = Computation.add(naive_datetime, period)
      assert result == ~N[2015-01-13 23:50:07]
    end

    test "NaiveDateTime: when NaiveDateTime is second argument adds the period to a NaiveDateTime" do
      {:ok, naive_datetime} = NaiveDateTime.from_iso8601("2015-01-03 23:50:07")
      {:ok, period} = Periods.new({10, :day})

      result = Computation.add(period, naive_datetime)
      assert result == ~N[2015-01-13 23:50:07]
    end

    test "NaiveDateTime: with a month returns error when trying to add to a NaiveDateTime" do
      {:ok, naive_datetime} = NaiveDateTime.from_iso8601("2015-01-23 23:50:07")

      {:ok, period} = Periods.new({10, :month})

      assert {:error, {:invalid_month_addition, NaiveDateTime}} ==
               Computation.add(naive_datetime, period)
    end
  end

  describe "diff/3" do
    test "Time: with valid arguments and no unit returns new Period in seconds" do
      {:ok, time_1} = Time.from_iso8601("21:30:43")
      {:ok, time_2} = Time.from_iso8601("13:50:17")

      {:ok, period} = Computation.diff(time_1, time_2)
      assert period.amount == 27626
      assert period.unit == :second

      assert Time.diff(time_1, time_2) == period.amount
    end

    test "Time: with valid arguments and a unit returns difference in that unit" do
      {:ok, time_1} = Time.from_iso8601("21:30:43")
      {:ok, time_2} = Time.from_iso8601("13:50:17")

      {:ok, period} = Computation.diff(time_1, time_2, :millisecond)
      assert period.amount == 27_626_000
      assert period.unit == :millisecond
    end

    test "Time: with invalid unit returns error" do
      {:ok, time_1} = Time.from_iso8601("21:30:43")
      {:ok, time_2} = Time.from_iso8601("13:50:17")

      assert {:error, :invalid_unit_type} == Computation.diff(time_1, time_2, :day)
    end

    test "Date: with valid arguments and no unit returns new Period in days" do
      {:ok, date_1} = Date.new(2000, 3, 15)
      {:ok, date_2} = Date.new(2000, 1, 1)

      {:ok, period} = Computation.diff(date_1, date_2)

      assert period.amount == 74
      assert period.unit == :day

      assert Date.diff(date_1, date_2) == period.amount
    end

    test "Date: with valid arguments and a unit returns new Period in that unit" do
      {:ok, date_1} = Date.new(2000, 3, 15)
      {:ok, date_2} = Date.new(2000, 1, 1)

      {:ok, period} = Computation.diff(date_1, date_2, :second)

      assert period.amount == 6_393_600
      assert period.unit == :second
    end

    test "Date: with month returns difference in months" do
      {:ok, date_1} = Date.new(2002, 7, 23)
      {:ok, date_2} = Date.new(2000, 1, 15)

      {:ok, period} = Computation.diff(date_1, date_2, :month)

      assert period.amount == 30
      assert period.unit == :month
    end

    test "Date: with month returns difference in negative months if the first date is further in the past" do
      {:ok, date_1} = Date.new(2002, 7, 23)
      {:ok, date_2} = Date.new(2000, 1, 15)

      {:ok, period} = Computation.diff(date_2, date_1, :month)

      assert period.amount == -30
      assert period.unit == :month
    end

    test "Date: with invalid unit returns error" do
      {:ok, date_1} = Date.new(2002, 7, 23)
      {:ok, date_2} = Date.new(2000, 1, 15)

      assert Computation.diff(date_1, date_2, :bad_unit) == {:error, :invalid_unit_type}
    end

    test "DateTime: with valid arguments, same timezone, and no unit returns new Period in seconds" do
      {:ok, datetime_1, 0} = DateTime.from_iso8601("2023-04-13T13:50:07Z")
      {:ok, datetime_2, 0} = DateTime.from_iso8601("2023-01-03T23:50:07Z")

      {:ok, period} = Computation.diff(datetime_1, datetime_2)

      assert period.amount == 8_604_000
      assert period.unit == :second

      assert DateTime.diff(datetime_1, datetime_2) == period.amount
    end

    test "DateTime: with valid arguments, same timezone, and a unit returns new Period in that unit" do
      {:ok, datetime_1} = DateTime.new(~D[2023-04-13], ~T[13:50:07.010], "Etc/UTC")
      {:ok, datetime_2} = DateTime.new(~D[2023-01-03], ~T[23:50:07.003], "Etc/UTC")

      assert Computation.diff(datetime_1, datetime_2, :millisecond) ==
               {:ok, %Period{amount: 8_604_000_007, unit: :millisecond}}

      assert Computation.diff(datetime_1, datetime_2, :minute) ==
               {:ok, %Period{amount: 143_400, unit: :minute}}

      assert Computation.diff(datetime_1, datetime_2, :hour) ==
               {:ok, %Period{amount: 2390, unit: :hour}}

      assert Computation.diff(datetime_1, datetime_2, :day) ==
               {:ok, %Period{amount: 99, unit: :day}}

      assert Computation.diff(datetime_1, datetime_2, :week) ==
               {:ok, %Period{amount: 14, unit: :week}}

      assert Computation.diff(datetime_1, datetime_2, :month) ==
               {:ok, %Period{amount: 3, unit: :month}}
    end

    test "DateTime: with different timezones shifts the timezones and returns difference" do
      {:ok, datetime_1} = DateTime.new(~D[2023-05-21], ~T[18:23:45.023], "Asia/Tokyo")
      {:ok, datetime_2} = DateTime.new(~D[2023-04-13], ~T[13:50:07.003], "Asia/Bangkok")

      {:ok, period} = Computation.diff(datetime_1, datetime_2)

      assert period.amount == 3_292_418
      assert period.unit == :second
    end

    test "DateTime: with one UTC timezone shifts the other timezone and returns difference" do
      Calendar.put_time_zone_database(Tz.TimeZoneDatabase)
      {:ok, datetime_1} = DateTime.new(~D[2023-04-13], ~T[13:50:07.003], "Etc/UTC")
      {:ok, datetime_2} = DateTime.new(~D[2023-04-13], ~T[13:50:07.003], "Asia/Tokyo")

      {:ok, period} = Computation.diff(datetime_1, datetime_2)

      assert period.amount == 32400
      assert period.unit == :second
    end

    test "DateTime: with different timezones, and a unit, shifts the timezones and returns difference in the unit" do
      {:ok, datetime_1} = DateTime.new(~D[2023-05-21], ~T[18:23:45.023], "Asia/Tokyo")
      {:ok, datetime_2} = DateTime.new(~D[2023-04-13], ~T[13:50:07.003], "Asia/Bangkok")

      assert Computation.diff(datetime_1, datetime_2, :millisecond) ==
               {:ok, %Period{amount: 3_292_418_020, unit: :millisecond}}

      assert Computation.diff(datetime_1, datetime_2, :minute) ==
               {:ok, %Period{amount: 54_873, unit: :minute}}

      assert Computation.diff(datetime_1, datetime_2, :hour) ==
               {:ok, %Period{amount: 914, unit: :hour}}

      assert Computation.diff(datetime_1, datetime_2, :day) ==
               {:ok, %Period{amount: 38, unit: :day}}

      assert Computation.diff(datetime_1, datetime_2, :week) ==
               {:ok, %Period{amount: 5, unit: :week}}

      assert Computation.diff(datetime_1, datetime_2, :month) ==
               {:ok, %Period{amount: 1, unit: :month}}
    end

    test "DateTime: with invalid unit returns error" do
      {:ok, datetime_1} = DateTime.new(~D[2023-05-21], ~T[18:23:45.023], "Asia/Tokyo")
      {:ok, datetime_2} = DateTime.new(~D[2023-04-13], ~T[13:50:07.003], "Asia/Bangkok")

      assert Computation.diff(datetime_1, datetime_2, :bad_unit) == {:error, :invalid_unit_type}
    end

    test "NaiveDateTime: with valid arguments and no unit returns new Period in seconds" do
      {:ok, naive_datetime_1} = NaiveDateTime.new(2010, 12, 21, 15, 30, 30, 800)
      {:ok, naive_datetime_2} = NaiveDateTime.new(2010, 12, 1, 21, 15, 15, 25)

      {:ok, period} = Computation.diff(naive_datetime_1, naive_datetime_2)

      assert period.amount == 1_707_315
      assert period.unit == :second

      assert NaiveDateTime.diff(naive_datetime_1, naive_datetime_2) == period.amount
    end

    test "NaiveDateTime: with month returns difference in months" do
      {:ok, naive_datetime_1} = NaiveDateTime.new(2002, 7, 23, 15, 30, 30, 800)
      {:ok, naive_datetime_2} = NaiveDateTime.new(2000, 1, 15, 21, 15, 15, 25)

      {:ok, period} = Computation.diff(naive_datetime_1, naive_datetime_2, :month)

      assert period.amount == 30
      assert period.unit == :month
    end

    test "NaiveDateTime: with valid arguments and a unit returns new Period in that unit" do
      {:ok, naive_datetime_1} = NaiveDateTime.new(2002, 7, 23, 15, 30, 30, 800)
      {:ok, naive_datetime_2} = NaiveDateTime.new(2000, 1, 15, 21, 15, 15, 25)

      assert Computation.diff(naive_datetime_1, naive_datetime_2, :millisecond) ==
               {:ok, %Period{amount: 79_467_315_000, unit: :millisecond}}

      assert Computation.diff(naive_datetime_1, naive_datetime_2, :minute) ==
               {:ok, %Period{amount: 1_324_455, unit: :minute}}

      assert Computation.diff(naive_datetime_1, naive_datetime_2, :hour) ==
               {:ok, %Period{amount: 22_074, unit: :hour}}

      assert Computation.diff(naive_datetime_1, naive_datetime_2, :day) ==
               {:ok, %Period{amount: 919, unit: :day}}

      assert Computation.diff(naive_datetime_1, naive_datetime_2, :week) ==
               {:ok, %Period{amount: 131, unit: :week}}

      assert Computation.diff(naive_datetime_1, naive_datetime_2, :month) ==
               {:ok, %Period{amount: 30, unit: :month}}

      assert Computation.diff(naive_datetime_1, naive_datetime_2, :year) ==
               {:ok, %Period{amount: 2, unit: :year}}
    end

    test "NaiveDateTime: with invalid unit returns error" do
      {:ok, naive_datetime_1} = NaiveDateTime.new(2002, 7, 23, 15, 30, 30, 800)
      {:ok, naive_datetime_2} = NaiveDateTime.new(2000, 1, 15, 21, 15, 15, 25)

      assert Computation.diff(naive_datetime_1, naive_datetime_2, :bad_unit) ==
               {:error, :invalid_unit_type}
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

        assert {:error, {:invalid_month_subtraction, bad_unit}} ==
                 Computation.subtract(period_1, period_2)
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

    test "Time: when Period is first argument subtracts the Period from the Time" do
      {:ok, time} = Time.from_iso8601("12:50:07")
      {:ok, period} = Periods.new({10, :hour})

      result = Computation.subtract(period, time)
      assert result == ~T[02:50:07]
    end

    test "Time: with a negative value adds the period from a Time" do
      {:ok, time} = Time.from_iso8601("13:50:07")
      {:ok, period} = Periods.new({-10, :hour})

      result = Computation.subtract(time, period)
      assert result == ~T[23:50:07]
    end

    test "Time: with a non Time value returns error when trying to add to a Time" do
      {:ok, time} = Time.from_iso8601("23:50:07")

      for bad_unit <- [:day, :week, :month, :year, :decade] do
        {:ok, period} = Periods.new({10, bad_unit})

        assert {:error, {:invalid_time_subtraction, bad_unit}} ==
                 Computation.subtract(time, period)
      end
    end

    test "Date: with a valid unit subtracts the period from a Date" do
      {:ok, date} = Date.new(2000, 1, 1)
      {:ok, period} = Periods.new({100, :hour})

      result = Computation.subtract(date, period)
      assert result == ~D[1999-12-28]
    end

    test "Date: with a negative value adds the period from a Date" do
      {:ok, date} = Date.new(2000, 1, 1)
      {:ok, period} = Periods.new({-100, :hour})

      result = Computation.subtract(date, period)
      assert result == ~D[2000-01-05]
    end

    test "Date: when Period is first argument subtracts the Period from the Date" do
      {:ok, date} = Date.new(2000, 1, 1)
      {:ok, period} = Periods.new({100, :hour})

      result = Computation.subtract(period, date)
      assert result == ~D[1999-12-28]
    end

    test "Date: a month returns error when trying to subtract from a Date" do
      {:ok, date} = Date.new(2000, 1, 1)

      {:ok, period} = Periods.new({10, :month})
      assert {:error, {:invalid_month_subtraction, Date}} == Computation.subtract(date, period)
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

    test "DateTime: when Period is first argument subtracts the Period from the DateTime" do
      {:ok, datetime, 0} = DateTime.from_iso8601("2023-01-23T23:50:07Z")
      {:ok, period} = Periods.new({10, :day})

      result = Computation.subtract(period, datetime)
      assert result == ~U[2023-01-13 23:50:07Z]
    end

    test "NaiveDateTime: with a non month value subtracts the period from a NaiveDateTime" do
      {:ok, naive_datetime} = NaiveDateTime.from_iso8601("2015-01-13 23:50:07")
      {:ok, period} = Periods.new({10, :day})

      result = Computation.subtract(naive_datetime, period)
      assert result == ~N[2015-01-03 23:50:07]
    end

    test "NaiveDateTime: with a negative value adds the period to a NaiveDateTime" do
      {:ok, naive_datetime} = NaiveDateTime.from_iso8601("2015-01-03 23:50:07")
      {:ok, period} = Periods.new({-10, :day})

      result = Computation.subtract(naive_datetime, period)
      assert result == ~N[2015-01-13 23:50:07]
    end

    test "NaiveDateTime: when Period is first argument subtracts the Period from the NaiveDateTime" do
      {:ok, naive_datetime} = NaiveDateTime.from_iso8601("2015-01-13 23:50:07")
      {:ok, period} = Periods.new({10, :day})

      result = Computation.subtract(period, naive_datetime)
      assert result == ~N[2015-01-03 23:50:07]
    end

    test "NaiveDateTime: with a month returns error when trying to subtract from a NaiveDateTime" do
      {:ok, naive_datetime} = NaiveDateTime.from_iso8601("2015-01-23 23:50:07")

      {:ok, period} = Periods.new({10, :month})

      assert {:error, {:invalid_month_subtraction, NaiveDateTime}} ==
               Computation.subtract(naive_datetime, period)
    end
  end
end
