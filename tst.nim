import os, strutils, browsers, sequtils, sets, json, sugar, uri, base64,
    htmlparser, httpclient, xmltree, algorithm, tables, streams, random,
    md5, macros, osproc, oids, times

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
proc concatNotes(folder: string) =
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
proc downloadLinks() =
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
proc getLinksOnly(file_path: string): seq[string] =
    for l in lines(file_path):
        if "<A" in l:
            result.add(l[l.find('"')+1 ..< l.find("\" A")])
# -------------------------------------------------------------------
proc joyGet(url: string) =
    # ? TODO: Add dimensions and file size restrictions
    let pics = parseHtml(newHttpClient().getContent url).findAll("img").mapIt(it.attr "src")
        .filterIt("avatar" notin it and [".jpeg", ".gif", ".png", ".jpg"].any(x => it.endsWith(x)))
    echo pics.len, "\n", pics
# -------------------------------------------------------------------
proc stripFaviconImages(old_file_path: string) =
    var new_html = newSeq[string]()
    for line in lines(old_file_path):
        if line.find("ICON_URI") > 0:
            new_html.add(line[0..line.find("ICON_URI")-2] & line[line.find("\">")+1..^1])
        else:
            new_html.add(line)
    writeFile(old_file_path[ .. ^6] & "_noicons.html", new_html.join("\n"))
# -------------------------------------------------------------------
proc pikabuGet(url: string, pages = 1) =
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

proc testMonoid() =
    type Monoid = concept x, y
        x + y is type(x)
        z(type(x)) is type(x)

    echo "int is monoid -> ", 3 is Monoid
    let x = 3
    echo z(type(x)) # prints 0
# -------------------------------------------------------------------
proc deduplicateAndSaveOrder(file_path: string) =
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
proc queueYtdl() =
    let links = """
https://www.youtube.com/watch?v=iGiHa3GtQhM
https://www.twitch.tv/videos/451307155
https://www.twitch.tv/videos/448285685"""
    for i in links.split_lines:
        let t = execCmd("youtube-dl.exe " & i)  # startProcess, bunches of startProcesses
        echo t
# -------------------------------------------------------------------
proc kgGet(url: string) =
    if "gallery-full" notin url:
        echo "Needs full gallery url"
        return
    
    let folder = joinPath("D:", url.split('/')[^3] & "_" & url.split('/')[^2])
    if existsOrCreateDir(folder):
        echo "Directory already exists"
        return
    
    let pics = newHttpClient().getContent(url).parseHtml
                .findAll("a").mapIt(it.attr("href")).filterIt(it.endsWith(".jpg"))[1..^1]
    echo pics.len

    for p in pics:
        let fileName = joinPath(folder, p.split('/')[^1])
        if not fileName.existsFile: #? delete line
            var f = newFileStream(fileName, fmWrite)
            if not f.isNil: f.write newHttpClient().getContent(p)
# -------------------------------------------------------------------
proc cmpFiles(sourceF: string, testF: string) =
    let t = readFile(sourceF).splitLines
    var s = newSeq[string]()
    for l in lines(testF):
        if l notin t: s.add(l)
        # else: echo l
    writeFile(r"C:\Users\Asus\Desktop\ttt3.txt", s.join("\n"))
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
# for l in lines(r"C:\Users\Asus\Desktop\.org"):
#     if l.len > 0 and not l.startsWith("* "):
#         s.add(l)
# writeFile(r"C:\Users\Asus\Desktop\.txt", s.deduplicate.join("\n"))

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
# for l in lines(r""):
#     # let s = l.split(" - ")
#     # var s = t.mgetOrPut(l, 0) + 1
#     if not t.hasKey(l):
#         t[l] = 1
#     else:
#         t[l] += 1
# for i in toSeq(t.pairs()).sorted((x, y) => cmp(x[1], y[1])):
#     echo i[1], " - ", i[0]

# let tt = cpuTime()
# proc get_from_html(file_path: string): seq[string] =
#     for line in read_file(file_path).split_lines:
#         if line.strip.starts_with("<DT><A"):
#             result.add(line[line.find("\"")+1 ..< line.rfind("\" A")])

#     return result.deduplicate

# let files = @[r"*.txt"]
# for l in readFile(r"").split_lines:
#     for f in files:
#         if l in readFile(f).split_lines:
#             echo l
# ------------------------------------------------------------
# echo getLinksOnly(r"")
# openLinks("""""")
# findEmptyFolders(r"C:\Users\Asus\Desktop\f")
# joyDl()
# sortHnFileByCommentsNum(r"C:\Users\Asus\Desktop\hn1.txt")
# getCommentsForHnLinks(r"")
# stripFaviconImages(r"")
# deduplicateFile(r"")
# downloadLinks()
# dedupSaveOrder(r"")

# echo decodeUrl("")
# echo decode("")
# randomize(); echo rand(39)
# echo genOid()

# kg_get("")
# cmpFiles()
