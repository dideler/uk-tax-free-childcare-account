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
    refute Money.equals?(%Money{amount: 1, currency: :GBP}, %Money{amount: 1, currency: :USD})
    refute Money.equals?(%Money{amount: 0, currency: :GBP}, %Money{amount: 1, currency: :GBP})
  end
end
