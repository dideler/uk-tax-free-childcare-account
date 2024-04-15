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
  def zero?(%Money{amount: amount}), do: amount === 0

  @spec positive?(t) :: boolean()
  def positive?(%Money{amount: amount}), do: amount > 0

  @spec negative?(t) :: boolean()
  def negative?(%Money{amount: amount}), do: amount < 0

  @spec equals?(t, t) :: boolean()
  def equals?(%Money{} = m1, %Money{} = m2), do: m1 === m2

  @spec gt?(t, t) :: boolean()
  def gt?(%Money{amount: a1, currency: c}, %Money{amount: a2, currency: c}), do: a1 > a2
  def gt?(%Money{}, %Money{}), do: false

  @spec gte?(t, t) :: boolean()
  def gte?(%Money{amount: a1, currency: c}, %Money{amount: a2, currency: c}), do: a1 >= a2
  def gte?(%Money{}, %Money{}), do: false

  @spec lt?(t, t) :: boolean()
  def lt?(%Money{amount: a1, currency: c}, %Money{amount: a2, currency: c}), do: a1 < a2
  def lt?(%Money{}, %Money{}), do: false

  # initialise: new, parse
  # predicates: equals?, zero?, positive?, negative?, gt?, lt? ge?/gte? le?/lte? eq? ne?, compare
  # operations: add, mul, div, sub, convert
  # presenters: symbol, name, to_s/to_string
end
