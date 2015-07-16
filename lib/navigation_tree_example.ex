# defmodule Navigation do
# 
#   require NavigationTree.Loader
#   alias NavigationTree.Node, as: Node
# 
#   NavigationTree.Loader.make_module(
#     Tree,
#     %Node{
#           name: "MYHome",
#           children: [
#               %Node{
#                   name: "MYLogin",
#                   url:  "/auth",
#               },
#               %Node{
#                   name: "MYProvate",
#                   url:  "/private",
#                   roles: ["user"]
#               },
#               %Node{
#                   name: "MYAdmin",
#                   roles: ["admin"],
#                   children: [
#                       %Node{ name: "MYUsers" },
#                       %Node{ name: "MYRoles" },
#                   ]
#               }
#           ]
#       }, 
#       fn( user_id ) when is_integer( user_id ) ->
#         [ "admin", "role_" <> Integer.to_string( user_id ) ]
#       end
#   );
# 
# end
