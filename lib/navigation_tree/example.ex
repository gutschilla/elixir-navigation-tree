defmodule NavigationTree.Example do
  alias NavigationTree.Node

  def config do    
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

end
