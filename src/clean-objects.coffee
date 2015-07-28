# clean out private properties from an object hierarchy

module.exports = clean = (obj) ->
  return obj unless typeof obj is 'object'

  if Array.isArray obj
    obj.map clean

  else
    result = {}

    for k, v of obj when k.length and k[0] isnt '_'
      result[k] = clean v

    result
