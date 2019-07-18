import os, strutils, browsers, sequtils, sets, json, sugar, uri, base64,
    htmlparser, httpclient, xmltree, algorithm, tables, streams, random,
    md5, macros, osproc

proc getFoldersSize(path: string) =
    var size: BiggestInt = 0
    for i in walkDirRec(path):
        size += getFileSize(i)
    echo size
# -------------------------------------------------------------------
proc openLinks (inp: string) =
    for l in inp.splitLines.filterIt(it != ""): openDefaultBrowser l
# -------------------------------------------------------------------
proc deduplicateLines(liness: string) =
    for i in liness.splitLines.deduplicate: echo i
# -------------------------------------------------------------------
proc compareFiles(file1: string, file2: string) =
    let
        f1 = readFile(file1).splitLines.toHashSet
        f2 = readFile(file2).splitLines.toHashSet
    # TODO: don't write part if there are no intersections
    var outFile = toSeq(items(f1 - f2)).join("\n") & "\n" & repeat('-', 80) & "\n" & toSeq(items(f2 - f1)).join("\n")
    writeFile(joinPath(getHomeDir(), "Desktop", "out.txt"), outFile)
# -------------------------------------------------------------------
proc deleteLinesFromFile(filePath: string, linesSeq: seq[string]) =
    var fileContent = readFile(filePath).splitLines
    writeFile(filePath, fileContent.filterIt(it notin linesSeq).join("\n"))
# -------------------------------------------------------------------
proc deduplicateFile(filePath: string) =
    writeFile(filePath, readFile(filePath).splitLines.deduplicate.join("\n"))
# -------------------------------------------------------------------
proc concat_notes(folder: string) =
    var outSeq = newSeq[string]()
    for _, file in walkDir(joinPath(getHomeDir(), "Desktop", folder)):
        outSeq.add(readFile(file).splitLines[^1])
    writeFile(joinPath(getHomeDir(), "Desktop", folder & ".txt"), outSeq.deduplicate.join("\n"))
# -------------------------------------------------------------------
# !NotImplemented
proc findEmptyFolders(path: string) =
    for file in walkDirRec(path):
        echo file
# -------------------------------------------------------------------
proc prettyPrint(file: string) =
    writeFile(file, readFile(file).parseJson.pretty)
# -------------------------------------------------------------------
proc arrow() =
    type fptr = (int -> int)

    proc f(x:int): int =
        result = x+1

    var myf : fptr = f
    echo myf(0)
# -------------------------------------------------------------------
proc download_links() =
    for i in 126..130:
        let folder = "D:\\"
        let pic_url = "" & $i & ".jpg"
        let fileName = joinPath(folder, $i & ".jpg")  # pic_url.split('/')[^1])

        var f = newFileStream(fileName, fmWrite)
        if not f.isNil:
            f.write newHttpClient().getContent(pic_url)
        echo "Saved ", fileName
        # sleep(500)
# -------------------------------------------------------------------
proc get_links_only(file_path: string): seq[string] =
    for l in lines(file_path):
        if "<A" in l:
            result.add(l[l.find('"')+1 ..< l.find("\" A")])
# -------------------------------------------------------------------
proc sort_hn_by_num_of_comments(path: string) =
    var r = initTable[string, (int, string)]()
    for line in lines(path):
        try:
            let json = parseJson(newHttpClient()
                .getContent("https://hacker-news.firebaseio.com/v0/item/$1.json" % line.split('=')[^1]))
            r.add(line, (json["descendants"].getInt, json["title"].getStr))
            sleep(100)
        except KeyError: #! Change to something else
            echo line
    
    for k in toSeq(r.pairs).sorted((x, y) => cmp(x[1][0], y[1][0])):
        echo k[1][0], " - ", k[0], " - ", k[1][1]
# -------------------------------------------------------------------
proc joyrDl(url: string) =
    let pics = parseHtml(newHttpClient().getContent(url)).findAll("img").mapIt(it.attr("src"))
        .filterIt("avatar" notin it and [".jpeg", ".gif", ".png", ".jpg"].any(x => it.endsWith(x)))
    echo len(pics), "\n", pics
# -------------------------------------------------------------------
proc strip_favicon_images(old_file_path: string) =
    var new_html = newSeq[string]()
    for line in lines(old_file_path):
        if line.find("ICON_URI") > 0:
            new_html.add(line[0..line.find("ICON_URI")-2] & line[line.find("\">")+1..^1])
        else:
            new_html.add(line)
    writeFile(old_file_path[ .. ^6] & "_noicons.html", new_html.join("\n"))
# -------------------------------------------------------------------
proc sort_hn_file_by_comments(path: string) =
    var t = initTable[string, int]()
    for l in lines(path):
        let s = l.split(" - ")
        if len(s) == 3:
            t.add(s[1] & " - " & s[2], s[0].parseInt)
        else:
            t.add(s[1], s[0].parseInt)
    for i in toSeq(t.pairs()).sorted((x, y) => cmp(x[1], y[1])):
        echo i[1], " - ", i[0]
