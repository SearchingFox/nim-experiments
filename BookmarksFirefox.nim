import json, sequtils, sets, os, strutils, tables, times, algorithm, sugar, sets

type WebSite = object
    url:   string
    title: string

type WebSites = Table[string, seq[WebSite]]

proc getLinks(path: string): WebSites =
    for i in parseFile(path):
        try:
            var t = newSeq[WebSite]()
            for _, y in i["windows"]:
                for _, z in y:
                    try:
                        t.add(WebSite(url : z["url"].getStr, title : z["title"].getStr))
                    except KeyError:
                        t.add(WebSite(url : z["url"].getStr, title : ""))
            
            #! Unsafe because of multiple saves for one day
            result.add((i["date"].getInt.div 1000).fromUnix.format("yyMMdd") & " - " & i["name"].getStr, t)
        except:
            echo "Got exception ", repr(getCurrentException()), " with message ", getCurrentExceptionMsg()

    return result

proc get_links_only(file_path: string): seq[string] =
    for line in lines(file_path):
        if "<A" in line:
            result.add(line[line.find("\"")+1 .. line.find("\" A")])

proc tabs_to_urls(file_path: string): seq[string] =
    for i in parseFile(file_path):
        try:
            for _, y in i["windows"]:
                for _, z in y:
                    result.add(z["url"].getStr)
        except:
            echo "Got exception ", repr(getCurrentException()), " with message ", getCurrentExceptionMsg()

    return result

proc find_in_all_my_links(file_path: string) = #, f=True):
    # proc no_http(line) =
    #     return line.split('/', 2)[2] if line.startswith('http') else line
    
    #! use cache
    let tabs_file = "C:\\Users\\Asus\\Desktop\\Sessions_2019-06-26_12-23-52.json"
    let bookmarks_file = "C:\\Users\\Asus\\Desktop\\bookmarks_firefox_190701_2230_noicons.html"
    var all_links = newSeq[string]()

    for i in tabs_to_urls(tabs_file).concat(get_links_only bookmarks_file):
        if i.startswith("http"):
            all_links.add(i.split("/", 2)[2])
        else:
            all_links.add(i)

    echo all_links.len
    
    var not_exist = newSeq[string]()
    var exist = newSeq[string]()
    var ls = newSeq[string]()
    for i in lines(file_path):
        if i.startswith("http"):
            ls.add(i.split("/", 2)[2])
        else:
            ls.add(i)

    for line in ls.deduplicate:
        # var line = line.strip()
        var tmp = if line.startswith("http"): line.split("/", 2)[2] else: line
        for i in all_links:
            if tmp == i:
                exist.add(line)
                break
        if line notin exist: # if fl == True:
            not_exist.add(line)
    
    if not_exist.len != 0 and len(not_exist) != len(ls):
        writeFile(file_path[0 .. ^6] & "_uniq.txt", not_exist.join("\n"))
    echo "notin bookmarks: ", not_exist.len,
         "\nin bookmarks: ", exist.len
    # , *sorted(exist), sep='\n') #, *sorted(not_exist), sep='\n', '-'*20, len(exist), *exist, sep='\n')
    # print(time.time() - t)

proc test(path: string) =
    for i in parseFile(path):
        try:
            var c = 0
            for _, y in i["windows"]:
                c += len(y)
            echo i["name"], " ", c
        except:
            echo "Got exception ", repr(getCurrentException()), " with message ", getCurrentExceptionMsg()

proc get_from_json() =
    let path = r"C:\Users\Asus\Desktop\.json"
    let links = getLinks(path)

    var t1: seq[string]
    for i in toSeq(links.values).concat.mapIt(it.url):
        if i in t1:
            echo i
        else:
            t1.add(i)

    let d = true
    if d:
        writeFile(path[0..^6] & "_links.txt", toSeq(links.values).concat.mapIt(it.url).deduplicate.join("\n"))
    else:
        writeFile(path[0..^6] & "_linksnd.txt", toSeq(links.values).concat.mapIt(it.url).join("\n"))

# get_from_json()
# test(path)

# var t = newSeq[string]()
# for l in links.keys:
#     t.add(l)
#     for i in links[l]:
#         t.add("    " & i.url & "\n    " & i.title)

# writeFile(path[0..^6] & "_pure.txt", t.join("\n"))

find_in_all_my_links(r"C:\Users\Asus\Desktop\document - RK4-2ndOrderODE-pdf - 2019-04-08 03-47-34_links.txt")
