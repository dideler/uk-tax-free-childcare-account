defmodule AccountTest do
  use ExUnit.Case

  alias Childcare.Account

  describe "pay_out/2 when there are sufficient funds" do
    test "reduces the balance by the amount due" do
      account = %Account{bal: 1500.0, due: 1000.0}

      assert {:ok, %Account{bal: 500.0}} = Account.pay_out(account)
    end

    test "resets the amount due" do
      account = %Account{bal: 1500.0, due: 1000.0}

      assert {:ok, %Account{due: +0.0}} = Account.pay_out(account)
    end
  end

  describe "pay_out/2 when there are insufficient funds" do
    test "errors with a descriptive message" do
      account = %Account{bal: 500.0, due: 1000.0}

      assert {:error, :insufficient_funds} = Account.pay_out(account)
    end
  end

  describe "pay_in/2 when used incorrectly" do
    test "errors when given anything other than a positive amount" do
      assert {:error, :amount_must_be_positive_number} == Account.pay_in(%Account{}, 0)
      assert {:error, :amount_must_be_positive_number} == Account.pay_in(%Account{}, -1.5)
      assert {:error, :amount_must_be_positive_number} == Account.pay_in(%Account{}, "1.0")
    end
  end

  describe "pay_in/2 when zero bonus quota is remaining" do
    test "adds only the payment amount to the balance" do
      pay_in = 1000.0
      account = %Account{bal: 0.0, rem: 0.0}

      assert {:ok, updated_account} = Account.pay_in(account, pay_in)
      assert %Account{bal: pay_in, rem: 0.0} == updated_account
    end
  end

  describe "pay_in/2 when a bonus quota is remaining" do
    test "adds a bonus to balance using the pay-in ratio" do
      pay_in = 80
      account = %Account{bal: 0.0, rem: 20.0, rat: {8, 2}}

      assert {:ok, updated_account} = Account.pay_in(account, pay_in)
      assert %Account{bal: 100.0} = updated_account
    end

    test "bonus cannot exceed the remaining bonus quota" do
      pay_in = 80
      account = %Account{bal: 0.0, rem: 10.0, rat: {8, 2}}

      assert {:ok, updated_account} = Account.pay_in(account, pay_in)
      assert %Account{bal: 90.0, rem: +0.0} = updated_account
    end

    test "deducts the added bonus from the remaining bonus" do
      pay_in = 80
      account = %Account{rem: 20.0, rat: {8, 2}}

      assert {:ok, updated_account} = Account.pay_in(account, pay_in)
      assert %Account{rem: +0.0} = updated_account
    end

    test "does not treat the terms of the ratio as a fraction" do
      account = %Account{bal: 0.0, rem: 2.0, rat: {8, 2}}

      assert {:ok, %Account{bal: 7.0, rem: 2.0}} = Account.pay_in(account, 7)
      assert {:ok, %Account{bal: 10.0, rem: +0.0}} = Account.pay_in(account, 8)
    end
  end

  describe "bonus/2" do
    test "zero bonus when there's no remaining bonus" do
      pay_in = 10
      assert 0 == Account.bonus(%Account{rem: 0}, pay_in)
      assert 0 == Account.bonus(%Account{rem: 0.0}, pay_in)
    end

    test "bonus is based on the pay-in, remaining bonus, and pay-in to bonus ratio" do
      assert 0.0 == Account.bonus(%Account{rem: 5, rat: {2, 1}}, 1)
      assert 1.0 == Account.bonus(%Account{rem: 1, rat: {2, 1}}, 10)
      assert 5.0 == Account.bonus(%Account{rem: 5, rat: {2, 1}}, 10)
      assert 5.0 == Account.bonus(%Account{rem: 10, rat: {2, 1}}, 10)
    end
  end
end
