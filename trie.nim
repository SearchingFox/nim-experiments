type Node = object
    letter: char
    children: seq[Node]

type Trie = ref object
    root: Node

# proc addNode(t: Trie, c: char) =
proc addToTrie(t: Trie, s: string)


proc printTrie(t: Trie) =
    echo t.root.letter
    for i in t.root.children:
        echo "\t", i.letter

var u = Node(letter: 'u', children: newSeq[Node]())
var n = Node(letter: 'a', children: [u])
var t = Trie(root: n)
printTrie(t)
# proc add(t: Trie, s: string): Trie =
#     for c in s:
#         if t.root