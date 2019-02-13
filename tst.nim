import os, strutils, browsers, sequtils, sets, json, ospaths, sugar, uri, base64
import htmlparser, httpclient, xmltree, algorithm, tables, streams, random

proc getFoldersSize(path: string) =
    var size: BiggestInt = 0
    for i in walkDirRec(path):
        size += getFileSize(i)
    echo size
# -------------------------------------------------------------------
proc openLinks (inp: string) =
    for l in inp.splitLines.filterIt(it != ""): openDefaultBrowser(l)
# -------------------------------------------------------------------
proc deduplicateLines(liness: string) =
    for i in liness.splitLines.deduplicate():
        echo i
# -------------------------------------------------------------------
proc compareFiles(file1: string, file2: string) =
    let
        f1 = readFile(file1).splitLines.toSet
        f2 = readFile(file2).splitLines.toSet
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
    let pics = parseHtml(newHttpClient().getContent(url)).findAll("img").mapIt(it.attr("src")).filterIt("avatar" notin it and [".jpeg", ".gif", ".png", ".jpg"].any(x => it.endsWith(x)))
    echo len(pics), "\n", pics
# -------------------------------------------------------------------
proc stripe_favicon_images(old_file_path: string) =
    var new_html = newSeq[string]()
    for line in lines(old_file_path):
        if line.find("ICON_URI") > 0:
            new_html.add(line[0 .. line.find("ICON_URI")-2] & line[line.find("\">")+1..^1])
        else:
            new_html.add(line)
    writeFile(old_file_path[ .. ^6] & "_noicons.html", new_html.join("\n"))
# -------------------------------------------------------------------
# proc z(x: typedesc[int]): int = 0
# proc z(x: typedesc[float]): float = 0.0

# type Monoid = concept x, y
# x + y is type(x)
# z(type(x)) is type(x)

# echo "int is monoid -> ", 3 is Monoid
# let x = 3
# echo z(type(x)) # prints 0
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
    # lines_jp = readFile("D:\\32456547587\\scripts_va11halla\\jp\\").splitLines()
    # lines_eng = readFile("D:\\32456547587\\scripts_va11halla\\eng\\").splitLines()
# echo high(lines_eng)
# var out_file = ""
# for l in low(lines_jp)..high(lines_jp):
#     out_file &= lines_jp[l] & "\n" & lines_eng[l] & "\n\n"
# writeFile(joinPath(getHomeDir(), "Desktop", "learnJP.txt"), out_file)
# -------------------------------------------------------------------

# *
# echo get_links_only(r"")
openLinks("""""")
# joyrDl()
# sort_hn_by_num_of_comments(r"C:\Users\Asus\Desktop\hn1.txt")
# stripe_favicon_images(r"")
# deduplicateFile(r"")

# echo decodeUrl("")
# echo decode("")
# download_links()
# randomize()
# echo rand(39)
# var sav = newSeq[string]()
# for i in lines(r"D:\Documents\35.txt"):
#     if i != "":
#         if i notin sav:
#             sav.add(i)
#         else:
#             echo i

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

# var t = initTable[string, int]()
# for l in lines(r"C:\Users\Asus\Desktop\hn.txt"):
#     let s = l.split(" - ")
#     if len(s) == 3:
#         t.add(s[1] & " - " & s[2], s[0].parseInt)
#     else:
#         t.add(s[1], s[0].parseInt)
# for i in toSeq(t.pairs()).sorted((x, y) => cmp(x[1], y[1])):
#     echo i[1], " - ", i[0]

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


# let url = "https://thehentaiworld.com/tag/liangxing/page/2/"
# let folder = "D:\\LiangXing2\\"
# let pics = parseHtml(newHttpClient().getContent(url)).findAll("a").mapIt(it.attr("href")).filterIt("hentai-images" in it).mapIt(parseHtml(newHttpClient().getContent(it)).findAll("a").mapIt(it.attr("href")).filterIt("wp-content" in it)).concat
# echo len(pics)
# var c = 0
# for l in pics:
#     let fileName = folder & $c & "_" & l.split("/")[^1]
#     var f = newFileStream(fileName, fmWrite)
#     if not f.isNil:
#         f.write newHttpClient().getContent(l)
#     c += 1
# echo len(pics), "\n", pics