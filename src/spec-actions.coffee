# spec actions

Reflux = require 'reflux'

module.exports = Reflux.createActions

  # static actions

  loadConfig:
    sync: yes

  addSpec:
    sync: yes

  # instance actions (require _id)

  updateName:
    sync: yes

  updateTable:
    sync: yes

  updateSpec:
    sync: yes
