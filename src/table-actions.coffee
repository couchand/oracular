# table actions

Reflux = require 'reflux'

module.exports = Reflux.createActions

  # static actions

  loadConfig:
    sync: yes

  addTable:
    sync: yes

  # instance actions (require _id)

  updateName:
    sync: yes

  updateId:
    sync: yes

  addField:
    sync: yes

  addParent:
    sync: yes

  # field actions (require field _id)

  updateFieldName:
    sync: yes

  updateFieldType:
    sync: yes

  # parent actions (require parent _id)

  updateParentName:
    sync: yes

  updateParentId:
    sync: yes

  updateParentTable:
    sync: yes
