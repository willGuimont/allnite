import os
import json
import strutils


type
    Parameter = object
        name      : string
        value     : string
        paramType : string
    Execution = object
        name        : string
        executable  : string
        parameters  : seq[Parameter]
        redirectLog : bool
    Runs = object
        logDir : string
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

        for param in run.parameters:
            if param.name != "":
                var dash = "";
                if param.paramType == "short":
                    dash = "-"
                elif param.paramType == "long":
                    dash = "--"
                cmd = cmd & " $1$2" % [dash, param.name] 
            cmd = cmd & " " & param.value
        
        if run.redirectLog:
            cmd = "($1) > $2/$3" % [cmd, runs.logDir, run.name]

        echo "\tExecuting: ", cmd
        discard execShellCmd(cmd)
