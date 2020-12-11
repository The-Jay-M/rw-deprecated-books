// an optional variable
var maybeString: String?   // defaults to nil
maybeString = nil          // can be assigned a nil value
maybeString = "fish"       // can be assigned a value

// unwrapping an optional
if let unwrappedString = maybeString {
  // unwrappedString is a String rather than an optional String
  println(unwrappedString.hasPrefix("f")) // "true"
} else {
  println("maybeString is nil")
}

// forced unwrapping - will fail at runtime if the optional is nil
if maybeString!.hasPrefix("f") {
  println("maybeString starts with 'f'")
}

// optional chaining, returning an optional with the 
// result of hasPrefix, which is then unwrapped
if let hasPrefix = maybeString?.hasPrefix("f") {
  if hasPrefix {
    println("maybeString starts with 'f'")
  }
}

// unwrapping of multiple optionals
let digitOne = "10".toInt()
let digitTwo = "5".toInt()

if let digitOne = digitOne, digitTwo = digitTwo {
  // notice that digitOne and digitTwo are local constants of
  // type Int that 'shadow' the constants of type Int? that
  // were initialized earlier
  println(digitOne + digitTwo)
}

// optional unwrapping with conditions
if let digitOne = digitOne, digitTwo = digitTwo where digitTwo != 5 {
  println(digitOne + digitTwo)
}

// null coalesce
var anOptional: Int?
var coalesced = anOptional ?? 3 // anOptional is nil, coalesced to 3



