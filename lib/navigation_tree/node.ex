defmodule NavigationTree.Node do
  defstruct \
    name: "",
      url:  nil,
      children: [],
      roles: [],
      controller: nil
end
