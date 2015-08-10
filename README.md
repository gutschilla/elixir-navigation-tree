# NavigationTree.Agent

...

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
