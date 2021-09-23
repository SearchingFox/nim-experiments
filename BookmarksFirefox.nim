import json
import os
import sequtils
import sets
import strutils
import algorithm # only for sorted

proc get_from_html(file_path: string): seq[string] =
    for line in lines(file_path):
        if line.strip.starts_with("<DT><A"):
            result.add(line[line.find("\"")+1 ..< line.find("\" A")])

proc get_from_json(file_path: string): seq[string] =
    for i in parse_file(file_path):
        try:
            for _, window in i["windows"]:
                for _, link in window:
                    result.add(link["url"].get_str)
        except:
            echo "Got exception ", repr(getCurrentException()), " with message ", getCurrentExceptionMsg()

proc get_from_folder(folder_path: string): seq[string] =
    for _, path in walk_dir(folder_path):
        result.add read_file(path).split_lines
            .filter_it(it.starts_with("http://") or
                       it.starts_with "https://") # or ftp

proc get_from_org(file_path: string): seq[string] =
    # TODO: no body support
    for l in lines(file_path):
        if l.len > 0 and not l.starts_with("* "):
            result.add l

proc del_http(i: string): (string, string) =
    if i.starts_with("http"):
        try:
            # Doesn't work
            result = (i.split("://", 1)[1], i.split("://")[0])
        except Exception:
            echo "in del_http:", i

proc find_notexisting_in_bookmarks(ls: seq[string]): seq[string] =
    let
        html_file = to_seq(walk_files r"C:\Users\Asus\Desktop\bookmarks_firefox_*.html").sorted()[^1]
        bookmarks = get_from_html html_file
        tabs = get_from_folder r"C:\Users\Asus\Desktop\firefox_resolve\tabs"
        
        all_links = bookmarks.concat(tabs).map_it(del_http it).to_hash_set
        test_links = ls.map_it(del_http it).to_hash_set

    # TODO: restore order somehow
    result = (test_links - all_links).to_seq().map_it(it[1] & "://" & it[0])
    let exist = (test_links * all_links).to_seq

    if exist.len < 180:
        echo "\n", exist
    echo "\nnotin bookmarks: ", result.len,
         "\nin bookmarks:    ", exist.len

proc main(file_path: string, format: string="old") =
    var ls = new_seq[string]()
    if format == "new":
        # Maybe indexes += 2
        for i, j in to_seq(read_file(file_path).split_lines):
            if i mod 2 != 0:
                ls.add(j)
    else:
        ls = if file_path.ends_with(".json"):
                get_from_json file_path
            elif file_path.ends_with(".html"):
                get_from_html file_path
            else:
                read_file(file_path).split_lines
    echo "Got ", ls.len, " links from file"

    let not_exist = find_notexisting_in_bookmarks(ls)
    if not_exist.len != 0 and not_exist.len != ls.len:
        let (dir, name, ext) = split_file file_path
        write_file(join_path(dir, name & "_uniq_links_2.txt"), not_exist.join "\n")

if param_count() > 1 and param_str(1) == "-f":
    main(param_str(2))
else:
    main(r"", "new")
