defmodule Periods.Errors do
  defmacro __using__(_opts) do
    quote do
      defexception [:message]

      def exception(:amount_must_be_integer) do
        %__MODULE__{message: "amount must be an integer"}
      end

      def exception(:invalid_arguments) do
        %__MODULE__{message: "invalid arguments please try again"}
      end

      def exception(:invalid_unit_type) do
        %__MODULE__{message: "invalid unit type"}
      end
    end
  end
end
