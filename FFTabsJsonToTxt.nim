import json, sequtils, sets, os, strutils, ospaths, tables, times, algorithm, sugar

type WebSite = object
    url:   string
    title: string

type WebSites = Table[string, seq[WebSite]]

proc getLinks(path: string): WebSites = # auto
    result = initTable[string, seq[WebSite]]()
    for i in parseFile(path):
        try:
            var t = newSeq[WebSite]()
            for _, y in i["windows"]:
                for _, z in y:
                    try:
                        t.add(WebSite(url : z["url"].getStr, title : z["title"].getStr))
                    except KeyError:
                        t.add(WebSite(url : z["url"].getStr, title : ""))
            
            # ! Unsafe because of multiple saves for one day
            result.add((i["date"].getInt.div 1000).fromUnix.format("yyMMdd"), t)
        except:
            echo "Got exception ", repr(getCurrentException()), " with message ", getCurrentExceptionMsg()

    return result

# proc findSimilarBuckets(s: seq[seq[WebSite]]) =
#     for i in s:
#         for j in s:
#             if i != j:
                
# echo "Enter full path:"
let
    path = r"C:\Users\Asus\Desktop\.json"
    links = getLinks(path)
stdout.write("> ")
var command = readLine(stdin)
while command != "q":
    case command:
        of "date":
            for k in toSeq(links.keys).sorted(cmp[string]):
                echo k
            let date = readLine(stdin)
            try:
                for i in links[date]:
                    echo i.url, " - ", i.title
            except KeyError:
                echo "Enter right date"
        of "find":
            let word = readLine(stdin).toLower
            for v in links.values:
                for i in v:
                    if word in i.url.toLower or word in i.title.toLower:
                        echo i.url, " - ", i.title
        of "tabs":
            for i in toSeq(links.values).mapIt(len it).sorted(cmp[int]):
                echo i
        of "links":
            # for i in links.values():
            #     for j in i:
            #         echo j.url
            writeFile(path[0..^6] & "_links.txt", toSeq(links.values).concat.mapIt(it.url).deduplicate.join("\n"))
        else:
            echo """
    q     - quit
    date  - get all links from date
    find  - find word in links
    tabs  - print number of tabs
    links - save links to file"""

    stdout.write("> ")
    command = readLine(stdin)
