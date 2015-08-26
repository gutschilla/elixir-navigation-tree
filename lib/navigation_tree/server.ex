defmodule NavigationTree.Server do
  use GenServer

  #####
  # External API

  def start_link root_node do
    thawed = NavigationTree.Helper.thaw( root_node ) 
    GenServer.start_link(
      __MODULE__, 
      %{
        root_node: root_node,
        tree:      thawed.tree,
        paths:     thawed.paths
      },
      name: __MODULE__
    )
  end

  def get do
    GenServer.call __MODULE__, :get
  end

  def node_of( path ) when is_list( path ) do
    data = get
    case data.paths[ path ] do
      nil -> nil
      _   -> NavigationTree.Helper.at( data.tree, path )
    end
  end

  @doc """
  Returns node at given path. Path must be a either

   - A list of node names traversing the stree starting with root node's name
   - An URL string. URL must be absolute e.g. "/admin/users"
  """
  def node_of( url ) when is_binary( url ) do
    node_of( path_of url )
  end

  @doc """
  Returns node path for given url
  """
  def path_of( url ) when is_binary( url ) do
    data = get
    [ paths, urls ] = data.paths |> Map.to_list |> List.zip
    index = urls |> Tuple.to_list |> Enum.find_index( fn find_url -> find_url == url end  )
    path = case index do
      nil -> nil
      _   -> Enum.at( Tuple.to_list( paths ), index )
    end
  end

  @doc """
  Return an HTML string suitable to fit in a navbar in a Twitter/Bootstrap
  environment. 

   - roles must be a list of user roles (strings)
   - atom2 must be either
     - :bootstrap (currently the only supported framework)
     - a module implementing tree_to_html( tree, roles )

  """
  def as_html( roles, :bootstrap ) when is_list( roles ) do
    NavigationTree.Bootstrap.tree_to_html get.tree, roles
  end

  #####
  # GenServer implementation

  def handle_call :get, _from, state do
    { :reply, state, state }
  end


end
