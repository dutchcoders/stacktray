on ApplicationIsRunning(appName)
  tell application "System Events" to set appNameIsRunning to exists (processes where name is appName)
  return appNameIsRunning
end ApplicationIsRunning

set isRunning to ApplicationIsRunning("iTerm2")

tell application "iTerm2"
  tell the current terminal
      if isRunning then
          set newSession to (launch session "Default Session")
          tell the last session
              write text "clear"
              write text "$cmd"
          end tell
      else
          tell the current session
              write text "clear"
              write text "$cmd"
              activate
          end tell
      end if
  end tell
end tell

