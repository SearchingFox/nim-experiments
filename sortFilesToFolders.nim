import os, ospaths, strutils

proc sortByExt(rootDir: string) =
    for oldFilePath in walkDirRec(rootDir):
        let newDirName = joinPath(rootDir, splitFile(oldFilePath).ext[1..^1])
        # echo newDir
        discard existsOrCreateDir(newDirName)
        # echo joinPath(newDir, extractFilename(oldFilePath))
        moveFile(oldFilePath, joinPath(newDirName, extractFilename(oldFilePath)))

proc sortBy1000(rootDir:string) =
    var curDir = 1
    var count = 0

    createDir(joinPath(rootDir, "__" & $curDir))
    for oldFilePath in walkDirRec(rootDir):
        if count < 1000:
            count += 1
            #moveFile(oldFilePath, joinPath(rootDir, "__" & $curDir, extractFilename(oldFilePath)))
            echo count, " ", joinPath(rootDir, "__" & $curDir, extractFilename(oldFilePath))
        else:
            count = 0
            curDir += 1
            #createDir(joinPath(rootDir, "__" & $curDir))
            echo curDir

proc findSameNames(rootDir: string) =
    var names = newSeq[string]()
    var count = 0
    for oldFilePath in walkDirRec(rootDir):
        var name = extractFilename(oldFilePath)
        if name notin names:
            count += 1
            names.add(name)
        else:
            echo name
    echo count
# sortBy1000()
findSameNames("")
