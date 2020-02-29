///////////////////
// MAP UTILITIES
///////////////////

// TODO:  Map.copy, Map.map_mutate

Map = { }

// Apply function (f) to each element of map (m), returning a new map with
// values applied.  (f) must take a single argument and return a single
// argument.
// 
// Example:
// 
//    double = function (n)
// 	    return n * 2
//    end function
//    map = {"foo":1, "bar":2, "baz":3, "boz":4}
//    print (Map.map(@double,map))

Map.map = function (f, m)
  map = { }
  for pair in m
    map[pair.key] = f(pair.value)
  end for
  return map
end function

// Reduce a map of values (m) to a single value by passing argument pairs
// to transforming function (f).  (f) must accept two arguments and return
// a single argument.  Initially, Map.reduce calls (f) with (acc) plus one
// value from (m); it then continues to call (f) with another value from
// (m) along with the return value of the previous call, until only one
// value remains.
// 
// Example:
// 
//    minus = function (a,b)
//      return a - b
//    end function
//    map = {"foo":1, "bar":2, "baz":3, "boz":4}
//    print(Map.reduce(@minus, 0, map))

Map.reduce = function (f, acc, m)
  for pair in m
      acc = @f(acc,pair.value)
  end for
  return acc
end function

// Filters map (m) via predicate (f).  (f) is a function that takes one
// argument returns TRUE or FALSE.  For every value in (m), if funfion (f)
// returns true, that value is added to a new map.
// 
// Example: 
// 
//    lessthan = function (n)
//      return function (v)
//        return v < n
//      end function
//    end function
//    map = {"foo":1, "bar":2, "baz":3, "boz":4}
//    print(Map.filter(lessthan(3), map))

Map.filter = function (f, m)
  map = {}
  for pair in m
    if f(pair.value) then
      map[pair.key] = pair.value
    end if
  end for
  return map
end function

// Returns true if predicate (p) exists in map (m)
Map.exists = function (p, m)
  return m.hasIndex(p)
end function
