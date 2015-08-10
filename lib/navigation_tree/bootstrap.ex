defmodule NavigationTree.Bootstrap do

  @vsn "0.2.0"
  @moduledoc """
  Converts a navigation tree into an HTML string that fits into 
  Twitter/Bootstraps "navbar-nav" schema for ULs.
  
  See http://getbootstrap.com/components/#navbar

  """

  @doc "Converts tree to a list of keword lists; each representing a tag"
  def as_list( tree ) do
      as_list tree, 0
  end
  def as_list( node, level ) do
       [[ tag: :ul, state: :open, level: level ]]
    ++ li_children( node, level )
    ++ [[ tag: :ul, state: :close ]]
  end

  def li_children( node, level ) do
    List.foldl(
      node.children, [], fn( n, acc ) ->
        acc ++ case length( n.children ) do
          0 -> [
            [ tag: :li, state: :open, leaf: true ],
            [ tag: :a,  state: :autoclose, href: n.url, text: n.name ],
            [ tag: :li, state: :close ]
          ]
          _ -> [
            # first, the menu item
            [ tag: :li, state: :open, leaf: false ],
            [ tag: :a,  state: :autoclose, href: :toggle, text: n.name ],
          ] 
          ++ as_list( n, level + 1 ) # ul inside
          ++ [[ tag: :li, state: :close ]]
        end
      end
    )
  end

  @doc "Converts the tree to HTML"
  def as_html( list ) do
    list = Enum.map list, &item_as_html/1
    Enum.join list, "\n"
  end

  @doc "Converts a single tag represented as keyword list into an HTML string"
  def item_as_html [ tag: :ul, state: :open, level: 0 ] do
    ~s[<ul class="nav navbar-nav">]
  end
  def item_as_html [ tag: :ul, state: :open, level: _level ] do
    ~s[<ul class="dropdown-menu">]
  end
  def item_as_html [ tag: :li, state: :open, leaf: false ] do
    ~s[<li class="dropdown">]
  end
  def item_as_html [ tag: :li, state: :open, leaf: true ] do
    ~s[<li>]
  end
  def item_as_html [ tag: tag, state: :close ] do
    "</#{ to_string tag }>"
  end
  def item_as_html [ tag: :a, state: :autoclose, href: :toggle, text: text ] do
    ~s[<a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">#{ text } <span class="caret"></span></a>]
  end
  def item_as_html [ tag: :a, state: :autoclose, href: href, text: text ] do
    ~s[<a href="#{ href }">#{ text }</a>]
  end

  @doc "Transforms a navigation tree into HTML, ignoring userrole settings"
  def tree_to_html( tree ) do
    as_list( tree ) |> as_html
  end

  @doc "Tronsdorms an navigation tree into HTML, strips off parts that aren't allowed for current userroles"
  def tree_to_html( tree, roles ) when is_list( roles ) do
    NavigationTree.Helper.allowed_tree( tree, roles )
    |> as_list
    |> as_html
  end

end
