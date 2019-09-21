import sequtils,
       strutils

type Node = ref object
    letter:   char
    children: seq[Node] #? ref Node, addr Node

type Trie = ref object
    root: Node

proc newTrie(): Trie =
    let n = Node(letter: '\0', children: @[])
    return Trie(root: n)

# proc addNode(t: Trie, c: char) =
proc addToTrie(t: Node, s: string) =
    let l = s[0]
    if l notin t.children.mapIt(it.letter):
        let n = Node(letter: l, children: @[])
        t.children.add(n)
    for i in t.children:
        if i.letter == l:
            addToTrie(t.children[i], s[1..^1])


proc printTrie(t: Trie) =
    proc printHelper(n: Node, level: int = 0) =
        echo repeat('\t', level), n.letter
        for i in n.children:
            printHelper(i, level + 1)
    
    printHelper(t.root)

# proc starts_with()

var u = Node(letter: 'u', children: newSeq[Node]())
var n = Node(letter: 'a', children: @[u])
var t = Trie(root: n)
printTrie(t)
# proc add(t: Trie, s: string): Trie =
#     for c in s:
#         if t.root