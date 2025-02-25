# UkTaxFreeChildcare

[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https%3A%2F%2Fgithub.com%2Fdideler%2Fuk-tax-free-childcare-account%2Fblob%2Fmain%2Flivebook.livemd)

Assists with deciding how much to pay into your UK Tax-Free Childcare Account.

> You can get up to £500 every 3 months (up to £2,000 a year) for each of your children to help with the costs of childcare.
> This goes up to £1,000 every 3 months if a child is disabled (up to £4,000 a year).
>
> If you get Tax-Free Childcare, you’ll set up an online childcare account for your child.
> For every £8 you pay into this account, the government will pay in £2 to use to pay your provider.

The user must enter the amount due, account balance, the remaining eligible bonus for the period, and the pay-in to bonus ratio.
These figures will be available on your [childcare accounts](https://www.gov.uk/sign-in-childcare-account).

### TODO
- Move to a livebook with kino ui
- Use safer money representation (money dep or build own module as a fun exercise)
  - See if it fixes this edge case rounding
  ```
  iex(1)> account = Childcare.Account.new(due: 906.10, bal: 209.52, rem: 290.48, rat: {8,2})
  %Childcare.Account{due: 906.1, bal: 209.52, rem: 290.48, rat: {8, 2}}
  iex(2)> Childcare.Account.PayInRecommender.suggest_pay_in(account, strat: :min_pay)
  {558.58,
   %Childcare.Account{
     due: 906.1,
     bal: 906.1,
     rem: 152.48000000000002,
     rat: {8, 2}
   }}
  ```
  - See if it fixes this bug as well
  ```
  iex(1)> account = Childcare.Account.new(due: 838.10, bal: 755.81, rem: 0, rat: {8,2})
  %Childcare.Account{due: 838.1, bal: 755.81, rem: 0, rat: {8, 2}}
  iex(2)> Childcare.Account.PayInRecommender.suggest_pay_in(account, strat: :max_bonus)
  {82.29000000000008,
  %Childcare.Account{due: 838.1, bal: 838.1, rem: 0.0, rat: {8, 2}}}
  iex(3)> Childcare.Account.PayInRecommender.suggest_pay_in(account, strat: :min_pay)
  # gets stuck with high cpu
  ```
- Add support for multiple dues
- Add a basic frontend
  - Kino for Livebook
  - https://github.com/livebook-dev/kino
  - https://gist.github.com/hugobarauna/018e1e487499249090bb30ed985eb764

### Example usage

```elixir
mix deps.get
iex -S mix

account = Childcare.Account.new(due: 1000.00, bal: 361.25, rem: 138.75, rat: {8,2})
Childcare.Account.PayInRecommender.suggest_pay_in(account, strat: :min_pay)
Childcare.Account.PayInRecommender.suggest_pay_in(account, strat: :max_bonus)
```

### Related
- https://github.com/martmacd/childcare-calc (does not fulfill my requirements)
- https://github.com/hmrc/cc-calculator/blob/main/README_TFC.md
- https://github.com/hmrc/childcare-calculator-frontend
