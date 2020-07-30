import lists
import os
import json
import strutils


type
    Parameter = object
        name  : string
        value : string
    Execution = object
        name        : string
        executable  : string
        parameters  : seq[Parameter]
        redirectLog : bool
    Runs = object
        logDir : string
        runs    : seq[Execution]

when isMainModule:
    import parseopt

    if paramCount() != 1:
        echo "Expected: allnite path/run/config"
        quit(1)
    
    let fileContent = readFile(paramStr(1))
    let fromJson = parseJson(fileContent)

    let runs = to(fromJson, Runs)

    echo runs.logDir
    createDir(runs.logDir)

    for i, run in runs.runs:
        echo "[", i + 1, "/", len(runs.runs), "] Running ", run.name, "..."
        var cmd = run.executable;

        for param in run.parameters:
            if param.name != "":
                cmd = cmd & " --" & param.name
            cmd = cmd & " " & param.value
        
        if run.redirectLog:
            cmd = "(" & cmd & ")" & " > " & runs.logDir & "/" & run.name

        echo "\tExecuting: ", cmd
        discard execShellCmd(cmd)
