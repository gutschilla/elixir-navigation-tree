defmodule NavigationTree.Mixfile do
  use Mix.Project

  def project do
    [app: :navigation_tree,
     version: "0.4.0",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package,
     description: description,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  def deps do
    [{:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.7", only: :dev}]
  end

  defp description do
    """
    A navigation tree representation with helpers to generate HTML out of it - depending of userroles. 
    Also creates nice HTML navbars for Bootstrap. Implemented as Agent to hold config state.
    """
  end

  defp package do
    [
     files: ["lib", "mix.exs", "README", "LICENSE", "test", "doc"],
     contributors: ["Martin Gutsch"],
     licenses: ["MIT"],
     links: %{
        "GitHub" => "https://github.com/gutschilla/elixir-navigation-tree"
      }
     ]
  end
end
