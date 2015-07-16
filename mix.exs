defmodule NavigationTree.Mixfile do
  use Mix.Project

  def project do
    [app: :navigation_tree,
     version: "0.1.0",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.0",
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
  # To depend on another app inside the umbrella:
  #
  #   {:myapp, in_umbrella: true}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    []
  end

  defp description do
    """
    A navigation tree representation with helpers to generate HTML out of it - depending of userroles. 
    Also creates nice HTML navbars for Bootstrap.
    """
  end
  
  defp package do
    [# These are the default files included in the package
     files: ["lib", "mix.exs", "README", "LICENSE", "test"],
     contributors: ["Martin Gutsch"],
     licenses: ["MIT"],
     links: %{
        "GitHub" => "https://github.com/gutschilla/elixir-navigation-tree.git"
        # "Docs" => "http://ericmj.github.io/postgrex/"
      }
     ]
  end

end
