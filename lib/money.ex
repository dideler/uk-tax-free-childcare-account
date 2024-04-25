defmodule Money do
  @moduledoc """
  Represents money as integer values internally for safer operations
  """
  alias Money.CurrencyError

  defmodule CurrencyError do
    defexception [:m1, :m2]

    def message(exception) do
      "Currencies #{exception.m1.currency} and #{exception.m2.currency} are not compatible"
    end
  end

  @supported_currencies ~w(GBP USD)a

  @type currency ::
          unquote(
            @supported_currencies
            |> Enum.map(&inspect/1)
            |> Enum.join(" | ")
            |> Code.string_to_quoted!()
          )

  @type t :: %__MODULE__{
          amount: integer,
          currency: currency
        }

  defstruct amount: 0, currency: :GBP

  @doc "Create Money structs with the ~M sigil. Requires 'import Money' to use sigil."
  def sigil_M(amount_raw, []), do: new(String.to_integer(amount_raw))

  def sigil_M(amount_raw, currency_raw) do
    new(String.to_integer(amount_raw), List.to_string(currency_raw) |> String.to_atom())
  end

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
  def gt?(%Money{} = m1, %Money{} = m2), do: raise(CurrencyError, m1: m1, m2: m2)

  @spec gte?(t, t) :: boolean()
  def gte?(%Money{amount: a1, currency: c}, %Money{amount: a2, currency: c}), do: a1 >= a2
  def gte?(%Money{} = m1, %Money{} = m2), do: raise(CurrencyError, m1: m1, m2: m2)

  @spec lt?(t, t) :: boolean()
  def lt?(%Money{amount: a1, currency: c}, %Money{amount: a2, currency: c}), do: a1 < a2
  def lt?(%Money{} = m1, %Money{} = m2), do: raise(CurrencyError, m1: m1, m2: m2)

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

  @spec abs(t) :: t
  def abs(%Money{amount: a} = m) when a < 0, do: %Money{m | amount: -a}
  def abs(%Money{} = m), do: m

  @spec add(t, t) :: t
  def add(%Money{amount: a1, currency: c}, %Money{amount: a2, currency: c}) do
    %Money{amount: a1 + a2, currency: c}
  end

  def add(%Money{} = m1, %Money{} = m2), do: raise(CurrencyError, m1: m1, m2: m2)

  @spec sub(t, t) :: t
  def sub(%Money{amount: a1, currency: c}, %Money{amount: a2, currency: c}) do
    %Money{amount: a1 - a2, currency: c}
  end

  def sub(%Money{} = m1, %Money{} = m2), do: raise(CurrencyError, m1: m1, m2: m2)

  @spec mul(t, number) :: t
  def mul(%Money{amount: a, currency: c}, multiplier) when is_number(multiplier) do
    %Money{amount: round(a * multiplier), currency: c}
  end

  @spec div(t, number) :: t
  def div(%Money{}, 0), do: raise(ArithmeticError, "Division by zero is not a number")
  def div(%Money{}, +0.0), do: raise(ArithmeticError, "Division by zero is not a number")

  def div(%Money{amount: a, currency: c}, divisor) when is_number(divisor) do
    %Money{amount: round(a / divisor), currency: c}
  end

  @spec split(t, pos_integer) :: [t]
  def split(%Money{} = m, 1), do: [m]

  def split(%Money{amount: a} = m, n) when is_integer(n) and n > 0 do
    [%Money{amount: head_a} | tail] = for _ <- 1..n, do: %Money{m | amount: Kernel.div(a, n)}
    [%Money{m | amount: head_a + rem(a, n)} | tail]
  end

  def split(%Money{}, _), do: raise(ArithmeticError)

  @spec convert(t, {currency, currency, number}) :: t
  def convert(%Money{}, {from, from, _rate}), do: raise(ArgumentError, "Exchange rate invalid")

  def convert(%Money{currency: from} = m, {from, to, rate})
      when to in @supported_currencies and rate > 0 do
    mul(%Money{m | currency: to}, rate)
  end

  def convert(%Money{}, _exchange_rate), do: raise(ArgumentError, "Exchange rate invalid")

  def currency_code(%Money{currency: c}), do: Kernel.to_string(c)

  def currency_name(%Money{currency: c}), do: currency_name(c)
  def currency_name(:GBP), do: "Sterling"
  def currency_name(:USD), do: "United States dollar"

  def currency_symbol(%Money{currency: :GBP}), do: "£"
  def currency_symbol(%Money{currency: :USD}), do: "$"

  # initialise: new, parse
  # predicates: equals?, zero?, positive?, negative?, gt?, lt? ge?/gte? le?/lte? eq? ne?, pos?, neg?
  # operations: add, mul, div, sub, abs, convert, compare, split
  # presenters: symbol, name, to_s/to_string
end
