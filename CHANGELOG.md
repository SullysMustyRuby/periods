# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0]

### Added

- `Periods.compare/2` — compares two Periods of any units and returns `:lt | :eq | :gt`.
  Works directly with `Enum.sort/2` (e.g. `Enum.sort(periods, Periods)`).
- `Periods.multiply/2` — scales a Period's amount by an integer.
- `Periods.negate/1` — flips the sign of a Period's amount.
- `Periods.abs/1` — returns a Period with the absolute value of its amount.
- `Periods.new!/2` — raising variant of `new/2` (mirrors the existing `new/2`).
- `Inspect` implementation for `Periods.Period` — renders as `#Periods.Period<10 day>`.
- `String.Chars` implementation for `Periods.Period` — enables string interpolation.
- `Periods.Ecto.IntervalType` — stores a Period as a native PostgreSQL `interval`,
  enabling database-side date math. (`Periods.Ecto.MapType` is still available for
  JSON storage that preserves the exact unit.)

### Changed

- Dropped the `decimal` dependency. All conversions operate on integer amounts, so the
  internal `Decimal.div_int/2` calls were equivalent to `Kernel.div/2`.
- `tz` is now a `:dev`/`:test`-only dependency. Timezone-aware `diff/3` uses whatever
  `:time_zone_database` the host application configures, so consuming apps no longer pull
  the full IANA dataset transitively.
- `ecto` requirement simplified to `~> 3.0`.

### Fixed

- README referenced the config key `:default_value`; the correct key is `:default_unit`.
- Corrected the `new!` documentation examples (the old example called a non-existent
  arity and named the wrong error type).
