<%= name.capitalize %> Terraform module
===========

(Insert description of module here)


Module Input Variables
----------------------

- `tags` A map of tags that can be used for resource tagging and for naming must include, team, product, service, environment, owner. See usage example.
- `foo` A foo input
- `bar` A bar input

Usage
-----

```
module "<%= name %>" {
  source = "git::ssh://git@github.com/tf/<%= name %>.git?ref=v0.0.1"

  tags = {
    team        = "platform"
    product     = "silverbullet"
    service     = "<%= name %>"
    environment = "dev"
    owner       = "insertyouremail@here.com"
  }

  addyourinputs = "more"
  foo           = "value"
  bar           = "VALIS"
}
```

Outputs
=======

- `example_1` - description of output 
- `example_2` - description of output
