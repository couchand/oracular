oracular
========

a query builder

  * intro
  * getting started
  * syntax
    * tables
    * specs
    * specification language
  * lowering

[![Build Status](https://travis-ci.org/couchand/oracular.svg?branch=master)](https://travis-ci.org/couchand/oracular)

intro
-----

***oracular*** is a little query builder based on the specification
pattern and oriented towards business users.  The goal is to refactor
business logic in such a way that it can be easily stored and used to
drive the execution of business applications.

getting started
---------------

In its most basic form an ***oracular*** installation is just a single
config file.  To help get you started, some examples are included.

syntax
------

The syntax of the config file is relatively straightforward, so once
you get used to it editing the file directly shouldn't be too hard,
however, ***oracular*** provides tools to help assist manipulation of
the config that are much more user-friendly.

The syntax is transmitted as JSON.  The top-level object has two
properties: `tables` and `specs`.  Each of these is an array of config
objects.

```coffeescript
config =
  tables: [
    # table configuration
  ]

  specs: [
    # spec configuration
  ]
```

### tables

The table configuration objects have four properties: `table`, the
name of the table; `id`, the table identity field; `parents`, a list
of parent table configuration objects; and `fields`, a list of the
configuration for the data fields. The id is optional and defaults
to `Id`, and the parent table configuration is optional.  The id must
match one of the available fields.

```coffeescript
accountTable =
  table: 'Account'
  id: 'Id' # the default

  parents: [
    # parent configuration
  ]

  fields: [
    # field configuration
  ]
```

The parent table object has three properties: `name`, the name of the
parent relationship field on the table; `id`, the id field on the
table to use for the join; and `table`, the table to join against.  The
table and id are optional, table defaults to the name, and id defaults
to name plus 'Id'.  The id must match one of the available fields.

```coffeescript
parentAccountReference =
  name: 'ParentAccount'
  name: 'ParentAccountId' # the default
  table: 'Account'

ownerReference =
  name: 'Owner'
  table: 'User'
```

The field object has two properties: `name`, the field name; and `type`,
the type of the field.  The type is one of `'string'`, `'number'`,
`'bool'` or `'date'`, and is optional, defaulting to string.

```coffeescript
typeField =
  name: 'Type'

createdDateField =
  name: 'CreatedDate'
  type: 'date'
```

### specs

The spec configuration objects have three properties: `name`, the name
to use to refer to the spec; `table`, the root table of the spec; and
`spec`, the actual specification expression itself.

```coffeescript
isCustomerSpec =
  name: 'isCustomer'
  table: 'Account'
  spec: 'Account.Type = "Customer"'
```

The specification language deserves a section of its own.

### specification language

The specification language is a typed predicate builder.  *Typed* means
that we statically check the types of each subexpression and verify
that they are all combined in legal ways.  *Predicate* implies that the
top-level type of a spec expression is a boolean value: true or false.

The simplest expression type is a field specification on the root table
of the spec.  For instance, with the `Account` table defined above,

```coffeescript
# customer spec
Account.Type = "Customer"

# has parent spec
Account.ParentAccountId != null

# created in the future spec??
Account.CreatedDate > TODAY
```

As you can see, a field spec uses a binary boolean-valued operator,
one of `=`, `!=`, `<`, `<=`, `>`, and `>=`.  In each case,
one side is the name of the field (dot-referenced on the root
object), and the other side is a literal of the same type.  In these
examples we used the string `"Customer"`, the special value `null`
(meaning no value), and the built-in `TODAY`, which is the current date.

Specs can also use binary math, again with the requirement that both
sides be the same type, and with not all functions available on all
types.  For instance,

```coffeescript
# created in the last 30 days
TODAY - 30 < Account.CreatedDate

# total price above the limit
LineItem.UnitPrice * LineItem.Quantity > 100
```

Building on this are logical operations on specs: conjunction
`AND`, disjunction `OR`, negation `NOT()`, and selection `SELECT()`.
For example,

```coffeescript
# not a customer
NOT(Account.Type = "Customer")

# customer created this month
Account.Type = "Customer" AND TODAY - Account.CreatedDate < 30

# manager or exec
User.Type = "Manager" OR User.Type = "Exec"
```

This last example could also be replaced by the `IN` operator, which
checks a field against a list of options:

```coffeescript
# manager or exec, version 2
User.Type IN ("Manager", "Exec")
```

Selection allows you to pick one of two options, which is useful for
swapping out parts of an expression.  If the first parameter is true,
the second parameter is checked, and otherwise the last parameter is.

```coffeescript
# needs customer update
SELECT(
  # if the account is a customer
  Account.Type = "Customer",

  # then check if the last order rolled off
  LAST(Opportunity.CloseDate, Opportunity.IsWon) < TODAY + 90,

  # else check if a new order rolled on
  TODAY + 90 < LAST(Opportunity.CloseDate, Opportunity.IsWon)
)
```

Field references can step through a record's parent objects by
dot-referencing the parent relationship by name.

```coffeescript
# owner is manager
Account.Owner.Type = "Manager"
```

The most complicated type of expression is a reduction over the child
objects.  These come in a few flavors: the predicates `ANY()`, `ALL()`,
and `NONE()`, and the reducers `FIRST()`, `LAST()`, `LARGEST()`, and
`SMALLEST()`.  They all require at least one parameter, a reference to
the child table or field to join.  You can also add a second parameter
for additional criteria on the child object.  For instance, doing a
query over the user table that account points to:

```coffeescript
# manager with a customer
User.Type = "Manager" AND ANY(Account, Account.Type = "Customer")

# manager with no accounts
User.Type = "Manager" AND NONE(Account)

# customer with recent deals
Account.Type = "Customer"
  AND
TODAY - LAST(Opportunity.CloseDate, Opportunity.IsClosed) < 60

# customers with big deals
Account.Type = "Customer"
  AND
LARGEST(Opportunity.Amount, Opportunity.IsClosed) > 100000
```

As you can see, for the predicates `ANY`, `ALL` and `NONE` you just
reference the child table directly.  The date reducers `FIRST` and
`LAST` require a reference to a date field on the child record, and the
numeric reducers `LARGEST` and `SMALLEST` require a child's number
field.  The child table specified must have a parent relationship to
the root table of the specification, and this relationship is used to
construct the natural join.

If these were the only tools we had our specifications would grow large
quickly -- business logic tends to be pretty messy.  Fortunately, we
also have a tool for abstraction: since every spec has a name, you can
refer to one spec from another.  For instance, we could define:

```coffeescript
specs = [
  {
    name: 'isManager'
    table: 'User'
    spec: 'User.Type = "Manager"'
  }
  {
    name: 'isCustomer'
    table: 'Account'
    spec: 'Account.Type = "Customer"'
  }
  {
    name: 'customerWithManagerOwner'
    table: 'Account'
    spec: 'isCustomer(Account) AND isManager(Account.Owner)'
  }
  {
    name: 'managersWithCustomers'
    table: 'User'
    spec: 'isManager(User) AND ANY(isCustomer(Account))'
  }
]
```

This way we can break down the business logic into little testable bits.
As you can see, the joins are automatically made based on the defined
relationships.  It is an error to define on a table more than one parent
relationship to any given table.

### higher-order specs

It would be great to add support for higher-order spec handling.  For
instance, the above example `managersWithCustomers` could be rewritten
as `isManager AND ANY(isCustomer)`.  Since the `isManager` spec has the
same root table as the current spec, we know it means `isManager(User)`,
and since `isCustomer`'s root table has a parent relationship to the
root of the current spec, we know the `ANY` should join on that.

This would also be quite useful for `SELECT`:

```coffeescript
SELECT(isCustomer(Account), customerSpec(Account), nonCustomerSpec(Account))
```

versus

```coffeescript
SELECT(isCustomer, customerSpec, nonCustomerSpec)
```

lowering
--------

In the example `ANY(isCustomer(Account))`, the query is built by
checking the `Account` table for a parent relationship to the root of
the current query, the `User` table.  One is indeed found, the `Owner`
relationship based on `OwnerId`, so the join is performed on that field.
Thus, it could be lowered to the following SQL:

```sql
SELECT u.Id
FROM User u
LEFT JOIN Account a ON a.OwnerId = u.Id
WHERE
  u.Type = 'Manager'
AND
  a.Type = 'Customer'
GROUP By u.Id
```

The result being all the Accounts in the database that match the spec.
By lowering the spec to SQL we can use specs for batch processing and
scheduled tasks, and we can also use it to assist in development, by
showing the records matching a spec right in the interface.

##### ╭╮☲☲☲╭╮ #####
