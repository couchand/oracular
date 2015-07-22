# an example with errors

@example ?= {}

@example.errors =
  tables: [
    {
      table: "Foobar"
      fields: [
        { name: "Id" }
      ]
    }
  ]
  specs: [
    {
      name: "specWithTableError"
      table: "Account"
      spec: "Account.Type = 'Customer'"
    }
    {
      name: "specWithRootError"
      table: "Foobar"
      spec: "User.Type = 'Manager'"
    }
    {
      name: "specWithFieldError"
      table: "Foobar"
      spec: "Foobar.Type = 'Customer'"
    }
    {
      name: "specWithTypeError"
      table: "Foobar"
      spec: "Foobar.Id = 42"
    }
  ]
