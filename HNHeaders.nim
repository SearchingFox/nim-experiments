import httpclient,
       strutils,
       json,
       os

var c = 1
for line in lines(""):
    try:
        echo c, " ", line
        echo parseJson(newHttpClient().getContent("https://hacker-news.firebaseio.com/v0/item/$1.json" % line.split('=')[^1]))["title"]
        discard readLine(stdin)
        c += 1
    except AssertionError:
        echo c, " ", line
