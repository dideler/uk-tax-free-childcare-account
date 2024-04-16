defmodule Money do
  @moduledoc """
  Represents money as integer values internally for safer operations
  """
  alias Money.CurrencyError

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
  def pos?(m), do: positive?(m)

  @spec negative?(t) :: boolean()
  def negative?(%Money{amount: amount}), do: amount < 0
  def neg?(m), do: negative?(m)

  @spec equals?(t, t) :: boolean()
  def equals?(%Money{} = m1, %Money{} = m2), do: m1 === m2
  def eq?(m1, m2), do: equals?(m1, m2)

  @spec not_equals?(t, t) :: boolean()
  def not_equals?(%Money{} = m1, %Money{} = m2), do: m1 !== m2
  def ne?(m1, m2), do: not_equals?(m1, m2)

  @spec gt?(t, t) :: boolean()
  def gt?(%Money{amount: a1, currency: c}, %Money{amount: a2, currency: c}), do: a1 > a2
  def gt?(%Money{}, %Money{}), do: false

  @spec gte?(t, t) :: boolean()
  def gte?(%Money{amount: a1, currency: c}, %Money{amount: a2, currency: c}), do: a1 >= a2
  def gte?(%Money{}, %Money{}), do: false

  @spec lt?(t, t) :: boolean()
  def lt?(%Money{amount: a1, currency: c}, %Money{amount: a2, currency: c}), do: a1 < a2
  def lt?(%Money{}, %Money{}), do: false

  @spec lte?(t, t) :: boolean()
  def lte?(%Money{amount: a1, currency: c}, %Money{amount: a2, currency: c}), do: a1 <= a2
  def lte?(%Money{} = m1, %Money{} = m2), do: raise(CurrencyError, m1: m1, m2: m2)

  @spec compare(t, t) :: :eq | :gt | :lt
  def compare(%Money{amount: a1, currency: c}, %Money{amount: a2, currency: c}) do
    cond do
      a1 === a2 -> :eq
      a1 > a2 -> :gt
      a1 < a2 -> :lt
    end
  end

  def compare(%Money{} = m1, %Money{} = m2), do: raise(CurrencyError, m1: m1, m2: m2)

  defmodule CurrencyError do
    defexception [:m1, :m2]

    def message(exception) do
      "Currencies #{exception.m1.currency} and #{exception.m2.currency} are not compatible"
    end
  end

  # initialise: new, parse
  # predicates: equals?, zero?, positive?, negative?, gt?, lt? ge?/gte? le?/lte? eq? ne?, compare
  # operations: add, mul, div, sub, convert
  # presenters: symbol, name, to_s/to_string
end
