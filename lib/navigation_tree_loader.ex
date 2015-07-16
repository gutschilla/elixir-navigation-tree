defmodule NavigationTree.Loader do

  defmacro make_module( name, given_config, get_roles_fn ) do
    quote do
      defmodule unquote( name ) do
        
        def config do
          unquote given_config
        end

        def roles_of( user_id ) when is_integer( user_id ) do
          apply( unquote( get_roles_fn ), [ user_id ] )
        end

        def tree do
          NavigationTree.thaw config
        end

        def as_list do
          NavigationTree.as_list tree, 0
        end

        def as_html do
          as_list |> NavigationTree.as_html
        end

        def allowed_tree( userroles ) do
            NavigationTree.allowed_tree( userroles, tree )
        end

        def as_html_for( roles ) when is_list( roles ) do 
          allowed_tree( roles )
          |> NavigationTree.as_list( 0 )
          |> NavigationTree.as_html
        end

        def as_html_for( user_id ) when is_integer( user_id ) do
          roles = roles_of( user_id )
          as_html_for( roles )
        end

      end
    end
  end

end
