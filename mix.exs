defmodule UkTaxFreeChildcare.MixProject do
  use Mix.Project

  def project do
    [
      app: :uk_tax_free_childcare,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:money_ex, "~> 0.2.0"}
    ]
  end
end
