# DEPRECATION NOTICE
This whole module will be changed to an Elixir.Agent-based thing. See `as-agent` branch 

# elixir-navigation-tree
A navigation tree representation with helpers to generate HTML out of it - depending of userroles. Creates nice HTML navbars for Bootstrap.

# How to use
Of course, include elixir-navigation-tree to your project's dependecies.

In your mix.exs
```
  defp deps do
    [
        ...
        { :navigation_tree, ">= 0.1.0" }
    ]
  end
```

Then, createa navigation module like this (assuming MyApp as your Application's name):

lib/myapp/navigation_tree.ex
```
defmodule MyApp.Navigation do

  require NavigationTree.Loader
  alias NavigationTree.Node, as: Node

  NavigationTree.Loader.make_module(
    Tree,
    %Node{
          name: "Home",
          children: [
              %Node{
                  name: "Login",
                  url:  "/auth",
              },
              %Node{
                  name: "Private",
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
      
      # this is going to be removed 
      fn( user_id ) when is_integer( user_id ) ->
        
        # a function that translates user_id => ["role1", "role2", ... ]
        MyApp.get_userroles_for( user_id )
        
        # or if you use phoenix-skeleton:
        # MyApp.User.Helper.roles_of( MyApp.Repo.get Myapp.User, user_id )

      end
  );

end

```

# Usage (minimal draft)

The above module will create a module `MyApp.Navigation.Tree`.

## Functions

### tree
Returns the tree as data structure

### allowed_tree([ "role1", "role2", ... ])
Returns the accessible tree for a user with userroles "role1" and "role2"

### as_list
Returns the traversed tree as flat list of elements

```
[%{classes: ["nav navbar-nav"], ul_start: true}, %{classes: [], li_start: true},
 %{anchor: true, href: "/auth", text: "Login"}, %{li_stop: true},
 %{classes: [], li_start: true},
 %{anchor: true, href: "/private", text: "Private"}, %{li_stop: true},
 %{classes: ["before-dropdown"], li_start: true},
 %{anchor: true, href: "/myadmin", text: "Admin"}, %{li_stop: true},
 %{classes: ["dropdown"], li_start: true}, %{dropdown_toggle: true},
 %{classes: ["dropdown-menu"], ul_start: true}, %{classes: [], li_start: true},
 %{anchor: true, href: "/myadmin/myusers", text: "Users"}, %{li_stop: true},
 %{classes: [], li_start: true},
 %{anchor: true, href: "/myadmin/myroles", text: "Roles"}, %{li_stop: true},
 %{ul_stop: true}, %{li_stop: true}, %{ul_stop: true}]

```

## as HTML

Currently, this module spits out navigation bars for Bootstrap

### as_html(), as_html( user_id ), as_html( [ "role1", ..] )

layout.eex
```
<html>
    ...
   <body>

    <nav class="navbar navbar-default">
      <div class="container-fluid">
        <%= raw MyApp.NavigationTree.as_html_for( current_get_user_roles() ) %>
      </div>
    </nav>
    
    <div class="container">
      <%= @inner %>
    </div>

  </body>

</html>       
```



 



