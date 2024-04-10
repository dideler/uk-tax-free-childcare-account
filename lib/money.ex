defmodule Money do
  @moduledoc """
  Represents money as integer values internally for safer operations
  """

  @type t :: %__MODULE__{
          amount: integer,
          currency: atom
        }

  defstruct amount: 0, currency: :GBP

  @supported_currencies ~w(GBP)a

  def new(amount) when is_integer(amount), do: struct(__MODULE__, amount: amount)

  def new(amount, currency) when is_integer(amount) and currency in @supported_currencies,
    do: struct(__MODULE__, amount: amount, currency: currency)

  # initialise: new, parse
  # predicates: equals?, zero?, positive?, negative?, gt?, lt? ge?/gte? le?/lte? eq? ne?, compare
  # operations: add, mul, div, sub, convert
  # presenters: symbol, name, to_s/to_string
end
