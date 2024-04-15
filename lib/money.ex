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

  @spec zero?(t) :: boolean()
  def zero?(%__MODULE__{amount: amount}), do: amount === 0

  @spec positive?(t) :: boolean()
  def positive?(%__MODULE__{amount: amount}), do: amount > 0

  @spec negative?(t) :: boolean()
  def negative?(%__MODULE__{amount: amount}), do: amount < 0

  @spec equals?(t, t) :: boolean()
  def equals?(%__MODULE__{} = m1, %__MODULE__{} = m2), do: m1 === m2

  @spec gt?(t, t) :: boolean()
  def gt?(%__MODULE__{amount: a1, currency: c}, %__MODULE__{amount: a2, currency: c}), do: a1 > a2
  def gt?(%__MODULE__{}, %__MODULE__{}), do: false

  # initialise: new, parse
  # predicates: equals?, zero?, positive?, negative?, gt?, lt? ge?/gte? le?/lte? eq? ne?, compare
  # operations: add, mul, div, sub, convert
  # presenters: symbol, name, to_s/to_string
end
