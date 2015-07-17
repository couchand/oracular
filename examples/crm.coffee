# a crm example

@example ?= {}

@example.CRM =
  tables: [
    {
      table: "Account"
      parents: [
        { name: "Owner", table: "User" }
      ]
      fields: [
        { name: "Id" }
        { name: "OwnerId" }
        { name: "Type" }
      ]
    }
    {
      table: "Opportunity"
      parents: [
        { name: "Account" }
        { name: "Owner", table: "User" }
      ]
      fields: [
        { name: "Id" }
        { name: "AccountId" }
        { name: "OwnerId" }
        { name: "Type" }
        { name: "IsClosed",  type: "bool" }
        { name: "Amount",    type: "number" }
        { name: "CloseDate", type: "date" }
      ]
    }
    {
      table: "User"
      fields: [
        { name: "Id" }
        { name: "Type" }
      ]
    }
  ]
  specs: [
    {
      name: "needsCustomerUpdate"
      table: "Account"
      spec: "Account.Type = 'Prospect' AND ANY(Opportunity.IsClosed)"
    }
    {
      name: "hasRecentDeal"
      table: "Account"
      spec: "TODAY - LAST(Opportunity.CloseDate, Opportunity.IsClosed) < 60"
    }
    {
      name: "managerCustomer"
      table: "Account"
      spec: "Account.Type = 'Customer' AND Account.Owner.Type = 'Manager'"
    }
    {
      name: "proveOperatorPrecedence"
      table: "Account"
      spec: "Account.Type = 'Customer' AND Account.Type = 'Past Customer' OR Account.Owner.Type = 'Manager'"
    }
  ]
