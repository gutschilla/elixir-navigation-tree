defmodule Navigation do

  require NavigationTree.Loader
  alias NavigationTree.Node, as: Node

  NavigationTree.Loader.make_module(
    Tree,
    %Node{
          name: "MYHome",
          children: [
              %Node{
                  name: "MYLogin",
                  url:  "/auth",
              },
              %Node{
                  name: "MYPrivate",
                  url:  "/private",
                  roles: ["user"]
              },
              %Node{
                  name: "MYAdmin",
                  roles: ["admin"],
                  children: [
                      %Node{ name: "MYUsers" },
                      %Node{ name: "MYRoles" },
                  ]
              }
          ]
      }, 
      fn( user_id ) when is_integer( user_id ) ->
        [ "admin", "role_" <> Integer.to_string( user_id ) ]
      end
  );

end

defmodule NavigationTreeTest do
  use ExUnit.Case

  test "traversing the tree" do
    tree = Navigation.Tree.tree;
    assert tree.name == "MYHome";
    {:ok, login } = Enum.fetch tree.children, 0;
    assert login.name == "MYLogin";
    # same in a complex notation
    assert ( tree.children |> Enum.fetch(1) |> elem 1 ).name == "MYPrivate"
  end
  
  test "allowed tree" do
    tree       = Navigation.Tree.allowed_tree([])
    admin_tree = Navigation.Tree.allowed_tree(["admin"]);
    assert length( admin_tree.children ) == 2
    # there must be missing the admin section
    assert length( tree.children ) == 1
  end
  
end
