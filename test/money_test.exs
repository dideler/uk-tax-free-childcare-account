defmodule MoneyTest do
  use ExUnit.Case

  test "zero?/1" do
    assert Money.zero?(%Money{amount: 0})
    refute Money.zero?(%Money{amount: 1})
    refute Money.zero?(%Money{amount: -1})
  end
end
