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
        result.add readFile(path).splitLines.filterIt(it.startsWith "http") # or ftp

    return result.deduplicate

proc get_from_org(file_path: string): seq[string] = # TODO: no body support
    for l in lines(file_path):
        if l.len > 0 and not l.startsWith("* "):
            result.add l

    return result.deduplicate

proc a(i: string): string =
    if i.startswith("http"):
        try:
            result = i.split("://")[1]
        except Exception:
            echo "in a:", i
            result = i
    else:
        result = i
    
    return result

proc find_existing_in_bookmarks(ls: seq[string]): seq[string] =
    let tabs = get_from_folder r"C:\Users\Asus\Desktop\firefox_resolve\tabs"
    let
        t2 = cpuTime()
        html_file = to_seq(walk_files(r"C:\Users\Asus\Desktop\bookmarks_firefox_*.html")).sorted()[^1]
        bookmarks = if exists_file(r"C:\Users\Asus\Desktop\bookmarks_cache.txt"):
            read_file(r"C:\Users\Asus\Desktop\bookmarks_cache.txt").split_lines
        else:
            get_from_html html_file
    echo "html time: ", cpuTime() - t2

    # for i in bookmarks:
    #     if "httpclient" in i:
    #         echo i
    # if true: quit(0)

    let
        t35 = readFile(r"D:\Documents\35 - Copy.txt").split_lines
        all_links = bookmarks.concat(tabs).filter_it(it.starts_with "http").map_it(a(it))
        t3 = cpuTime()
    # writeFile("C:\\Users\\Asus\\Desktop\\alltabs.txt", all_links.join("\n")) # .mapIt(a(it))
    # if true: quit(0)
    var
        not_exist = newSeq[string]()
        exist     = newSeq[string]()
        c = 0

    for line in ls:
        c += 1

        var tmp: string
        try:
            tmp = if line.startswith("http"): line.split("://")[1] else: line
        except Exception:
            echo "in proc:", c, line
            tmp = line
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
        elif file_path.ends_with(".html"):
            get_from_html file_path
        else:
            read_file(file_path).split_lines
    echo "links from file: ", ls.len
    # writeFile(file_path[0..^6] & "_links.txt", ls.join("\n"))
    # if true: quit(0)

    let output = find_existing_in_bookmarks ls
    if output.len != 0 and output.len != ls.len:
        let (dir, name, ext) = split_file file_path
        write_file(join_path(dir, name & "_uniq_links.txt"), output.join "\n")

if param_count() > 1 and param_str(1) == "-f":
    main(param_str(2))
else:
    main(r"C:\Users\Asus\Desktop\firefox_resolve\tabs_190727_2332.txt")
