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
    self.children = childValues.map({ Node(value: $0) })
  }

  init(value: Int, childNodes: Node...) {
    self.value = value
    self.children = childNodes
  }
}

// MARK: Inside of this extension write two functions
extension Node {

  /*1. Write a function that goes through the tree and returns the first element which satisfies the predicate. If no element found, return nil;
   predicate is expressed by closure (Int) -> Bool
   */
  func first(where predicate: (Int) -> Bool) -> Node? {
    if predicate(value) { return self }

    for child in children {
      if let temp = child.first(where: predicate) {
        return temp
      }
    }

    return nil
  }

  /*2. Write a filter function that goes through the tree and returns an array of all elements which satisfy the predicate. If no element found, return empty array; predicate is expressed by closure (Int) -> Bool
   */
  func nodes(where predicate: (Int) -> Bool) -> [Node] {
    var result = [Node]()
    nodesRecursive(where: predicate, to: &result)
    return result
  }

  private func nodesRecursive(where predicate: (Int) -> Bool, to result: inout [Node]) {
    if predicate(value) {
      result.append(self)
    }

    for child in children {
      var temp = [Node]()
      child.nodesRecursive(where: predicate, to: &temp)
      result += temp
    }
  }

  func check(where predicate: (Int) -> Bool) {
    print("First element = ", terminator: "")

    if let node = first(where: predicate) {
      print(node.value)
    } else {
      print("there is no such object")
    }

    let nodesMatching = nodes(where: predicate)
    print("Object range = ", terminator: "")
    if nodesMatching.count == 0 {
      print("no elements in the range")
    }

    for node in nodesMatching {
      print(node.value, " ", terminator: "")
    }
  }
}

//MARK: Test your code
//To test the code, we create a very dummy tree and apply some rules to it.

let middle1 = Node(value: 5, childValues: 13, 16)
let middle2 = Node(value: 7, childValues: 24)
let tree = Node(value: 1, childNodes: middle1, middle2)

var predicate: (Int) -> Bool

print("predicate > 12")
predicate = { $0 > 12 }
tree.check(where: predicate)

print("\n\npredicate > 0")
predicate = { $0 > 0 }
tree.check(where: predicate)

print("\n\npredicate > 50")
predicate = { $0 > 50 }
tree.check(where: predicate)

print("\n\npredicate == 4")
predicate = { $0 == 4 }
tree.check(where: predicate)

print("\n\npredicate == 13")
predicate = { $0 == 13 }
tree.check(where: predicate)

print("\n\npredicate < 15")
predicate = { $0 < 15 }
tree.check(where: predicate)

//Use the tree to find first object and filter objects that satisfy the predicates:
// element is > 12, > 0, > 50, == 4, == 13, < 15.
