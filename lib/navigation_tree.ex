defmodule NavigationTree.Node do
    defstruct \
        name: "",
        url:  nil,
        children: [],
        roles: []
end

defmodule NavigationTree do

    alias NavigationTree.Node, as: Node

    def config() do
      throw NavigationTree.CONFIG_NOT_OVERLOADED
        %Node{
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
                        %Node{ name: "Users" },
                        %Node{ name: "Roles" },
                    ]
                }
            ]
        }
    end

    def tree() do
        thaw config
    end

    def thaw( node ) do
        # note that root node's url is "/", but setting parent_url to ""
        # to avoid double slashes in front of other urls
        thaw node, "", []
    end

    def thaw( node, parent_url, parent_roles ) do

        url = cond do
            node.url          -> node.url
            parent_url == ""  -> "/"
            parent_url == "/" -> ( "/" <> safe_name( node.name ) )
            true              -> ( parent_url <> "/" <> safe_name( node.name ) )
        end

        roles = parent_roles ++ node.roles

        children = Enum.map(
            node.children,
            fn( child ) ->
                thaw( child, url, roles )
            end
        )

        %{ node |
            url:      url,
            roles:    roles,
            children: children
        }

    end

    def safe_name( name ) do
        String.downcase( name )
    end

    def allowed_tree( userroles ) do
        allowed_tree( userroles, tree() )
    end

    def allowed_tree( userroles, node ) do
        %Node{ node |
            children: Enum.filter(
                node.children,
                fn( child ) ->
                    needed = Enum.into child.roles, HashSet.new
                    having = Enum.into userroles,   HashSet.new
                    # needed minus having shall be empty
                    result = Set.difference( needed, having )
                    Set.size( result ) == 0
                end
            )
        }
    end

    def as_simple_hash( node, level ) do
        %{
            name:  node.name,
            url:   node.url,
            level: level,
            has_children: case length node.children do 0 -> false; _ -> true end
        }
    end

    def as_list() do
        # using as_list2, now
        as_list tree, 0
    end
    def as_list( tree ) do
        # using as_list2, now
        as_list tree, 0
    end

    def as_list( node, 0 ) do
        List.flatten [
            %{ ul_start: true, classes: ["nav navbar-nav"] },
            li_children( node, 0 ),
            %{ ul_stop: true },
        ]
    end
    def as_list( node, level ) do
        List.flatten [
            %{ ul_start: true, classes: ["dropdown-menu"] },
            li_children( node, level ),
            %{ ul_stop: true },
        ]
    end

    def li_children( node, level ) do
        Enum.map node.children, fn( n ) ->
            case length( n.children ) do
                0 -> [
                    %{ li_start: true, classes: [] },
                    %{ anchor:   true, href: n.url, text: n.name },
                    %{ li_stop:  true },
                ]
                _ -> [
                    # first, the menu item
                    %{ li_start: true, classes: ["before-dropdown"]},
                    %{ anchor:   true, href: n.url, text: n.name },
                    %{ li_stop:  true },

                    # second, the dropdown-toggle and the dropdown
                    %{ li_start: true, classes: ["dropdown"]},
                    %{ dropdown_toggle: true },
                    as_list( n, level + 1 ), # ul inside
                    %{ li_stop:  true },
                ]
            end
        end
    end

  def roles_of( _user_id ) do
    ["user"]
    # replace with something useful like this
    # Skeleton.User.Helper.roles_of( Skeleton.Repo.get Skeleton.User, user_id )
  end

  def as_html( list ) when is_list( list ) do
    list = Enum.map list, &as_html/1
    Enum.join list, "\n"
  end

  # this if for bootstrap navbars
  def as_html( item ) when is_map( item ) do
    case item do
        %{ ul_start: true } -> ~s(<ul class=\"#{ Enum.join( item.classes, " " ) }\">)
        %{ anchor:   true } -> ~s(<a href="#{ item.href }">#{ item.text }</a>)
        %{ li_start: true } -> ~s(<li class=\"#{ Enum.join( item.classes, " " ) }\">)
        %{ ul_stop:  true } -> ~s(</ul>)
        %{ li_stop:  true } -> ~s(</li>)
        %{ dropdown_toggle: true } -> ~s(<a href="#" class="dropdown-toggle " data-toggle="dropdown"><b class="caret"></b></a>)
      end
  end

  def as_html do
    as_list |> as_html
  end

  def as_html_for( roles ) when is_list( roles ) do 
    allowed_tree( roles )
    |> as_list( 0 )
    |> as_html
  end

  def as_html_for( user_id ) when is_integer( user_id ) do
    roles = roles_of( user_id )
    as_html_for( roles )
  end

end
