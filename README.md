# NavigationTree.Agent and NavigationTree.Server
An agent represing a navigation tree. The agent holds transformed configuration
state. NavigationTree.Server does exactly the same but is implemented as GenServer.

Provides convenience wrappers to generate Twitter/bootstrap-freindly
userrole-aware HTML out of this state through NavigationTree.Helper and
NavigationTree.Bootstrap.

Navigation tree nodes are to be configured as NavigationTree.Node structs.

## Terminology

__node__: A configuration struct looking like this:
```
%NavigationTree.Node{
    name: string, # the node's name, like "About Us"
    url: nil or string, # will be set on startup, but may be overridden
    controller: nil or string, # would be set to about-us, but may be overridden
    children:, nil or list of child nodes
    roles: nil or list of strings # role names a user must have to see this navigation item
}
```

__path__: A list of node names, e.g. ["Home", "Admin"]

__url__: Every node gets a url on start_link setup constructed out of its ancestors' url 
concatenated with "/<controller>" whereas <controller> is either a safe_string version of
the node's name or the specified controller namde in this node's config


# Basic usage
- create a config module or just use NavigationTree.Example
- Startup Agent or Server, possibly in your application setup
- create you HTML generator or use the shipped NavigationTree.Bootstrap module
- enjoy!

```
# startup
NavigationTree.Agent.start_link NavigationTree.Example.config

# getters
NavigationTree.Agent.get.tree
NavigationTree.Agent.get.paths
NavigationTree.Agent.get.root_node (initoal config)

# methods
NavigationTree.Agent.node_of ["Home","Admin"]
# same as
NavigationTree.Agent.node_of "/admin"
 
# reverse
NavigationTree.Agent.path_of "/admin" # returns ["Home","Admin"]

# HTML
NavigationTree.Agent.as_html [], :bootstrap
# returns HTML for unauthenticated user

NavigationTree.Agent.as_html ["admin", "customer"], :bootstrap 
# returns HTML for user with admin and customer role

# or your tree_to_html implementation:
MyApp.NavigationTree.Sidenav.tree_to_html NavigationTree.Agent.get.tree

```

# Documentation 
[Can be found here.](http://hexdocs.pm/navigation_tree/0.4.0/NavigationTree.Agent.html)

# Basics

Add this project both to your dependecies and to your app list (including configuration). [..]

# LICENSE
M.I.T.
