defmodule NavigationTree.Agent do

@vsn "0.4.1"
@moduledoc """
An agent represing a navigation tree. The agent holds transformed configuration
state.

Provides convenience wrappers to generate Twitter/bootstrap-freindly
userrole-aware HTML out of this state through NavigationTree.Helper and
NavigationTree.Bootstrap.  

Navigation tree nodes are to be configured as NavigationTree.Node structs.

## Examples
### Configure and start agent

    iex> alias NavigationTree.Node, as: Node
    nil

    iex> NavigationTree.Agent.start_link %Node{
      name: "Home",
      url:  "/",
      children: [
        %Node{ name: "Login", url: "/auth" },
        %Node{
          name:  "Admin",
          roles: ["admin"],
          children: [
            %Node{ name: "Users", roles: ["user_admin"] },
            %Node{ name: "Roles" }
          ]
        }
      ]
    }
    {:ok, #PID<0.120.0>}

### get tree node by path hopping through tree

    iex> NavigationTree.Agent.node_of ["Home", "Admin", "Users"]
    %{children: [], controller: nil, name: "Users", roles: ["admin", "user_admin"], url: "/admin/users"}

### generate bootstrap-style HTML for a user that has userroles ["admin"]

      iex> NavigationTree.Agent.as_html ["admin"], :bootstrap
      \"\"\"
        <ul class="nav navbar-nav">
          <li><a href="/auth">Login</a></li>
          <li class="dropdown">
            <a href="#">Admin</a>
            <ul class="dropdown-menu">
              <li><a href="/admin/roles">Roles</a></li>
            </ul>
          </li>
        </ul>
      \"\"\"
"""

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
  case index do
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

@doc """
Returns the next sibling (next child of parent) or nil
"""
def next_sibling( path ) when is_list( path ) do
    next_sibling path, 1
end
# node w/o parent (the root node) has no siblings
def next_sibling( [ _single ], _num ), do: nil

def next_sibling( path, num, op \\ &Elixir.Kernel.+/2 ) do
  node = node_of( path )
  [ _node_name | reversed_parent_path ] = Enum.reverse path
  parent = node_of( Enum.reverse reversed_parent_path )
  node_index = Enum.find_index parent.children, fn child ->
    child == node
  end
  
  # Enum.at [1,2,3], -1 whould return 3, but I want it to be nil
  if ( op == &Elixir.Kernel.-/2 ) && ( num > node_index ) do
    nil
  else
    Enum.at parent.children, op.( node_index, num )
  end

end

@doc """
Returns the previous sibling (previous child of parent) or nil
"""
def previous_sibling( path ) do
  previous_sibling( path, 1 )
end
def previous_sibling( path, num ) do
  next_sibling( path, num, &Elixir.Kernel.-/2 )
end

end
