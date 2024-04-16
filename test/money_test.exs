defmodule MoneyTest do
  use ExUnit.Case

  test "zero?/1" do
    assert Money.zero?(%Money{amount: 0})
    refute Money.zero?(%Money{amount: 1})
    refute Money.zero?(%Money{amount: -1})
  end

  test "positive?/1" do
    assert Money.positive?(%Money{amount: 1})
    refute Money.positive?(%Money{amount: 0})
    refute Money.positive?(%Money{amount: -1})
  end

  test "negative?/1" do
    assert Money.negative?(%Money{amount: -1})
    refute Money.negative?(%Money{amount: 0})
    refute Money.negative?(%Money{amount: 1})
  end

  test "equals?/2" do
    assert Money.equals?(%Money{amount: 1, currency: :GBP}, %Money{amount: 1, currency: :GBP})
    refute Money.equals?(%Money{amount: 1, currency: :USD}, %Money{amount: 1, currency: :GBP})
    refute Money.equals?(%Money{amount: 0, currency: :GBP}, %Money{amount: 1, currency: :GBP})
  end

  test "not_equals?/2" do
    assert Money.not_equals?(%Money{amount: 0, currency: :GBP}, %Money{amount: 1, currency: :GBP})
    assert Money.not_equals?(%Money{amount: 1, currency: :USD}, %Money{amount: 1, currency: :GBP})
    refute Money.not_equals?(%Money{amount: 1, currency: :GBP}, %Money{amount: 1, currency: :GBP})
  end

  test "gt?/2" do
    assert Money.gt?(%Money{amount: 2, currency: :GBP}, %Money{amount: 1, currency: :GBP})
    refute Money.gt?(%Money{amount: 1, currency: :GBP}, %Money{amount: 2, currency: :GBP})
    refute Money.gt?(%Money{amount: 1, currency: :GBP}, %Money{amount: 1, currency: :GBP})
  end

  test "gt?/2 with incompatible currencies" do
    assert_raise Money.CurrencyError, "Currencies GBP and USD are not compatible", fn ->
      Money.gt?(%Money{currency: :GBP}, %Money{currency: :USD})
    end
  end

  test "gte?/2" do
    assert Money.gte?(%Money{amount: 2, currency: :GBP}, %Money{amount: 1, currency: :GBP})
    assert Money.gte?(%Money{amount: 1, currency: :GBP}, %Money{amount: 1, currency: :GBP})
    refute Money.gte?(%Money{amount: 1, currency: :GBP}, %Money{amount: 2, currency: :GBP})
  end

  test "gte?/2 with incompatible currencies" do
    assert_raise Money.CurrencyError, "Currencies GBP and USD are not compatible", fn ->
      Money.gte?(%Money{currency: :GBP}, %Money{currency: :USD})
    end
  end

  test "lt?/2" do
    assert Money.lt?(%Money{amount: 1, currency: :GBP}, %Money{amount: 2, currency: :GBP})
    refute Money.lt?(%Money{amount: 2, currency: :GBP}, %Money{amount: 1, currency: :GBP})
    refute Money.lt?(%Money{amount: 1, currency: :GBP}, %Money{amount: 1, currency: :GBP})
  end

  test "lt?/2 with incompatible currencies" do
    assert_raise Money.CurrencyError, "Currencies GBP and USD are not compatible", fn ->
      Money.lt?(%Money{currency: :GBP}, %Money{currency: :USD})
    end
  end

  test "lte?/2" do
    assert Money.lte?(%Money{amount: 1, currency: :GBP}, %Money{amount: 2, currency: :GBP})
    assert Money.lte?(%Money{amount: 1, currency: :GBP}, %Money{amount: 1, currency: :GBP})
    refute Money.lte?(%Money{amount: 2, currency: :GBP}, %Money{amount: 1, currency: :GBP})
  end

  test "lte?/2 with incompatible currencies" do
    assert_raise Money.CurrencyError, "Currencies GBP and USD are not compatible", fn ->
      Money.lte?(%Money{currency: :GBP}, %Money{currency: :USD})
    end
  end

  test "compare/2" do
    assert :eq == Money.compare(%Money{amount: 1}, %Money{amount: 1})
    assert :gt == Money.compare(%Money{amount: 2}, %Money{amount: 1})
    assert :lt == Money.compare(%Money{amount: 1}, %Money{amount: 2})
  end

  test "compare/2 with incompatible currencies" do
    assert_raise Money.CurrencyError, "Currencies GBP and USD are not compatible", fn ->
      Money.compare(%Money{currency: :GBP}, %Money{currency: :USD})
    end
  end

  test "abs/1" do
    assert %Money{amount: 5} = Money.abs(%Money{amount: -5})
    assert %Money{amount: 0} = Money.abs(%Money{amount: 0})
    assert %Money{amount: 2} = Money.abs(%Money{amount: 2})
  end

  test "add/2" do
    assert %Money{amount: 10} = Money.add(%Money{amount: 5}, %Money{amount: 5})
  end

  test "add/2 with incompatible currencies" do
    assert_raise Money.CurrencyError, "Currencies GBP and USD are not compatible", fn ->
      Money.add(%Money{currency: :GBP}, %Money{currency: :USD})
    end
  end

  test "sub/2" do
    assert %Money{amount: -5} = Money.sub(%Money{amount: 0}, %Money{amount: 5})
  end

  test "sub/2 with incompatible currencies" do
    assert_raise Money.CurrencyError, "Currencies GBP and USD are not compatible", fn ->
      Money.sub(%Money{currency: :GBP}, %Money{currency: :USD})
    end
  end
end
