import os, strutils, browsers, sequtils, sets, json, sugar, uri, base64,
    htmlparser, httpclient, xmltree, algorithm, tables, streams, random,
    md5, macros, osproc, oids, times, strformat, itertools, strtabs

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
    writeFile(filePath & "_new.txt", fileContent.filterIt(it notin linesSeq).join("\n"))
# -------------------------------------------------------------------
proc deduplicateFile(filePath: string) =
    writeFile(filePath & "_new.txt", readFile(filePath).splitLines.deduplicate.join("\n"))
# -------------------------------------------------------------------
proc concatNotes(folder: string) =
    var outSeq = newSeq[string]()
    for _, file in walkDir(joinPath(getHomeDir(), "Desktop", folder)):
        outSeq.add(readFile(file).splitLines[^1])
    writeFile(joinPath(getHomeDir(), "Desktop", folder & ".txt"), outSeq.deduplicate.join("\n"))
# -------------------------------------------------------------------
proc findEmptyFolders(path: string) =
    for k, dir in walkDir(path):
        if k == pcDir:
            if toSeq(walkDirRec(dir)) == @[]:
                removeDir dir
        # echo k, " ", dir
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
proc joyGet(url: string) =
    # ? TODO: Add dimensions and file size restrictions
    let pics = parseHtml(newHttpClient().getContent url).findAll("img").mapIt(it.attr "src")
        .filterIt("avatar" notin it and [".jpeg", ".gif", ".png", ".jpg"].any(x => it.endsWith x))
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
proc pikaGet(url: string, pages = 1) =
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
                    newHttpClient().downloadFile(pic_url, fileName)
                    # var f = newFileStream(fileName, fmWrite)
                    # if not f.isNil:
                    #     f.write newHttpClient().getContent(pic_url)
        
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
    let links = """"""
    for i in links.split_lines:
        let t = execCmd("youtube-dl.exe " & i)  # startProcess, bunches of startProcesses
        echo t
# -------------------------------------------------------------------
proc kgGet(url: string) =
    if "gallery-full" notin url:
        echo "Use full gallery url"
        return
    
    let folder = joinPath("D:\\Downloadss", url.split('/')[^3] & "_" & url.split('/')[^2])
    if existsOrCreateDir(folder):
        echo "Directory already exists"
        return

    let pics = newHttpClient().getContent(url).parseHtml
                .findAll("a").mapIt(it.attr("href")).filterIt(it.endsWith(".jpg"))[1..^1]
    echo pics.len

    for p in pics:
        let fileName = joinPath(folder, p.split('/')[^1])
        if not fileName.existsFile: #? delete line
            newHttpClient().downloadFile(p, fileName)
# -------------------------------------------------------------------
proc cmpFiles(sourceF: string, testF: string) =
    let t = readFile(sourceF).splitLines
    var s = newSeq[string]()
    for l in lines(testF):
        if l notin t: s.add(l)
        # else: echo l
    writeFile(r"", s.join("\n"))
# -------------------------------------------------------------------
proc moveToFoldersByExtension(path: string) =
    #! NOUSE
    # TODO: If only one file with such extension exist, skip it
    for k, p in walkDir(path):
        if k == pcFile:
            var (dir, name, ext) = p.splitFile
            echo ext
            try:
                discard existsOrCreateDir(joinPath(path, ext[1..^1]))
                moveFile(p, joinPath(path, ext[1..^1], name.addFileExt(ext))) #! Check for existing files
            except Exception:
                echo "Nope:", name, ext
# -------------------------------------------------------------------
proc update_ffmpeg() =
    # TODO: add check for dates
    newHttpClient().downloadFile("https://ffmpeg.zeranoe.com/builds/win64/static/ffmpeg-latest-win64-static.zip", "D:\\Downloads\\ffmpeg-latest-win64-static.zip")
    if existsFile("D:\\Downloads\\ffmpeg-latest-win64-static.zip"):
        echo "Downloaded ffmpeg-latest-win64-static.zip"
        discard execCmd("\"C:\\Program Files\\7-Zip\\7z.exe\" x D:\\Downloads\\ffmpeg-latest-win64-static.zip -oD:\\Documents\\Programs")
        removeDir("D:\\Documents\\Programs\\ffmpeg")
        # discard execProcess("C:\\Program Files\\7-Zip\\7z.exe", args=["x", "ffmpeg-latest-win64-static.zip", "-oD:\\Documents\\Programs"])
        moveDir("D:\\Documents\\Programs\\ffmpeg-latest-win64-static", "D:\\Documents\\Programs\\ffmpeg")
        removeFile("D:\\Downloads\\ffmpeg-latest-win64-static.zip")
        # echo t
# -------------------------------------------------------------------
proc cut_by_time(path: string, times: string) =
    # TODO: add file instead of times string?
    var (dir, name, ext) = path.splitFile()
    discard existsOrCreateDir(joinPath(dir, name))
    let songs = times.splitLines.mapIt(it.rsplit(" ", 1)) # linked list ?

    for i in 0 ..< songs.len-1:
        let song_cmd = "ffmpeg -i \"" & path & "\" -acodec copy -ss " & songs[i][1] & " -to " & songs[i+1][1] & " \"" & joinPath(dir, name, songs[i][0].filterIt(it notin "<>:\"/\\|?*").join()) & ext & "\""
        discard execCmd(song_cmd)
    let last_song_cmd = "ffmpeg -i \"" & path & "\" -acodec copy -ss " & songs[^1][1] & " \"" & joinPath(dir, name, songs[^1][0].filterIt(it notin "<>:\"/\\|?*").join()) & ext & "\""
    discard execCmd(last_song_cmd)
