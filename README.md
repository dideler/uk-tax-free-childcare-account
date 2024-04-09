# UkTaxFreeChildcare

Assists with deciding how much to pay into your UK Tax-Free Childcare Account.

> You can get up to £500 every 3 months (up to £2,000 a year) for each of your children to help with the costs of childcare.
> This goes up to £1,000 every 3 months if a child is disabled (up to £4,000 a year).
>
> If you get Tax-Free Childcare, you’ll set up an online childcare account for your child.
> For every £8 you pay into this account, the government will pay in £2 to use to pay your provider.

The user must enter the amount due, account balance, the remaining eligible bonus for the period, and the pay-in to bonus ratio.
These figures will be available on your [childcare accounts](https://www.gov.uk/sign-in-childcare-account).

### TODO
- Use safer money representation (money dep or build own module as a fun exercise)
- Add support for multiple dues
- Add a basic frontend

### Example usage

```elixir
iex -S mix

account = Childcare.Account.new(due: 1000.00, bal: 361.25, rem: 138.75, rat: {8,2})
Childcare.Account.PayInRecommender.suggest_pay_in(account, strat: :min_pay)
Childcare.Account.PayInRecommender.suggest_pay_in(account, strat: :max_bonus)
```

### Related
- https://github.com/martmacd/childcare-calc (does not fulfill my requirements)
- https://github.com/hmrc/cc-calculator/blob/main/README_TFC.md
- https://github.com/hmrc/childcare-calculator-frontend
