QUnit.module 'Batman.Hash',
  setup: ->
    @hash = new Batman.Hash

equalHashLength = (hash, length) ->
  equal hash.length, length
  equal hash.meta.get('length'), length

test "constructor takes arguments", ->
  @hash = new Batman.Hash(foo: 'bar', baz: true)
  ok @hash.hasKey('foo')
  ok !@hash.hasKey('qux')

test "isEmpty() on an empty hash returns true", ->
  ok @hash.isEmpty()
  ok @hash.meta.get('isEmpty')

test "hasKey(key) on an empty hash returns false", ->
  equal @hash.hasKey('foo'), false

test "hasKey(undefined) returns false", ->
  equal @hash.hasKey(undefined), false

test "hasKey(key) for an existing key whose value is undefined returns true", ->
  @hash.set('foo', undefined)
  ok @hash.hasKey('foo')

test "get(undefined) returns undefined", ->
  equal typeof(@hash.get(undefined)), 'undefined'

test "get(key) on an empty hash returns undefined", ->
  equal typeof(@hash.get('foo')), 'undefined'

test "get(key) where the key's value is undefined returns undefined", ->
  @hash.set('foo', undefined)
  equalHashLength @hash, 1
  equal @hash.get('foo'), undefined

test "set(key, val) stores the value for that key, such that hasKey(key) returns true and get(key) returns the stored value", ->
  @hash.set 'foo', 'bar'
  equal @hash.hasKey('foo'), true
  equal @hash.get('foo'), 'bar'

test "set(key, val) overwrites existing keys", ->
  @hash.set 'foo', 'bar'
  @hash.set 'foo', 'baz'
  equal @hash.hasKey('foo'), true
  equal @hash.get('foo'), 'baz'

test "set(key, val) keeps unequal keys distinct", ->
  key1 = {}
  key2 = {}
  @hash.set key1, 1
  @hash.set key2, 2
  equal @hash.get(key1), 1
  equal @hash.get(key2), 2

test "set(key, undefined) sets", ->
  equal typeof(@hash.set 'foo', undefined), 'undefined'
  equalHashLength @hash, 1

test "unset(key) unsets a key and its value from the hash, returning the existing key", ->
  @hash.set 'foo', 'bar'
  equal typeof(@hash.unset('foo')), 'undefined'
  equal @hash.hasKey('foo'), false

test "unset(key) doesn't touch any other keys", ->
  @hash.set 'foo', 'bar'
  @hash.set (o1 = {}), 1
  @hash.set (o2 = {}), 2
  @hash.set (o3 = {}), 3
  @hash.unset o2
  equal @hash.hasKey('foo'), true
  equal @hash.hasKey(o1), true
  equal @hash.hasKey(o2), false
  equal @hash.hasKey(o3), true

test "unset(undefined) doesn't touch any other keys", ->
  @hash.set 'foo', 'bar'
  @hash.set {}, 'bar'
  @hash.unset undefined
  equalHashLength @hash, 2

test "length is maintained over get, set, and unset", ->
  equalHashLength @hash, 0

  @hash.set 'foo', 'bar'
  equalHashLength @hash, 1

  @hash.set 'foo', 'baz'
  equalHashLength @hash, 1, "Length doesn't increase after setting an already existing key"

  @hash.set 'corge', 'qux'
  equalHashLength @hash, 2

  @hash.unset 'foo'
  equalHashLength @hash, 1, "Unsetting an existant key decreases the length"

  @hash.unset 'nonexistant'
  equalHashLength @hash, 1, "Unsetting an nonexistant key doesn't decrease the length"

  @hash.set 'bar', 'baz'
  @hash.clear()
  equalHashLength @hash, 0

  @hash.set o1 = {}, true
  equalHashLength @hash, 1
  @hash.set o2 = {}, true
  equalHashLength @hash, 2

  @hash.set o1, false, "Resetting object keys doesn't change length"
  equalHashLength @hash, 2

  @hash.clear()
  equalHashLength @hash, 0

test "using .hasKey(key) in an accessor registers the hash as a source of the property", ->
  obj = new Batman.Object
  obj.accessor 'hasFoo', => @hash.hasKey('foo')
  obj.observe 'hasFoo', observer = createSpy()
  @hash.set('foo', 'bar')
  equal observer.callCount, 1
  @hash.unset('foo')
  equal observer.callCount, 2

test "using .forEach() in an accessor registers the hash as a source of the property", ->
  obj = new Batman.Object
  obj.accessor 'foreach', => @hash.forEach ->
  obj.observe 'foreach', observer = createSpy()
  @hash.set('foo', 'bar')
  equal observer.callCount, 1
  @hash.unset('foo')
  equal observer.callCount, 2

