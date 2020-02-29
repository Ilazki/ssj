////////////////////
// LIST UTILITIES
////////////////////

// TODO: List.copy, List.map_mutate

List = { }

// Apply function (f) to each element of list (l), returning a new list with
// values applied.  (f) must take a single argument and return a single
// argument.
// 
// Example:
// 
//    double = function (n)
// 	    return n * 2
//    end function
//    list = [1, 2, 3, 4]
//    print (List.map(@double,list))

List.map = function (f, l)
  list = []
  for v in l
    list.push(@f(v))
  end for
  return list
end function

// Reduce a list of values (l) to a single value by passing argument pairs
// to transforming function (f) using a left fold.  (f) must accept two
// arguments and return a single argument.  Initially, List.fold_left calls
// (f) with (acc) plus // one value from (l); it then continues to call (f)
// with another value from (l) along with the return value of the previous
// call, until only one value remains.
// 
// Example:
// 
//    minus = function (a,b)
//      return a - b
//    end function
//    list = [1, 2, 3, 4]
//    print(List.fold_left(@minus, 0, list))

List.fold_left = function (f, acc, l)
  for v in l
    acc = f(acc,v)
  end for
  return acc
end function

// Filters list (l) via predicate (f).  (f) is a function that takes one
// argument returns TRUE or FALSE.  For every value in (l), if funfion (f)
// returns true, that value is added to a new list.
// 
// Example:
// 
//    lessthan = function (n)
//      return function (v)
//        return v < n
//      end function
//    end function
//    list = [1, 2, 3, 4]
//    print(List.filter(lessthan(3), list))

List.filter = function (f, l)
  list = []
  for v in l
    if f(v) then
      list.push(v)
    end if
  end for
  return list
end function

// Returns (n) elements from (l).
// Redundant, but exists for consistency with Cons.take and Lazy.take
List.take = function (l,n)
         return l[:n]
end function

// Takes a list (l) and returns a new, reversed list without modifying
// the original.
List.reverse = function (l)
  list = []
  for i in range(l.len - 1, 0)
    list.push(l[i])
  end for
  return list
end function

// Flatten a list of lists (ls).  Elements of (ls) are concatenated
// in the same order to give the result.
// 
// Example:
// 
// List.flatten([[1,2],[3,4],[5,6]])

List.flatten = function (ls)
  list = []
  for l in ls
    list + l
  end for
  return list
end function

// Returns true if predicate (p) exists in list (l)
List.exists = function (p, l)
  for v in l
    if p == v then return true; end if
  end for
  return false
end function

// Returns first value of list (l) that satisfies predicate function (p),
// or null if there is none.
List.find = function (f, l)
  list = []
  for v in l
    if f(v) then
      return v
    end if
  end for
  return null
end function

