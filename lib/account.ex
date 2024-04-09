defmodule Childcare.Account do
  @moduledoc """
  GOV.UK Tax-Free Childcare Account, https://www.gov.uk/sign-in-childcare-account
  """

  alias Childcare.Account

  @type amount_due :: Float.t()
  @type balance :: Float.t()
  @type remaining_bonus :: Float.t()
  @type antecedent :: pos_integer()
  @type consequent :: pos_integer()
  @type pay_in_bonus_ratio :: {antecedent, consequent}

  @type t :: %__MODULE__{
          due: amount_due,
          bal: balance,
          rem: remaining_bonus,
          rat: pay_in_bonus_ratio
        }

  defstruct [:due, bal: 0.00, rem: 500.00, rat: {8, 2}]

  def new(attrs \\ %{}), do: struct(__MODULE__, attrs)

  @doc "Adjusts the account balance and amount due based on the due amount paid out"
  @spec pay_out(Account.t()) :: {:ok, Account.t()} | {:error, term}
  def pay_out(%Account{bal: balance, due: due}) when due > balance,
    do: {:error, :insufficient_funds}

  def pay_out(%Account{bal: balance, due: due} = account),
    do: {:ok, %Account{account | bal: balance - due, due: 0.0}}

  @doc "Adjusts the account balance and maybe the remaining bonus based on the amount paid in"
  @spec pay_in(Account.t(), number()) :: {:ok, Account.t()} | {:error, term}
  def pay_in(_account, paid_in) when not is_number(paid_in),
    do: {:error, :amount_must_be_positive_number}

  def pay_in(_account, paid_in) when paid_in <= 0, do: {:error, :amount_must_be_positive_number}

  def pay_in(%Account{} = account, paid_in) do
    account =
      account
      |> Map.update(:bal, 0.00, fn balance -> balance + paid_in end)
      |> apply_bonus(paid_in)

    {:ok, account}
  end

  @doc "Returns the bonus based on the amount paid in, remaining bonus, and pay-in to bonus ratio"
  @spec bonus(Account.t(), Float.t()) :: Float.t()
  def bonus(%Account{rem: 0}, _pay_in), do: 0.0
  def bonus(%Account{rem: +0.0}, _pay_in), do: 0.0

  def bonus(%Account{rem: remaining_bonus, rat: {antecedent, consequent}}, pay_in) do
    uncapped_bonus = Float.floor(pay_in / antecedent) * consequent
    min(remaining_bonus, uncapped_bonus)
  end

  defp apply_bonus(%Account{} = account, pay_in) do
    bonus = Account.bonus(account, pay_in)

    account
    |> Map.update!(:bal, &Float.round(&1 + bonus, 2))
    |> Map.update!(:rem, &Float.round(&1 - bonus, 2))
  end
end