# -------------------------------------------------------------------
proc get_jr_sidebar() =
    let url = "http://joyreactor.cc"
    let table = newHttpClient().getContent(url).parseHtml.findAll("div")
        .filterIt(it.attr("id") == "blogs_week_content")[0].findAll("a")
        .filterIt(it.attrs.hasKey("title")).mapIt((url & it.attr("href"), it.attr("title"))) #? Delete filter by title
    for t in table.sorted((x, y) => cmp(x[0].len, y[0].len)):
        echo t[0], "\t", t[1] #? Delete second element
# -------------------------------------------------------------------
proc get_ff_bookmarks_folder(start_id, end_id: string): seq[string] =
    var c = 0
    var flag = false
    for line in lines(""):
        c += 1
        if start_id in line:
            flag = true
        if flag and "HREF" in line:
            var name = line[line.find("\">")+2 ..< line.find("</A")].split("; ", 1)
            if name.len > 1:
                result.add(name[1].replace("&#39;", "'"))
            else:
                result.add(name[0].replace("&#39;", "'"))
            result.add(line[line.find("=\"")+2 ..< line.find("\" ")])
        if end_id in line:
            flag = false
            break
# -------------------------------------------------------------------
proc get_ff_bookmarks_folder_1(file_name: string) =
    # gets all links from subfolders
    var
        week_number = 1
        in_year = false
        in_week = false
        week = newSeq[string]()
        file_name: string

    for line in lines(file_name):
        if in_year:
            if "<DT><H3" in line:
                week_number += 1
                in_week = true
                week = newSeq[string]()
                file_name = "C:\\Users\\Asus\\Desktop\\hn\\" & "18-" & (if week_number < 10: "0" else: "") & $week_number & ".txt"
            if in_week and "HREF" in line:
                var name = line[line.find("\">")+2 ..< line.find("</A")]
                # if name.startswith("&gt; "):
                #     name = name.split("&gt; ", 1)[1]
                week.add(name.replace("&gt;", "").replace("&#39;", "'"))
                #if name.len > 1: name[1] else: name[0])
                #.replace("&#39;", "'"))
                week.add(line[line.find("=\"")+2 ..< line.find("\" ")])
            if in_week and "</DL><p>" in line:
                in_week = false
                # echo file_name
                # echo week.len()
                writeFile(file_name, week.join("\n"))
                continue
            if not in_week and "</DL><p>" in line:
                in_year = false
                continue  # ? break
        elif ">2018</H3>" in line:
            in_year = true
            continue
# -------------------------------------------------------------------
# macro test(n: varargs[untyped]): untyped =
#     for x in n.children:
#         echo x.repr

# discard test(1)
# discard test(1,2)
# discard test(1,b=2)
# -------------------------------------------------------------------
# Use Nim's macro system to transform a dense # data-centric description of x86 instructions
# into lookup tables that are used by # assemblers and JITs.
# macro toLookupTable(data: static[string]): untyped =
#   result = newTree(nnkBracket)
#   for w in data.split(';'):
#     result.add newLit(w)

# const
#   data = "mov;btc;cli;xor"
#   opcodes = toLookupTable(data)
# for o in opcodes:
#   echo o
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

# let test = collect(newSeq): (for i in 1..10: i)
# echo test
# -------------------------------------------------------------------
# randomize()
# var s = 0
# for i in 1..100:
#     var t, tt: int
#     t = rand(2)
#     if t == 0:
#         tt = rand(4) + 5
#     if t == 1:
#         tt = rand(9) + 5
#     if t == 2:
#         tt = rand(19) + 5
#     s += tt
# echo s / 100
# -------------------------------------------------------------------
# for i, j in toSeq(distinctPermutations([1,2,3,4])):
#     echo i, j
# -------------------------------------------------------------------
# type
#   Comparable = concept x, y
#     (x < y) is bool
  
#   Stack[T] = concept s, var v
#     s.pop() is T
#     v.push(T)
    
#     s.len is Ordinal
    
#     for value in s:
#       value is T
# -------------------------------------------------------------------
# var arr = newSeq[proc()]()
# for j in 0..<10:
#   closureScope:
#     let x : int = j + 1
#     let p = proc() = echo x
#     arr.add(p)

# for p in arr:
#   p()
# -------------------------------------------------------------------
# let powersOfTwo = @[1, 2, 4, 8, 16, 32, 64, 128, 256]
# echo(powersOfTwo.filter do (x: int) -> bool: x > 32)
# echo powersOfTwo.filter(proc (x: int): bool = x > 32)
# proc greaterThan32(x: int): bool = x > 32
# echo powersOfTwo.filter(greaterThan32)
# -------------------------------------------------------------------
# let mys = @[(1, 2), (3,4), (5,6), (7,8)]
# for i, (x, y) in mys:
#     echo i, x, y
# -------------------------------------------------------------------
# -------------------------------------------------------------------
# -------------------------------------------------------------------
# echo getLinksOnly(r"")
# openLinks("""""")
# findEmptyFolders(r"")
# joyGet("")
# sortHnFileByCommentsNum(r"")
# getCommentsForHnLinks(r"")
# stripFaviconImages(r"")
# deduplicateFile(r"")
# downloadLinks()
# dedupSaveOrder(r"")
# cmpFiles()
# moveToFoldersByExtension(r"")

# echo decodeUrl("")
# echo decode("")
# randomize(); echo rand(39)
# echo genOid()

# get_jr_sidebar()
# cut_by_time(r"", s)

# kg_get("")
# update_ffmpeg()
