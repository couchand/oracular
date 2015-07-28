# elide config defaults for clarity

module.exports = (config) ->
  tables = for table in config.tables
    nextTable =
      name: table.name
      fields: for field in table.fields
        nextField = name: field.name
        nextField.type = field.type unless field.type is 'string'
        nextField

    nextTable.id = table.id unless table.id is 'Id'

    if table.parents.length
      nextTable.parents = for parent in table.parents
        nextParent = name: parent.name
        nextParent.id = parent.id unless parent.id is "#{parent.name}Id"
        nextParent.table = parent.table unless parent.table is parent.name
        nextParent

    nextTable

  specs = []

  {tables, specs}
