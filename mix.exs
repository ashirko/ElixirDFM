defmodule DFM.MixProject do
  use Mix.Project

  def project do
    [
      app: :dfm,
      version: "0.1.0",
      elixir: "~> 1.14.0",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.18", only: :docs},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev], runtime: false},
      {:nimble_csv, "~> 1.2.0"},
      {:timex, "~> 3.7.0"},
      {:flow, "~> 1.2.0"}
    ]
  end
end
