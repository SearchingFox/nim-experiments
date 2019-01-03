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
            result.add(l[l.find('"')+1..<l.find("\" A")])
# -------------------------------------------------------------------
proc sort_hn_by_num_of_comments(links: string) =
    var r = initTable[string, int]()
    for line in readFile(links).splitLines:
        let num = parseJson(newHttpClient()
            .getContent("https://hacker-news.firebaseio.com/v0/item/$1.json" % line.split('=')[^1]))["descendants"].getInt
        r.add(line, num)
        sleep(100)
    
    for k in toSeq(r.pairs).sorted((x, y) => cmp(x[1], y[1])):
        echo k[1], " - ", k[0]
# -------------------------------------------------------------------
proc joyrDl(url: string) =
    let pics = parseHtml(newHttpClient().getContent(url)).findAll("img").mapIt(it.attr("src")).filterIt("avatar" notin it and [".jpeg", ".gif", ".png", ".jpg"].any(x => it.endsWith(x)))
    echo len(pics), "\n", pics
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
# openLinks("""""")
# joyrDl()
# sort_hn_by_num_of_comments(r"C:\Users\Asus\Desktop\hn3.txt")

# echo decodeUrl("")
# echo decode("")
# download_links()
# randomize()
# echo rand(39)+1
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