test "using .isEmpty() in an accessor registers the hash as a source of the property", ->
  obj = new Batman.Object
  obj.accessor 'isEmpty', => @hash.isEmpty()
  obj.observe 'isEmpty', observer = createSpy()
  @hash.set('foo', 'bar')
  equal observer.callCount, 1
  @hash.unset('foo')
  equal observer.callCount, 2

test "using .keys() in an accessor registers the hash as a source of the property", ->
  obj = new Batman.Object
  obj.accessor 'keys', => @hash.keys()
  obj.observe 'keys', observer = createSpy()
  @hash.set('foo', 'bar')
  equal observer.callCount, 1
  @hash.unset('foo')
  equal observer.callCount, 2

test "using .merge(other) in an accessor registers the hash as a source of the property", ->
  obj = new Batman.Object
  otherHash = new Batman.Hash
  obj.accessor 'mergedWithOther', => @hash.merge(otherHash)
  obj.observe 'mergedWithOther', observer = createSpy()
  @hash.set('foo', 'bar')
  equal observer.callCount, 1
  @hash.unset('foo')
  equal observer.callCount, 2

test "equality(lhs, rhs) uses === by default", ->
  equal @hash.equality({}, {}), false
  equal @hash.equality(1, '1'), false
  equal @hash.equality('1', '1'), true

test "equality(lhs, rhs) uses lhs.isEqual and rhs.isEqual if available", ->
  o1 = isEqual: -> true
  o2 = isEqual: -> true
  equal @hash.equality(o1, o2), true
  equal @hash.equality(o2, o1), true

test "equality(lhs, rhs) returns true when both are NaN", ->
  equal @hash.equality(NaN, NaN), true

test "keys() returns an array of the hash's keys", ->
  @hash.set 'foo', 'bar'
  @hash.set (o1 = {}), 1
  @hash.set (o2 = {}), 2
  @hash.set 'foo', 'baz'
  @hash.set 'bar', 'buzz'
  @hash.set 'baz', 'blue'
  @hash.unset 'baz'
  test = (keys) ->
    equal keys.indexOf('baz'), -1
    notEqual keys.indexOf('foo'), -1
    notEqual keys.indexOf(o1), -1
    notEqual keys.indexOf(o2), -1
    notEqual keys.indexOf('bar'), -1
  test(@hash.keys())
  test(@hash.meta.get('keys'))

test "get/set/unset/hasKey with an undefined or null key works like any other, and they don't collide with each other", ->
  equal @hash.hasKey(undefined), false
  equal @hash.hasKey(null), false

  equal @hash.set(undefined, 1), 1
  equal @hash.get(undefined), 1
  equal @hash.hasKey(undefined), true
  equal @hash.hasKey(null), false
  equal @hash.get(null), undefined

  equal @hash.set(null, 1), 1
  equal @hash.get(null), 1
  equal @hash.hasKey(null), true

  @hash.unset(null)
  equal @hash.hasKey(null), false
  equal @hash.hasKey(undefined), true

  @hash.unset(undefined)
  equal @hash.hasKey(undefined), false

test "get/set/unset with an undefined or null value works like any other", ->
  equal @hash.set(1, undefined), undefined
  equal @hash.get(1), undefined
  equal @hash.hasKey(1), true
  @hash.unset(1)
  equal @hash.hasKey(1), false

  equal @hash.set(1, null), null
  equal @hash.get(1), null
  equal @hash.hasKey(1), true
  @hash.unset(1)
  equal @hash.hasKey(1), false

test "keys containing dots (.) are treated as simple keys, not keypaths", ->
  key = "foo.bar.baz"
  equal @hash.hasKey(key), false

  equal @hash.set(key, 1), 1
  equal @hash.get(key), 1
  equal @hash.hasKey(key), true

  equal @hash.hasKey(key), true

  @hash.unset(key)
  equal @hash.hasKey(key), false

test "merge(other) returns a new hash without modifying the original", ->
  key1 = {}
  key2 = {}
  @hash.set key1, 1
  @hash.set key2, 2
  @hash.set 'foo', 'baz'
  @hash.set 'bar', 'buzz'

  other = new Batman.Hash
  other.set key1, 3
  other.set key3 = {}, 4

  merged = @hash.merge other

  ok merged.hasKey 'foo'
  ok merged.hasKey 'bar'
  ok merged.hasKey key1
  ok merged.hasKey key2
  ok merged.hasKey key3
  equal merged.get(key1), 3

  ok !@hash.hasKey(key3)
  equal @hash.get(key1), 1

test "filter(f) returns a filtered hash", ->
  key1 = {}
  key2 = {}
  @hash.set key1, 1
  @hash.set key2, 2
  @hash.set 'foo', 'baz'
  @hash.set 'bar', 'buzz'

  @filtered = @hash.filter (k, v) -> k in [key1, 'foo']
  ok @filtered instanceof Batman.Hash
  equal @filtered.length, 2
  ok @filtered.get key1
  ok @filtered.get 'foo'
