import json, sequtils, sets, os, strutils, tables, times, algorithm, sugar, times

proc get_from_html(file_path: string): seq[string] =
    for line in lines(file_path):
        if line.strip.starts_with("<DT><A"):
            result.add(line[line.find("\"")+1 ..< line.find("\" A")])

    return result.deduplicate

proc get_from_json(file_path: string): seq[string] =
    for i in parseFile(file_path):
        try:
            for _, y in i["windows"]:
                for _, z in y:
                    result.add(z["url"].getStr)
        except:
            echo "Got exception ", repr(getCurrentException()), " with message ", getCurrentExceptionMsg()

    return result.deduplicate

proc get_from_folder(path: string): seq[string] =
    for k, path in walkDir(path):
        result.add readFile(path).splitLines

    return result.deduplicate

proc get_from_org(file_path: string): seq[string] =
    for l in lines(file_path):
        if l.len > 0 and not l.startsWith("* "):
            result.add l

    return result.deduplicate

proc delete_existing_in_bookmarks(ls: seq[string]): seq[string] = #(file_path: string) = #, f=True):
    let t1 = cpuTime()
    let tabs = if exists_file(r"C:\Users\Asus\Desktop\json_tabs_cache.txt"):
            read_file(r"C:\Users\Asus\Desktop\json_tabs_cache.txt").split_lines
        else:
            # get_from_json r"C:\Users\Asus\Desktop\Sessions_2019-08-24_07-14-18.json"
            get_from_folder r"C:\Users\Asus\Desktop\firefox_resolve\tabs"
    echo "folder time: ", cpuTime() - t1

    let t2 = cpuTime()
    let bookmarks = if exists_file(r"C:\Users\Asus\Desktop\bookmarks_cache.txt"):
            read_file(r"C:\Users\Asus\Desktop\bookmarks_cache.txt").split_lines
        else:
            get_from_html r"C:\Users\Asus\Desktop\bookmarks_firefox_190831_1517_noicons.html"
    echo "html time: ", cpuTime() - t2

    let
        t35 = readFile(r"D:\Documents\35 - Copy.txt").split_lines
        all_links = bookmarks.concat(tabs).concat(t35).mapIt(if it.startswith("http"): it.split("://")[1] else: it)
        t3 = cpuTime()
    echo "all links: ", all_links.len
    
    var
        not_exist = newSeq[string]()
        exist     = newSeq[string]()

    for line in ls:
        let tmp = if line.startswith("http"): line.split("://")[1] else: line
        for i in all_links:
            if tmp.strip == i:
                exist.add(line)
                break
        if line notin exist:
            not_exist.add(line)
    echo "processing time: ", cpuTime() - t3

    if exist.len < 80:
        echo "\n", exist
    echo "\nnotin bookmarks: ", not_exist.len,
         "\nin bookmarks:    ", exist.len

    return not_exist

proc main(file_path: string) =
    let ls = if file_path.ends_with(".json"):
            get_from_json file_path
        elif file_path.endsWith(".html"):
            get_from_html file_path
        else:
            read_file(file_path).split_lines
    echo "links from file: ", ls.len # writeFile(file_path[0..^6] & "_links.txt", ls.join("\n"))

    let output = delete_existing_in_bookmarks ls
    if output.len != 0 and output.len != ls.len:
        let (dir, name, ext) = split_file file_path
        write_file(join_path(dir, name & "_uniq_links.txt"), output.join("\n"))

if paramCount() > 1 and paramStr(1) == "-c":
    main(paramStr(2))
else:
    main(r"C:\Users\Asus\Desktop\firefox_resolve\Sessions_2019-06-18_04-24-55_pure.txt")
