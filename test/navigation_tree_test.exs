defmodule NavigationTreeTest do
  use ExUnit.Case

  alias NavigationTree.Node, as: Node

  defp root_node do    
    %Node{
      url:  "/", # this is important, otherwise all urls will start with "/home"
      name: "Home",
      children: [
        %Node{
          name: "Login",
          url:  "/auth",
        },
        %Node{
          name: "Admin",
          roles: ["admin"],
          children: [
            %Node{ name: "Users", roles: ["user_admin"] },
            %Node{ name: "Roles"},
          ]
        }
      ]
    }
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

end
