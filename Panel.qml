import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// Tip of the day on the bar: the current tip, with previous and next.
// Service.qml sends the daily notification; this widget (one per monitor)
// only reads ~/.local/state/omarchy/tips.json and runs scripts/tip next/prev.
Panel {
  id: root
  moduleName: "techspawn.tips"
  ipcTarget: "techspawn.tips"
  manageIpc: true

  readonly property string helper: Qt.resolvedUrl("scripts/tip").toString().replace(/^file:\/\//, "")
  readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")) + "/omarchy"
  readonly property color fg: root.bar ? root.bar.foreground : Commons.Color.foreground
  readonly property string font: root.bar ? root.bar.fontFamily : Style.font.family

  // Nerd Font (Material Design): md-lightbulb_on, md-chevron_left, md-chevron_right, md-pencil.
  readonly property string glyphTip: String.fromCodePoint(0xF06E8)
  readonly property string glyphPrev: String.fromCodePoint(0xF0141)
  readonly property string glyphNext: String.fromCodePoint(0xF0142)
  readonly property string glyphEdit: String.fromCodePoint(0xF03EB)

  property var tipState: ({ history: [], pos: -1, seen: [] })
  readonly property var history: tipState.history || []
  readonly property int pos: tipState.pos === undefined ? history.length - 1 : tipState.pos
  readonly property var tip: pos >= 0 && pos < history.length ? history[pos] : null
  readonly property bool busy: stepProc.running

  function step(cmd) {
    if (stepProc.running) return
    stepProc.command = [root.helper, cmd]
    stepProc.running = true
  }

  onOpenedChanged: if (root.opened) { stateFile.reload(); if (!root.tip) step("current") }

  FileView {
    id: stateFile
    path: root.stateDir + "/tips.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: { try { var d = JSON.parse(text()); if (d) root.tipState = d } catch (e) {} }
  }

  Process {
    id: stepProc
    command: [root.helper, "current"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: stateFile.reload()
    }
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.glyphTip
    tooltipText: root.tip ? "Tip · " + root.tip.topic : "Tip of the day"
    onPressed: function(b) { root.toggle() }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(440))
    contentHeight: panel.fittedContentHeight(column.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onMoveRequested: function(dx, dy) {
        var d = dx || dy
        if (d < 0) root.step("prev")
        else if (d > 0) root.step("next")
      }
      onActivateRequested: root.step("next")

      Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Style.space(12)

        Item {
          width: parent.width
          implicitHeight: Math.max(hero.implicitHeight, editButton.implicitHeight)
          Row {
            id: hero
            spacing: Style.space(14)
            anchors.verticalCenter: parent.verticalCenter
            Text {
              text: root.glyphTip
              color: root.fg; font.family: root.font; font.pixelSize: Style.font.display
              anchors.verticalCenter: parent.verticalCenter
            }
            Column {
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(2)
              Text { text: "Tip of the day"; color: root.fg; font.family: root.font; font.pixelSize: Style.font.title; font.bold: true }
              Text {
                text: (root.tip ? root.tip.topic : "No tip yet").toUpperCase()
                color: Qt.darker(root.fg, 1.4)
                font.family: root.font; font.pixelSize: Style.font.caption; font.bold: true; font.letterSpacing: 1.2
              }
            }
          }
          Button {
            id: editButton
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            iconText: root.glyphEdit; tooltipText: "Time of day, notifications and topics"
            foreground: root.fg; fontFamily: root.font
            onClicked: { Quickshell.execDetached([root.helper, "edit"]); root.close() }
          }
        }

        Rectangle {
          width: parent.width
          implicitHeight: tipText.implicitHeight + Style.space(24)
          radius: Style.cornerRadius
          color: Qt.rgba(root.fg.r, root.fg.g, root.fg.b, 0.05)
          Text {
            id: tipText
            anchors.left: parent.left; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Style.space(12)
            text: root.tip ? root.tip.tip : (root.busy ? "Picking a tip…" : "Press Enter for a tip.")
            textFormat: Text.PlainText
            wrapMode: Text.Wrap
            color: root.fg; font.family: root.font; font.pixelSize: Style.font.body
          }
        }

        Item {
          width: parent.width
          implicitHeight: navRow.implicitHeight
          Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - navRow.width - Style.space(10)
            elide: Text.ElideRight
            text: (root.tipState.seen || []).length + " seen · no repeats until you have seen them all"
            color: Qt.darker(root.fg, 1.8); font.family: root.font; font.pixelSize: Style.font.caption
          }
          Row {
            id: navRow
            anchors.right: parent.right
            spacing: Style.space(6)
            Button {
              iconText: root.glyphPrev; text: "Previous"; tooltipText: "The tip before this one (h)"
              visible: root.pos > 0
              bordered: true; fontSize: Style.font.caption
              foreground: root.fg; fontFamily: root.font
              onClicked: root.step("prev")
            }
            Button {
              text: "Next  " + root.glyphNext; tooltipText: "Another tip (l or Enter)"
              bordered: true; fontSize: Style.font.caption
              foreground: root.fg; fontFamily: root.font
              onClicked: root.step("next")
            }
          }
        }
      }
    }
  }
}
