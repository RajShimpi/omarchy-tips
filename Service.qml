import QtQuick
import Quickshell.Io

// The one place that notifies. Every minute `tip daily` checks whether
// today's tip is due (time in ~/.config/omarchy/tips.json, default 09:00).
// It shows one tip a day, catches up at the first check after a sleep or
// shutdown, and remembers what it showed in ~/.local/state/omarchy/tips.json,
// so a shell restart never repeats it.
Item {
  id: root
  readonly property string helper: Qt.resolvedUrl("scripts/tip").toString().replace(/^file:\/\//, "")

  Process { id: daily; command: [root.helper, "daily"] }

  // Give the session a moment after login or a shell restart, then check every minute.
  Timer {
    interval: 20000; running: true
    onTriggered: { if (!daily.running) daily.running = true; tick.running = true }
  }
  Timer { id: tick; interval: 60000; repeat: true; onTriggered: if (!daily.running) daily.running = true }
}
