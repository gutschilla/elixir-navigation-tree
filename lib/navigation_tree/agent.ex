defmodule NavigationTree.Agent do

@name __MODULE__

def init_opts( root_node ) do
  thawed = NavigationTree.Helper.thaw( root_node ) 
  %{
    root_node: root_node,
    tree:      thawed.tree,
    paths:     thawed.paths
  }
end

def start_link( root_node ) do
  Agent.start_link( __MODULE__, :init_opts, [ root_node ], name: @name  )
end

def stop do
  Agent.stop @name
end

def get do
  Agent.get( @name, fn( data ) -> data end )
end

def node_of( path ) when is_list( path ) do
  data = get
  case data.paths[ path ] do
    nil -> nil
    _   -> NavigationTree.Helper.at( data.tree, path )
  end
end

def node_of( url ) when is_binary( url ) do
  data = get
  [ paths, urls ] = data.paths |> Map.to_list |> List.zip
  index = urls |> Tuple.to_list |> Enum.find_index( fn find_url -> find_url == url end  )
  path = case index do
    nil -> nil
    _   -> Enum.at( Tuple.to_list( paths ), index )
  end
  node_of( path )
end

end
