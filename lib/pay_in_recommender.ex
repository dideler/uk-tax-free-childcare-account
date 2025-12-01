defmodule Childcare.Account.PayInRecommender do
  alias Childcare.Account

  @doc """
  Returns the suggested amount to pay in along with the expected paid-in account state.

  Max bonus strategy suggests the minimum pay-in amount to cover dues and maximise the remaining bonus.
  Calculates the pay-in amount needed to exhaust the remaining balance, plus any additional funds
  needed if there's still a deficit after exhausting the bonus in order to cover the dues.

  Min payment strategy suggests the minimum pay-in amount to cover dues while taking bonus into account.
  Uses a binary search to find the optimal pay-in amount, where `deficit = pay_in + bonus(pay_in)`.
  """
  @spec suggest_pay_in(Account.t(), strat: term) :: {Float.t(), Account.t()}
  def suggest_pay_in(account, opts \\ [strat: :min_pay])

  def suggest_pay_in(%Account{due: +0.0} = acct, _opts), do: {0.0, acct}

  def suggest_pay_in(%Account{due: due, bal: bal} = acct, _opts) when bal >= due do
    {0.0, acct}
  end

  def suggest_pay_in(%Account{due: due, bal: balance, rem: rem} = acct, _opts) when rem == 0 do
    pay_in = due - balance
    account = Map.update(acct, :bal, balance, &(&1 + pay_in))
    {pay_in, account}
  end

  def suggest_pay_in(
        %Account{due: due, bal: balance, rem: remaining_bonus, rat: ratio} = acct,
        strat: :max_bonus
      ) do
    {antecedent, consequent} = ratio
    num_bonuses = Float.round(remaining_bonus / consequent, 2)
    pay_in_for_max_bonus = num_bonuses * antecedent
    new_balance = balance + pay_in_for_max_bonus + remaining_bonus

    pay_in =
      if new_balance >= due do
        pay_in_for_max_bonus
      else
        pay_in_for_max_bonus + (due - new_balance)
      end

    new_balance = balance + pay_in + remaining_bonus
    account = %Account{acct | bal: new_balance, rem: 0.0}
    {pay_in, account}
  end

  def suggest_pay_in(%Account{due: due, bal: balance} = account, strat: :min_pay) do
    pay_in = find_min_pay_in(account, due - balance)
    bonus = Account.bonus(account, pay_in)

    account =
      account
      |> Map.update!(:bal, &(&1 + pay_in + bonus))
      |> Map.update!(:rem, &(&1 - bonus))

    {pay_in, account}
  end

  defp find_min_pay_in(account, deficit), do: find_min_pay_in(account, deficit, 0, deficit)

  defp find_min_pay_in(account, deficit, min, max) do
    pay_in = Float.round((min + max) / 2, 2)
    top_up = pay_in + Account.bonus(account, pay_in)

    cond do
      top_up < deficit -> find_min_pay_in(account, deficit, pay_in + 1, max)
      top_up > deficit -> find_min_pay_in(account, deficit, min, pay_in - 1)
      top_up == deficit -> pay_in
    end
  end
end
