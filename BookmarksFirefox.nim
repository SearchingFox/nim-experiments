import json, sequtils, sets, os, strutils, tables, times, algorithm, sugar, sets

proc get_links_only(file_path: string): seq[string] =
    for line in lines(file_path):
        if "<A" in line:
            result.add(line[line.find("\"")+1 ..< line.find("\" A")])

proc json_to_links(file_path: string): seq[string] =
    for i in parseFile(file_path):
        try:
            for _, y in i["windows"]:
                for _, z in y:
                    result.add(z["url"].getStr)
        except:
            echo "Got exception ", repr(getCurrentException()), " with message ", getCurrentExceptionMsg()

    return result.deduplicate

proc delete_existing_in_bookmarks(ls: seq[string]): seq[string] = #(file_path: string) = #, f=True):
    # proc no_http(line) =
    #     return line.split('/', 2)[2] if line.startswith('http') else line
    
    #! use cache
    let tabs_file = "C:\\Users\\Asus\\Desktop\\Sessions_2019-07-02_01-15-29.json"
    let bookmarks_file = "C:\\Users\\Asus\\Desktop\\bookmarks_firefox_190701_2230_noicons.html"
    var all_links = newSeq[string]()

    for i in json_to_links(tabs_file).concat(get_links_only bookmarks_file):
        let t = if i.startswith("http"): i.split("/", 2)[2] else: i
        all_links.add(t)

    echo "all links: ", all_links.len
    
    var not_exist = newSeq[string]()
    var exist = newSeq[string]()
    # var ls = newSeq[string]()
    # for i in lines(file_path):
    #     if i.startswith("http"):
    #         ls.add(i.split("/", 2)[2])
    #     else:
    #         ls.add(i)

    for line in ls:#.deduplicate:
        # var line = line.strip()
        var tmp = if line.startswith("http"): line.split("/", 2)[2] else: line
        for i in all_links:
            if tmp == i:
                exist.add(line)
                break
        if line notin exist: # if fl == True:
            not_exist.add(line)
    
    # if not_exist.len != 0 and not_exist.len != ls.len:
    #     writeFile(file_path[0 .. ^6] & "_uniq.txt", not_exist.join("\n"))
    echo "notin bookmarks: ", not_exist.len,
         "\nin bookmarks: ", exist.len

    return not_exist
    # , *sorted(exist), sep='\n') #, *sorted(not_exist), sep='\n', '-'*20, len(exist), *exist, sep='\n')
    # print(time.time() - t)

proc main(file_path: string) =
    let ls = json_to_links(file_path)
    echo "links from json: ", ls.len
    # writeFile(file_path[0..^6] & "_links.txt", ls.join("\n"))
    let output = delete_existing_in_bookmarks(ls)
    if output.len != 0:
        writeFile(file_path[0..^6] & "_uniq_links.txt", output.join("\n"))

if paramStr(1) == "-c":
    main(paramStr(2))
