import httpclient, strutils, json, os, tables, sequtils, algorithm, sugar

proc interactive_titles() =
    var c = 1
    for line in @["https://news.ycombinator.com/item?id=14381526"]:#lines(""):
        try:
            echo c, " ", line
            echo parseJson(newHttpClient().getContent("https://hacker-news.firebaseio.com/v0/item/$1.json" % line.split('=')[^1]))["title"]
            discard readLine(stdin)
            c += 1
        except AssertionError:
            echo c, " ", line

proc sortHnFileByCommentsNum(path: string) =
    var t = initTable[string, int]()
    for l in lines(path):
        let s = l.split(" - ")
        if len(s) == 3:
            t.add(s[1] & " - " & s[2], s[0].parseInt)
        else:
            t.add(s[1], s[0].parseInt)
    for i in toSeq(t.pairs()).sorted((x, y) => cmp(x[1], y[1])):
        echo i[1], " - ", i[0]

proc getCommentsForHnLinks(path: string) =
    var r = initTable[string, (int, string)]()
    for line in lines(path):
        try:
            let json = parseJson(newHttpClient()
                .getContent("https://hacker-news.firebaseio.com/v0/item/$1.json" % line.split('=')[^1]))
            r.add(line, (json["descendants"].getInt, json["title"].getStr))
            sleep 100
        except KeyError: #! Change to something else
            echo line

    writeFile(path[0..^5] & "_comm.txt", toSeq(r.pairs).sorted((x, y) => cmp(x[1][0], y[1][0]))
        .mapIt($it[1][0] & " - " & it[0] & " - " & it[1][1] & "\n").join())


getCommentsForHnLinks(r"C:\Users\Asus\Desktop\hn5.txt")
