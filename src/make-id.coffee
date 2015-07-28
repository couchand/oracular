# make unique ids

idsIssued = 0

module.exports = ->
  newId = idsIssued
  idsIssued += 1
  newId
