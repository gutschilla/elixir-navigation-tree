defmodule NavigationTreeTest do
  use ExUnit.Case

  defp root_node do    
    NavigationTree.Example.config
  end

  def init_node, do: NavigationTree.Agent.start_link( root_node )
  def stop_node, do: NavigationTree.Agent.stop

  test "start/stop node" do
    { :ok, _pid } = init_node 
    :ok = stop_node
  end
    
  test "Helper.thaw" do
    { :ok, _pid } = init_node # start again for later tests
    %{ tree: tree, paths: paths, root_node: my_root_node } = NavigationTree.Agent.get
    assert my_root_node == root_node
    assert length( Map.keys paths ) == 5 # home, login, admin, admin/users, admin/roles
    assert tree.name == "Home"
    assert Enum.at( tree.children, 0 ).name == "Login" 
    assert Enum.at( tree.children, 1 ).name == "Admin" 
  end

  test "Agent.node_of and roles" do
    { :ok, _pid } = init_node # start again for later tests
    assert NavigationTree.Agent.node_of(["Home", "Login"]) == NavigationTree.Agent.node_of("/auth")
    assert NavigationTree.Agent.node_of(["Home", "Admin", "Users"]).name == "Users"
    assert NavigationTree.Agent.node_of(["Home", "Admin", "Users"]).roles == ["admin", "user_admin"]
  end

  test "Agent.parent_of" do
    { :ok, _pid } = init_node # start again for later tests
    admin = ( NavigationTree.Agent.parent_of ["Home", "Admin", "Users" ] )
    assert admin.name == "Admin"
    assert NavigationTree.Agent.path_of( admin.url ) == ["Home", "Admin"]
  end

  test "Agent.next_sibling" do
    { :ok, _pid } = init_node # start again for later tests
    roles = NavigationTree.Agent.next_sibling ["Home", "Admin", "Users" ]
    assert roles.name == "Roles"
    assert NavigationTree.Agent.path_of( roles.url ) == ["Home", "Admin", "Roles"]
    assert ( NavigationTree.Agent.next_sibling ["Home", "Admin", "Roles" ] ) == nil
    
    login = NavigationTree.Agent.previous_sibling ["Home", "Admin"]
    assert login.name == "Login"
  end

    

end
