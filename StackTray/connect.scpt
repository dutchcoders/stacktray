tell application "iTerm"
    activate
    set myterm to (make new terminal)
    tell myterm
            set mysession to (make new session at the end of sessions)
            tell mysession
                set name to "%@"
                exec command  "ssh %@@@%@"
            end tell
    end tell
end tell
