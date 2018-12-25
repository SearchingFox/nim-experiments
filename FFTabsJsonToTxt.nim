import json, sequtils, sets, os, strutils, ospaths, tables, times, algorithm, sugar

type WebSite = object
    url:   string
    title: string

type WebSites = OrderedTable[string, seq[WebSite]]

proc getLinks(path: string): Table[string, seq[WebSite]] =
    var result1 = {"0": @[WebSite(url : "", title : "")]}.toTable
    result1.del("0")
    for i in parseFile(path):
        try:
            var t = newSeq[WebSite]()
            for _, y in i["windows"]:
                for _, z in y:
                    try:
                        t.add(WebSite(url : z["url"].getStr, title : z["title"].getStr))
                    except KeyError:
                        t.add(WebSite(url : z["url"].getStr, title : ""))
                    # if paramCount() > 1 and paramStr(1) == "--ext":
            result1.add(format((i["date"].getInt.div(1000)).fromUnix, "yyMMdd"), t)
        except:
            echo "Got exception ", repr(getCurrentException()), " with message ", getCurrentExceptionMsg()

    return result1

let links = getLinks(r"C:\Users\Asus\Desktop\Сессии - 2018-12-22 08-35-04.json")
stdout.write("> ")
var command = readLine(stdin)

if command == "help":
    echo """
    date - get all links from date
    find - find word in links"""
elif command == "date":
    for k in toSeq(links.keys()).sorted((x, y) => cmp(x, y)):
        echo k
    let date = readLine(stdin)
    for i in links[date]:
        echo i.url, " - ", i.title
elif command == "find":
    let word = readLine(stdin).toLower
    for v in links.values:
        for i in v:
            if word in i.url.toLower or word in i.title.toLower:
                echo i.url, " - ", i.title
elif command == "sets":
    var links1 = toSeq(getLinks(r"").values()).concat.map(x => x.url).toSet
    var links2 = toSeq(getLinks(r"").values()).concat.map(x => x.url).toSet
    for i in links1 - links2:
        echo i
    echo "\n"
    for i in links2 - links1:
        echo i
elif command == "tabs":
    for i in toSeq(links.values()).sorted((x, y) => cmp(len(x), len(y))):
        echo len(i)#, " - ", i

# echo "Enter full path:"
# let path = readLine(stdin)
# var links1 = getLinks(path)
# echo len(links1), " ", len(toSet(links1))
# writeFile(path.split("/")[0..^2].join("/") & "/SessionsFromNim.txt", links1.deduplicate.join("\n"))

# var nim = newSeq[string]()
# for i in lines(joinPath(getHomeDir(), "Desktop", SessionsFromNim.txt")):
#     nim.add(i)
# var c = 0
# for i in lines(joinPath(getHomeDir(), "Desktop", SessionsFromHaskell_2.txt")):
#     if not (i in nim):
#         c += 1
# echo c

# var s = newSeq[string]()
# for i in walkFiles("D:\\Downloads\\TabSessionManager - Backup\\*.json"):
#     s = concat(s, getLinks(i))
# var ds = deduplicate(s)
# var dds = toSet(ds) - toSet(getLinks(""))
# var ss = ""
# for i in dds:
#     ss &= i & "\n"
# # echo len(s), " ", len(ds)
# writeFile("", ss)#join(s, "\n"))
# # echo len(dds)