# -------------------------------------------------------------------
proc pikabu_get(url: string, pages = 1) =
    var cur_url = url
    let folder = joinPath("D:", url.split('@')[^1])
    discard existsOrCreateDir(folder) #! discard ???

    for page in 1 .. pages:
        let page_html = newHttpClient().getContent(cur_url).parseHtml
        let page_folder = joinPath(folder, page.intToStr)
        discard existsOrCreateDir(page_folder) #! discard ???

        for j, post_url in page_html.findAll("a").filterIt(it.attr("href").endsWith("#comments")):
            echo j, " ", post_url.attr("href")
            let post_html = newHttpClient().getContent(post_url.attr("href")).parseHtml
            let post_folder = joinPath(page_folder, getMD5(post_url.attr("href")))
            discard existsOrCreateDir(post_folder) #! discard ???

            let links = post_html.findAll("img").filterIt(it.attr("data-large-image") != "")
            echo links.len
            for link in links:
                let pic_url = link.attr("data-large-image")
                let fileName = joinPath(post_folder, pic_url.split('/')[^1])
                if not fileName.existsFile:
                    var f = newFileStream(fileName, fmWrite)
                    if not f.isNil:
                        f.write newHttpClient().getContent(pic_url)
        
        cur_url = url & "?page=$1" % page.intToStr
# -------------------------------------------------------------------
proc z(x: typedesc[int]): int = 0
proc z(x: typedesc[float]): float = 0.0
proc test_monoid() =
    type Monoid = concept x, y
        x + y is type(x)
        z(type(x)) is type(x)

    echo "int is monoid -> ", 3 is Monoid
    let x = 3
    echo z(type(x)) # prints 0
# -------------------------------------------------------------------
proc dedup_save_order(file_path: string) =
    var t = newSeq[string]()
    for i in lines(file_path):
        if len(i) != 0:
            if i notin t:
                t.add(i)
            else:
                echo i
        else:
            t.add(i)
    writeFile(file_path[ .. ^5] & "_nodup.txt", t.join("\n"))
# -------------------------------------------------------------------
proc enqueue_ytdl() =
    let links = """
https://www.youtube.com/watch?v=iGiHa3GtQhM
https://www.twitch.tv/videos/451307155
https://www.twitch.tv/videos/448285685"""
    for i in links.split_lines:
        let t = execCmd("youtube-dl.exe " & i)  # startProcess, bunches of startProcesses
        echo t
# -------------------------------------------------------------------
# macro test(n: varargs[untyped]): untyped =
#     for x in n.children:
#         echo x.repr

# discard test(1)
# discard test(1,2)
# discard test(1,b=2)
# -------------------------------------------------------------------
# echo lc[x | (x <- 1..10, x mod 2 == 0), int]
# -------------------------------------------------------------------
# var outStr = ""
# for i in parseJson(readFile(""))["notes"]:
#     if i["state"].getStr != "TRASH":
#         for j in parseJson(i["description"].getStr)["note"]:
#             outStr &= j["text"].getStr & "\n"
#         outStr &= repeat('-', 80) & "\n"
# writeFile("", outStr)
# -------------------------------------------------------------------
# let
    # lines_jp = readFile("D:\\32456547587\\scripts_va11halla\\jp\\").splitLines
    # lines_eng = readFile("D:\\32456547587\\scripts_va11halla\\eng\\").splitLines
# echo high(lines_eng)
# var out_file = ""
# for l in low(lines_jp)..high(lines_jp):
#     out_file &= lines_jp[l] & "\n" & lines_eng[l] & "\n\n"
# writeFile(joinPath(getHomeDir(), "Desktop", "learnJP.txt"), out_file)

# var t = newSeq[string]()
# for i in lines(r"C:\Users\Asus\Desktop\ddd.txt"):
#     if i.toLower notin t:
#         t.add(i.toLower)
#         echo i

# for l in lines(""):
#     if l != "" and l.contains(re"(?|(.jpg)|(.png)|(.gif))"):
#         echo l

# var s = newSeq[string]()
# for i in lines(r"C:\Users\Asus\Desktop\Bookmarks_181004_2003.org"):
#     if i != "" and not i.startsWith("* "):
#         s.add(i)
# writeFile(r"C:\Users\Asus\Desktop\123.txt", deduplicate(s).join("\n"))

# var links1 = toSeq(getLinks(r"").values()).concat.map(x => x.url).toSet
# var links2 = toSeq(getLinks(r"").values()).concat.map(x => x.url).toSet
# for i in links1 - links2:
#     echo i
# echo "\n"
# for i in links2 - links1:
#     echo i

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

# var t = initTable[string, int]()
# for l in lines(r"C:\Users\Asus\Desktop\tst2.txt"):
#     # let s = l.split(" - ")
#     # var s = t.mgetOrPut(l, 0) + 1
#     if not t.hasKey(l):
#         t[l] = 1
#     else:
#         t[l] += 1
# for i in toSeq(t.pairs()).sorted((x, y) => cmp(x[1], y[1])):
#     echo i[1], " - ", i[0]

# ------------------------------------------------------------
# echo get_links_only(r"")
openLinks("""""")
# joyrDl()
# sort_hn_file_by_comments(r"C:\Users\Asus\Desktop\hn1.txt")
# sort_hn_by_num_of_comments(r"C:\Users\Asus\Desktop\hn6.txt")
# strip_favicon_images()
# deduplicateFile(r"")

# echo decodeUrl("")
# echo decode("")
# download_links()
# randomize(); echo rand(39)
# dedup_save_order(r"D:\Documents\35 - Copy.txt")

# for l in lines(r"C:\Users\Asus\Desktop\Imp.org"):
#     if l.len > 0 and not l.startsWith("* "):
#         echo l
