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
      spec: "TODAY - 60 < LAST(Opportunity.CloseDate, Opportunity.IsClosed)"
    }
    {
      name: "isManager"
      table: "User"
      spec: "User.Type = 'Manager'"
    }
    {
      name: "managerCustomer2"
      table: "Account"
      spec: "Account.Type = 'Customer' AND isManager(Account.Owner)"
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
