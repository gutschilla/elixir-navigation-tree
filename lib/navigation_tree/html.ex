defmodule NavigationTree.HTML do

  alias NavigationTree.Node, as: Node

  def as_simple_hash( node, level ) do
    %{
        name:  node.name,
        url:   node.url,
        level: level,
        has_children: case length node.children do 0 -> false; _ -> true end
    }
  end
  
  def as_list( tree ) do
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

  def tree_to_html( tree ) do
    as_list( tree ) |> as_html
  end

  def as_html_for( tree, roles ) when is_list( roles ) do 
    allowed_tree( tree, roles )
    |> as_list( 0 )
    |> as_html
  end
  
  def allowed_tree( node, userroles ) do
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
  
end
