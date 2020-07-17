//MARK: - Tree
struct Node {
  var value: Int
  var children: [Node] = []

  init(value: Int) {
    self.value = value
  }

  mutating func addNode(with value: Int) {
    children.append(Node(value: value))
  }

  //convenient initialisers to create a dummy tree
  init(value: Int, childValues: Int...) {
    self.value = value
    self.children = childValues.map({ Node(value: $0)})
  }

  init(value: Int, childNodes: Node...) {
    self.value = value
    self.children = childNodes
  }

}

// MARK: Inside of this extension write two functions
extension Node {
  /*1. Write a function that goes through the tree and returns the first element which satisfies the condition. If no element found, return nil;
   condition is expressed by closure (Int) -> Bool
   */
  func firstSatisfying(condition: (Int) -> Bool) -> Node? {
    if condition(value) {
      return self
    }
    for child in children {
      if let ans = child.firstSatisfying(condition: condition) {
        return ans
      }
    }
    return nil
  }

  /*2. Write a filter function that goes through the tree and returns an array of all elements which satisfy the condition. If no element found, return empty array;
   condition is expressed by closure (Int) -> Bool
   */
  func nodesSatisfying(condition: (Int) -> Bool) -> [Node] {
    var nodes: [Node] = []
    if condition(value) {
      nodes.append(self)
    }
    children.forEach { nodes += $0.nodesSatisfying(condition: condition) }
    return nodes
  }
}


//MARK: Test your code
//To test the code, we create a very dummy tree and apply some rules to it.

let middle1 = Node(value: 5, childValues: 13, 16)
let middle2 = Node(value: 7, childValues: 24)
let tree = Node(value: 1, childNodes: middle1, middle2)

//Use the tree to find first object and filter objects that satisfy the conditions:
// element is > 12, > 0, > 50, == 4, == 13, < 15.

func test(condition: (Int) -> Bool) -> Void {
  if let elem = tree.firstSatisfying(condition: condition) {
    print("first element: ", elem.value)
  }

  var elems: [Int] = []
  tree.nodesSatisfying(condition: condition).forEach {elems.append($0.value)}
  print("elements: ", elems)
  print()
}

print("> 12")
test(condition: {$0 > 12})

print("> 0")
test(condition: {$0 > 0})

print("> 50")
test(condition: {$0 > 50})

print("< 15")
test(condition: {$0 < 15})

print("== 4")
test(condition: {$0 == 4})

print("== 13")
test(condition: {$0 == 13})
