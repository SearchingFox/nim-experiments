import json, sequtils, sets, os, strutils, ospaths


proc getLinks(path: string): seq[string] =
    for i in parseFile(path):
        try:
            for _, y in i["windows"]:
                for _, z in y:
                    result.add(z["url"].getStr)
                    if paramCount() > 1 and paramStr(1) == "--ext":
                        result.add(z["title"].getStr)
        except:
            echo "None"

    return result


echo "Enter full path:"
let path = readLine(stdin)
var links1 = getLinks(path)
echo len(links1), " ", len(toSet(links1))
writeFile(path.split("/")[0..^2].join("/") & "/SessionsFromNim.txt", links1.deduplicate.join("\n"))

# type WebSite = object
#     url:   string
#     title: string

# proc getLinks1(path: string): seq[WebSite] =
#     for i in parseJson(readFile(path)):
#         try:
#             for _, y in i["windows"]:
#                 for _, z in y:
#                     result.add(WebSite(url : z["url"].getStr, title : z["title"].getStr))
#         except:
#             echo "None"

#     return result


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
