import httpclient
import json
import os
import sequtils
import streams
import strutils

var client = newHttpClient()
client.headers["Authorization"] = readFile(joinPath(getAppDir(), "config"))

echo "Enter URL:"
var link = readLine stdin
link = if link[^1] == '/': link[0..^2] else: link
echo link

var data = parseJson(client.getContent("https://api.imgur.com/3/album/" & link.split('/')[^1]))["data"]

let folderName = "D:\\" & filter(data["title"].getStr, proc (i: char): bool = i notin "/\\:*?\"<>|").join() & "\\"
echo folderName
discard existsOrCreateDir(folderName)

var c = 0
for node in data["images"]:
    let fileName = folderName & $c & "_" & node["id"].getStr & "." & node["type"].getStr.split("/")[1]
    echo "Saving ", fileName
    
    var f = newFileStream(fileName, fmWrite)
    if not f.isNil:
        f.write client.getContent(node["link"].getStr)
    
    c += 1
