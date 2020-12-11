func longestWord(words: String...) -> String? {
  var currentLongest: String?
  for word in words {
    if currentLongest != nil {
      if count(word) > count(currentLongest!) {
        currentLongest = word
      }
    } else {
      currentLongest = word
    }
  }
  return currentLongest
}

let long = longestWord("chick", "fish", "cat", "elephant")
println(long)


func longestWord2(words: String...) -> String? {
  return words.reduce(String?()) {
    (longest, word) in
    (longest == nil) || count(word) > count(longest!)
      ? word : longest
  }
}

let long2 = longestWord2("chick", "fish", "cat", "elephant")
println(long2)




