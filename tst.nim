import os, strutils, browsers, sequtils, sets, json, ospaths, sugar, uri, base64, streams
import htmlparser
import httpclient
import xmltree

proc getFoldersSize(path: string) =
    var size: BiggestInt = 0
    for i in walkDirRec(path):
        size += getFileSize(i)
    echo size
# -------------------------------------------------------------------
proc openLinks (inp: string) =
    for l in inp.splitLines: openDefaultBrowser(l)
# -------------------------------------------------------------------
proc deduplicateLines(lines: string) =
    for i in lines.splitLines.deduplicate:
        echo i
# -------------------------------------------------------------------
proc compareFiles(file1: string, file2: string) =
    var f1 = readFile(file1).splitLines.toSet
    var f2 = readFile(file2).splitLines.toSet
    var outFile = toSeq(items(f1 - f2)).join("\n") & "\n" & repeat('-', 80) & "\n" & toSeq(items(f2 - f1)).join("\n")
    writeFile(joinPath(getHomeDir(), "Desktop", "out.txt"), outFile)
# -------------------------------------------------------------------
proc deleteLinesFromFile(filePath: string, linesSeq: seq[string]) =
    var fileContent = readFile(filePath).splitLines
    writeFile(filePath, fileContent.filterIt(it notin linesSeq).join("\n"))
# -------------------------------------------------------------------
proc deduplicateFile(filePath: string) =
    var fileContent = readFile(filePath).splitLines
    writeFile(filePath, fileContent.deduplicate.join("\n"))
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
# var outSeq = newSeq[string]()
# for _, file in walkDir(joinPath(getHomeDir(), "Desktop", "firefox_tabs_181019_1348")):
#     outSeq.add(readFile(file))
# writeFile(joinPath(getHomeDir(), "Desktop", "firefox_tabs_181019_1944.txt"), outSeq.deduplicate.join("\n"))
# -------------------------------------------------------------------
proc findEmptyFolders(path: string) =
    for file in walkDirRec(path):
        echo file
# -------------------------------------------------------------------
proc prettyPrint(file: string) =
    var c = 1
    var text = ""
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
        let fileName = joinPath(folder, $i & ".jpg")#pic_url.split('/')[^1])

        var f = newFileStream(fileName, fmWrite)
        if not f.isNil:
            f.write newHttpClient().getContent(pic_url)
        echo "Saved ", fileName
        # sleep(500)
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
#TODO: script to update all programms from github

# openLinks("""""")
# echo decodeUrl("")
# echo decode("")
# download_links()
