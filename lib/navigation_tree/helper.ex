defmodule NavigationTree.Helper do

  def thaw( node ) do
    # note that root node's url is "/", but setting parent_url to ""
    # to avoid double slashes in front of other urls
    thawed = thaw( 
      node, # node
      "",  # parent_url
      [],   # parent_name_path
      [],   # parent_roles
      %{}   # paths accumulator
    )
    %{
      paths: thawed.paths_acc,
      tree:  Map.delete( thawed, :paths_acc )
    }
  end

  defp double x do 
    { x, x } 
  end

  def join_slash parent \\ "", child \\ "" do
    String.replace( parent, ~r{/$}, "" ) <> "/" <> String.replace( child, ~r{^/}, "" ) 
  end

  def thaw( 
    node, 
    parent_url,
    parent_name_path, 
    parent_roles,
    paths_acc
  ) do

    controller = node.controller || safe_name( node.name )
    { next_parent_url, url } = cond do
        node.url                          -> { parent_url, node.url }  # keep parent_url for direct/external links
        String.first( controller ) == "/" -> double( controller )      # set parent to controller if absolute path
        true                              -> double( join_slash( parent_url, controller ) )
    end

    roles = parent_roles ++ node.roles
    node_name_path = parent_name_path ++ [ node.name ]
    paths_acc = Map.put( paths_acc, node_name_path, url )

    children = Enum.map(
        node.children,
        fn( child ) ->
            thaw( child, next_parent_url, node_name_path, roles, paths_acc )
        end
    )
    # add children's path to ours
    children_accs = Enum.map( children, fn( child ) -> child.paths_acc end  )
    children_acc  = List.foldl( children_accs, %{}, fn( x, acc ) -> Map.merge( acc, x ) end )
    paths_acc = Map.merge( paths_acc, children_acc )

    %{ node |
      url:      url,
      roles:    roles,
      children: Enum.map( children, fn( child) -> Map.delete( child, :paths_acc ) end ),
    } 
    |> Map.put( :paths_acc, paths_acc )
    |> Map.delete( :"__struct__" )

  end

  @doc """
  Replaces German Umlauts äöü and ß with ae oe ue, 
  downcases the string and replaces all nonword sequences to "-"
  
  ## Example
    
    iex> NavigationTree.Helper.safe_name "Hane Büchener     Unsinn"
    "hane-buechener-unsinn"

  """
  @spec safe_name( String.t ) :: String.t
  def safe_name( name ) do
    name 
    |> String.replace( ~r/[^[:graph:]]/, "-" )
    |> String.downcase
    |> String.replace( "ä", "ae" )
    |> String.replace( "ü", "ue" )
    |> String.replace( "ö", "oe" )
    |> String.replace( "ß", "ss" )
    |> String.replace( ~r/[^0-9A-z]+/, "-")
  end

  # this is a very naive approach but it's workuing and I am in a hurry
  def at2( node, [ last ] ) do
    # IO.inspect({:last, node.name, last })
    case node.name == last do
      true  -> node
      false -> nil
    end
  end
  def at2( node, [ head | tail ] ) do
    # IO.inspect({:headtail, node.name, [ head | tail ] })
    case node.name == head do
      true  -> Enum.map( node.children, fn child -> at( child, tail ) end )
      false -> nil
    end
  end

  @doc """
  Traverses the tree searching for the names given in list.
  """
  def at( node, list ) do
    [ at2( node, list) ]
    |> List.flatten
    |> Enum.find( fn item -> item != nil end )
  end

end
