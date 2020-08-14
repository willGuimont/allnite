import os
import json
import strutils


type
    Argument = object
        name      : string
        value     : string
        argType   : string
    Execution = object
        name        : string
        executable  : string
        arguments   : seq[Argument]
        redirectLog : bool
    Runs = object
        logDir  : string
        runs    : seq[Execution]


when isMainModule:
    if paramCount() != 1:
        echo "Expected: allnite <path/run/config>"
        quit(1)
    
    let fileContent = readFile(paramStr(1))
    let fromJson = parseJson(fileContent)

    let runs = to(fromJson, Runs)

    echo runs.logDir
    createDir(runs.logDir)

    for i, run in runs.runs:
        echo "[$1/$2] Running $3..." % [$(i + 1), $len(runs.runs), run.name]
        var cmd = run.executable;

        for arg in run.arguments:
            if arg.name != "":
                var dash = "";
                if arg.argType == "short":
                    dash = "-"
                elif arg.argType == "long":
                    dash = "--"
                cmd = cmd & " $1$2" % [dash, arg.name] 
            cmd = cmd & " " & arg.value
        
        if run.redirectLog:
            cmd = "($1) > $2/$3" % [cmd, runs.logDir, run.name]

        echo "\tExecuting: ", cmd
        discard execShellCmd(cmd)
