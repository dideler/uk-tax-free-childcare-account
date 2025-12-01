defmodule PayInRecommenderTest do
  use ExUnit.Case

  alias Childcare.Account
  alias Childcare.Account.PayInRecommender, as: Recommender

  describe "suggest_pay_in/1" do
    test "suggests zero payment when no payment is due" do
      account_v1 = %Account{due: 0.0, bal: 100.0}
      account_v2 = %Account{due: 0.0, bal: 100.0}
      assert {0.0, account_v2} == Recommender.suggest_pay_in(account_v1)
    end

    test "suggests the min payment when balance insufficient and no bonus remaining" do
      account_v1 = %Account{due: 100.0, bal: 50.0, rem: 0.0}
      account_v2 = %Account{due: 100.0, bal: 100.0, rem: 0.0}
      assert {50.0, account_v2} == Recommender.suggest_pay_in(account_v1)
    end
  end

  describe "suggest_pay_in/1 when using the min payment strategy" do
    test "optimises for the minimum pay-in to cover the dues adjusting for bonus" do
      opts = [strat: :min_pay]
      account_v1 = %Account{due: 100.0, bal: 70.0, rem: 20.0, rat: {2, 1}}
      account_v2 = %Account{due: 100.0, bal: 100.0, rem: 10.0, rat: {2, 1}}
      assert {20.0, account_v2} == Recommender.suggest_pay_in(account_v1, opts)
    end

    test "suggests zero payment when balance is sufficient despite bonus remaining" do
      opts = [strat: :min_pay]
      account_v1 = %Account{due: 100.0, bal: 100.0, rem: 20.0}
      account_v2 = %Account{due: 100.0, bal: 100.0, rem: 20.0}
      assert {0.0, account_v2} == Recommender.suggest_pay_in(account_v1, opts)
    end
  end

  describe "suggest_pay_in/1 when using the max bonus strategy" do
    test "optimises for the pay-in to maximise the bonus and cover the dues" do
      opts = [strat: :max_bonus]
      account_v1 = %Account{due: 100.0, bal: 50.0, rem: 50.0, rat: {2, 1}}
      account_v2 = %Account{due: 100.0, bal: 200.0, rem: 0.0, rat: {2, 1}}
      assert {100.0, account_v2} == Recommender.suggest_pay_in(account_v1, opts)
    end

    test "suggests more when maxing the remaining bonus not sufficient to pay dues" do
      opts = [strat: :max_bonus]
      account_v1 = %Account{due: 250.0, bal: 50.0, rem: 50.0, rat: {2, 1}}
      account_v2 = %Account{due: 250.0, bal: 250.0, rem: 0.0, rat: {2, 1}}
      assert {150.0, account_v2} == Recommender.suggest_pay_in(account_v1, opts)
    end
  end

  describe "suggest_pay_in/2 edge cases" do
    test "does not introduce rounding errors with min_pay strategy" do
      account = Account.new(due: 906.1, bal: 209.52, rem: 290.48, rat: {8, 2})

      {_pay_in, updated_account} =
        Recommender.suggest_pay_in(account, strat: :min_pay)

      assert updated_account.rem == 152.48
    end

    @tag timeout: 1_000
    test "does not hang with min_pay strategy when remaining bonus is zero" do
      account = Account.new(due: 838.1, bal: 755.81, rem: 0, rat: {8, 2})

      {pay_in, updated_account} =
        Recommender.suggest_pay_in(account, strat: :min_pay)

      assert pay_in == 82.29
      assert updated_account.bal == 838.1
    end
  end
end
