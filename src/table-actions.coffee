# table actions

Reflux = require 'reflux'

module.exports = Reflux.createActions

  # static actions

  addTable:
    sync: yes

  # instance actions (require _id)

  updateName:
    sync: yes

  updateId:
    sync: yes

  addField:
    sync: yes

  # field actions (require field _id)

  updateFieldName:
    sync: yes

  updateFieldType:
    sync: yes
