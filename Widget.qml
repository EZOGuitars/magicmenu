import QtQuick
import QtCore
import QtQuick.Controls
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "magicmike.frontrow"
  implicitWidth: button.implicitWidth
  implicitHeight: barSize
  Settings {
    id: preferences
    location: Qt.resolvedUrl("../../magicmenu.ini")
    property int fontSize: 16
    property int fontChoice: 0
    property int paletteChoice: 0
    property int intensity: 2
    property bool startup: true
    property bool scanlines: true
    property bool sweep: true
    property bool glitches: true
  }
  QtObject {
    id: draft
    property int fontSize: preferences.fontSize
    property int fontChoice: preferences.fontChoice
    property int paletteChoice: preferences.paletteChoice
    property int intensity: preferences.intensity
    property bool startup: preferences.startup
    property bool scanlines: preferences.scanlines
    property bool sweep: preferences.sweep
    property bool glitches: preferences.glitches
  }
  function editSettings() {
    draft.fontSize = preferences.fontSize
    draft.fontChoice = preferences.fontChoice
    draft.paletteChoice = preferences.paletteChoice
    draft.intensity = preferences.intensity
    draft.startup = preferences.startup
    draft.scanlines = preferences.scanlines
    draft.sweep = preferences.sweep
    draft.glitches = preferences.glitches
    settingsOpen = true
    Qt.callLater(function() { fontChooser.forceActiveFocus() })
  }
  function applySettings() {
    preferences.fontSize = draft.fontSize
    preferences.fontChoice = draft.fontChoice
    preferences.paletteChoice = draft.paletteChoice
    preferences.intensity = draft.intensity
    preferences.startup = draft.startup
    preferences.scanlines = draft.scanlines
    preferences.sweep = draft.sweep
    preferences.glitches = draft.glitches
    preferences.sync()
  }
  function cancelSettings() {
    settingsOpen = false
    search.forceActiveFocus()
  }
  component SettingChoice: Controls.ComboBox {
    id: choice
    property string label: ""
    width: parent.width; height: 34
    textRole: "label"
    Accessible.name: label
    contentItem: Text {
      text: choice.label + ": " + choice.displayText
      leftPadding: 10; rightPadding: 28
      color: root.ink; font.family: root.menuFont; font.pixelSize: 14
      verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight
    }
    indicator: Text {
      x: parent.width - 24; anchors.verticalCenter: parent.verticalCenter
      text: "▾"; color: root.ink; font.pixelSize: 18
    }
    background: Rectangle {
      color: root.palette.surface
      border.color: choice.activeFocus || choice.hovered ? root.ink : root.palette.line
    }
    delegate: Controls.ItemDelegate {
      id: option
      required property int index
      required property var modelData
      width: choice.width - 2; height: 30
      highlighted: choice.highlightedIndex === index
      contentItem: Text {
        text: (choice.currentIndex === option.index ? "✓ " : "  ") + option.modelData.label
        color: option.highlighted ? root.palette.bg : root.ink
        font.family: option.modelData.family || root.menuFont; font.pixelSize: 14
        verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight
      }
      background: Rectangle { color: option.highlighted ? root.ink : root.palette.surface }
    }
    popup: Controls.Popup {
      y: choice.height + 2; width: choice.width
      padding: 1
      implicitHeight: Math.min(240, options.contentHeight) + 2
      background: Rectangle { color: root.palette.surface; border.color: root.ink }
      contentItem: ListView {
        id: options
        clip: true; implicitHeight: Math.min(240, contentHeight)
        model: choice.popup.visible ? choice.delegateModel : null
        currentIndex: choice.highlightedIndex
        boundsBehavior: Flickable.StopAtBounds
        Controls.ScrollBar.vertical: Controls.ScrollBar {}
      }
    }
  }
  FontLoader { id: biosFont; source: "fonts/PxPlus_IBM_BIOS.ttf" }
  FontLoader { id: vgaFont; source: "fonts/PxPlus_IBM_VGA_8x16.ttf" }
  FontLoader { id: egaFont; source: "fonts/PxPlus_IBM_EGA_8x14.ttf" }
  readonly property var fontChoices: [
    {label: "SYSTEM MONO", family: "monospace"},
    {label: "IBM ROM / BIOS", family: biosFont.name},
    {label: "MS-DOS / IBM VGA", family: vgaFont.name},
    {label: "IBM EGA", family: egaFont.name},
    {label: "UBUNTU MONO", family: "Ubuntu Mono"},
    {label: "COURIER / NIMBUS", family: "Nimbus Mono PS"},
    {label: "LIBERATION MONO", family: "Liberation Mono"},
    {label: "JETBRAINS MONO", family: "JetBrainsMono Nerd Font"}
  ]
  readonly property string menuFont: (fontChoices[preferences.fontChoice] || fontChoices[0]).family || "monospace"
  readonly property var palettes: [
    {name: "GREEN PHOSPHOR", ink: "#71ff8b", bg: "#030e07", muted: "#58b873", line: "#296e3d", surface: "#081b0e", hover: "#103d20"},
    {name: "AMBER TERMINAL", ink: "#ffbf58", bg: "#130c03", muted: "#c89142", line: "#795321", surface: "#241807", hover: "#483012"},
    {name: "WHITE PHOSPHOR", ink: "#e5edf1", bg: "#090d10", muted: "#9babb5", line: "#4a606d", surface: "#142029", hover: "#2c414e"},
    {name: "DOS BLUE", ink: "#ffffff", bg: "#000080", muted: "#aaaaff", line: "#5555ff", surface: "#000099", hover: "#2222bb"},
    {name: "CYAN TERMINAL", ink: "#62edff", bg: "#031015", muted: "#4fabbc", line: "#216579", surface: "#08232c", hover: "#104456"}
  ]
  readonly property var palette: palettes[preferences.paletteChoice] || palettes[0]
  readonly property real fontScale: Math.max(12, Math.min(20, preferences.fontSize)) / 16
  property bool appearanceTab: true
  property bool settingsOpen: false
  readonly property real effectStrength: preferences.intensity === 2 ? 1.8 : 0.7
  readonly property bool effectsEnabled: preferences.intensity > 0
  function preview() {
    if (effectsEnabled && preferences.startup) boot.restart()
    if (effectsEnabled && preferences.glitches) glitch.restart()
  }
  component MenuButton: Controls.Button {
    id: control
    height: 34
    hoverEnabled: true
    contentItem: Text {
      text: control.text
      elide: Text.ElideRight
      color: control.down || control.activeFocus ? root.palette.bg : root.ink
      font.family: root.menuFont; font.pixelSize: 14
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
    }
    background: Rectangle {
      color: control.down || control.activeFocus ? root.ink : control.hovered ? root.palette.hover : root.palette.surface
      border.color: control.hovered || control.activeFocus ? root.ink : root.palette.line
      Behavior on color { ColorAnimation { duration: 100 } }
    }
  }
  property string statsText: "CPU --  |  RAM --  |  DISK / --"
  property real previousCpuTotal: -1
  property real previousCpuIdle: 0
  property var previousNetwork: ({})
  property real previousSampleTime: 0
  property string networkText: "NET ↑ sampling…  ↓ sampling…"
  function networkRate(bytes) {
    if (bytes >= 1048576) return (bytes / 1048576).toFixed(1) + " MiB/s"
    return (bytes / 1024).toFixed(1) + " KiB/s"
  }
  function updateStats() {
    if (opened && !statsProcess.running) statsProcess.running = true
  }
  Process {
    id: statsProcess
    // Use a fixed interpreter and an isolated startup environment. This keeps
    // inherited PATH/PYTHONPATH/sitecustomize state out of the helper.
    command: ["/usr/bin/env", "-i", "PATH=/usr/bin:/bin", "PYTHONNOUSERSITE=1", "PYTHONPATH=", "/usr/bin/python3", Qt.resolvedUrl("system-stats.py").toString().replace("file://", "")]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          var sample = JSON.parse(text)
          var delta = sample.cpuTotal - root.previousCpuTotal
          var cpu = root.previousCpuTotal >= 0 && delta > 0
            ? Math.round(Math.max(0, Math.min(100, 100 * (1 - (sample.cpuIdle - root.previousCpuIdle) / delta)))) + "%" : "--"
          var elapsed = sample.time - root.previousSampleTime
          var rx = 0, tx = 0
          for (var name in sample.network) {
            var before = root.previousNetwork[name]
            if (before && elapsed > 0) {
              rx += Math.max(0, sample.network[name].rx - before.rx) / elapsed
              tx += Math.max(0, sample.network[name].tx - before.tx) / elapsed
            }
          }
          root.networkText = root.previousSampleTime > 0
            ? "NET ↑ " + root.networkRate(tx) + "   ↓ " + root.networkRate(rx)
            : "NET ↑ sampling…  ↓ sampling…"
          root.previousNetwork = sample.network
          root.previousSampleTime = sample.time
          root.previousCpuTotal = sample.cpuTotal
          root.previousCpuIdle = sample.cpuIdle
          root.statsText = "CPU " + cpu + "  |  RAM " + sample.ramUsed.toFixed(1) + "/" + sample.ramTotal.toFixed(1)
            + " GiB  |  DISK / " + Math.round(sample.diskUsed / sample.diskTotal * 100) + "%"
        } catch (error) {
          root.statsText = "SYSTEM STATS UNAVAILABLE"
        }
      }
    }
  }
  Timer {
    interval: 2000
    repeat: true
    running: root.opened
    onTriggered: root.updateStats()
  }
  Timer {
    id: firstStatsSample
    interval: 250
    onTriggered: root.updateStats()
  }
  property bool opened: false
  property bool interactionActive: false
  property real bootProgress: 1
  property real glitchProgress: 0
  property int idleGlitches: 0
  function activity() {
    if (!opened) return
    interactionActive = true
    interactionSleep.restart()
    glitch.stop()
    glitchProgress = 0
    idleTimer.restart()
  }
  onOpenedChanged: {
    if (opened) {
      previousCpuTotal = -1
      previousSampleTime = 0
      previousNetwork = ({})
      statsText = "CPU sampling…  |  RAM --  |  DISK / --"
      networkText = "NET ↑ sampling…  ↓ sampling…"
      updateStats()
      firstStatsSample.restart()
      interactionActive = true
      interactionSleep.restart()
      if (effectsEnabled && preferences.startup) boot.restart()
      idleTimer.restart()
    } else {
      firstStatsSample.stop()
      interactionSleep.stop()
      interactionActive = false
      idleTimer.stop()
      boot.stop()
      glitch.stop()
      bootProgress = 1
      glitchProgress = 0
    }
  }
  Timer {
    id: interactionSleep
    interval: 1400
    onTriggered: root.interactionActive = false
  }
  Timer {
    id: idleTimer
    interval: preferences.intensity === 2 ? 3500 : 6000
    onTriggered: if (root.opened && root.interactionActive && root.effectsEnabled && preferences.glitches) { root.idleGlitches++; glitch.restart() }
  }
  NumberAnimation {
    id: boot
    target: root; property: "bootProgress"
    from: 0; to: 1; duration: preferences.intensity === 2 ? 680 : 440
    easing.type: Easing.OutCubic
  }
  NumberAnimation {
    id: glitch
    target: root; property: "glitchProgress"
    from: 0; to: 1; duration: preferences.intensity === 2 ? 360 : 220
    onFinished: { root.glitchProgress = 0; if (root.opened) idleTimer.restart() }
  }
  property string category: ""
  property var entries: []
  readonly property var library: bar && bar.shell ? bar.shell.appLibrary : null
  readonly property color ink: palette.ink
  // The inline app menu needs the manifest's menu capability for appLibrary.
  onLibraryChanged: Qt.callLater(refresh)
  function refresh() {
    var apps = library ? library.sortedEntries(search.text).map(function(row) { return row.entry }) : []
    entries = apps.filter(function(app) {
      return search.text.trim() !== "" || category === "" ||
        (app.categories || []).indexOf(category) >= 0
    })
    grid.currentIndex = entries.length ? 0 : -1
  }
  function open() {
    if (bar) bar.requestPopout(root)
    category = ""
    if (library) library.refreshIcons()
    search.text = ""
    refresh()
    opened = true
    Qt.callLater(function() { search.forceActiveFocus() })
  }
  function close() {
    if (settingsOpen) return
    opened = false
    settingsOpen = false
    preferences.sync()
    if (bar) bar.releasePopout(root)
  }
  function launch(index) {
    if (index < 0 || index >= entries.length || !library) return
    var app = entries[index]
    close()
    library.launch(app.id, library.entryName(app))
  }
  IpcHandler {
    target: "magicmike.frontrow"
    function open(): void { root.open() }
    function toggle(): void { root.opened ? root.close() : root.open() }
    function close(): void { root.close() }
    function settings(): void { root.open(); root.editSettings() }
    function preview(): void { root.preview() }
    function count(): string { return String(root.entries.length) }
    function effects(): string {
      return JSON.stringify({opened: root.opened, boot: boot.running, glitch: glitch.running,
        idleTimer: idleTimer.running, idleGlitches: root.idleGlitches, intensity: preferences.intensity, settings: root.settingsOpen, font: root.menuFont, fontSize: preferences.fontSize, stats: root.statsText, network: root.networkText, fontStatus: [biosFont.status, vgaFont.status, egaFont.status], palette: root.palette.name, sweep: sweepAnimation.running})
    }
  }
  Connections {
    target: root.library
    function onAppsChanged() { root.refresh() }
  }
  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "[ MagicMenu ]"
    foreground: root.ink
    fontFamily: root.menuFont
    horizontalMargin: 10
    onPressed: root.opened ? root.close() : root.open()
  }
  KeyboardPanel {
    id: panel
    anchorItem: button
    bar: root.bar
    owner: root
    open: root.opened
    contentWidth: Math.min(720 * root.fontScale, screen ? screen.width - 60 : 720 * root.fontScale)
    contentHeight: Math.min(580 * root.fontScale, screen ? screen.height - 70 : 580 * root.fontScale)
    padding: 8
    borderSpec: Border.flat(root.palette.line, 1)
    // The panel is a full-screen layer for input routing, but must remain
    // visually transparent outside the card itself.
    color: "transparent"
    focusTarget: search
    Item {
      id: terminal
      width: parent.width / root.fontScale
      height: parent.height / root.fontScale
      scale: root.fontScale
      transformOrigin: Item.TopLeft
      Keys.onEscapePressed: root.close()
      clip: true
      HoverHandler { onPointChanged: root.activity() }
      TapHandler { onTapped: root.activity() }
      Item {
        id: crtContent
        anchors.fill: parent
        transform: Translate {
          x: glitch.running ? Math.sin(root.glitchProgress * 28) * root.effectStrength : 0
        }
      Rectangle {
        anchors.fill: parent
        anchors.margins: -8
        color: root.palette.bg
        border.color: root.palette.line
        border.width: 1
      }
      Rectangle {
        anchors.fill: parent
        anchors.margins: -3
        color: "transparent"
        border.color: root.ink
        border.width: 1
        opacity: 0.55
      }
      Text {
        x: 12; y: 7
        width: parent.width - 24
        elide: Text.ElideRight
        text: "╔═ MagicMenu / APPLICATION DIRECTORY ═╗"
        color: root.ink
        font.family: root.menuFont; font.pixelSize: 19; font.bold: true
      }
      Text {
        x: 12; y: 36
        width: parent.width - 160
        elide: Text.ElideRight
        text: "PERSONAL COMPUTER  ·  SYSTEM READY"
        color: root.palette.muted
        font.family: root.menuFont; font.pixelSize: 13
      }
      Text {
        x: 12; y: 61
        width: parent.width - 24
        text: root.statsText
        color: root.ink
        font.family: root.menuFont; font.pixelSize: 13
        elide: Text.ElideRight
      }
      Text {
        x: 12; y: 82
        width: parent.width - 24
        text: root.networkText
        color: root.ink
        font.family: root.menuFont; font.pixelSize: 13
        elide: Text.ElideRight
      }
      MenuButton {
        x: parent.width - width - 10; y: 30
        width: 124; height: 28
        text: "[ SETTINGS ]"
        onClicked: root.editSettings()
      }
      TextField {
        id: search
        x: 10; y: 110
        width: parent.width - 20; height: 38
        placeholderText: "C:\\MAGIC> type to search_"
        font.family: root.menuFont; font.pixelSize: 18
        color: root.ink
        placeholderTextColor: root.palette.muted
        selectionColor: root.ink
        selectedTextColor: root.palette.bg
        leftPadding: 10
        background: Rectangle {
          color: root.palette.surface
          border.color: root.palette.line
        }
        onTextChanged: { root.activity(); root.refresh() }
        Keys.onReleased: function(event) { root.activity(); event.accepted = false }
        onAccepted: root.launch(grid.currentIndex)
        Keys.onDownPressed: { grid.forceActiveFocus(); if (grid.currentIndex < 0 && grid.count) grid.currentIndex = 0 }
        Keys.onEscapePressed: root.close()
      }
      Text {
        x: 12; y: 161
        text: "GROUP"
        color: root.palette.muted
        font.family: root.menuFont; font.pixelSize: 13
      }
      Text {
        x: 191; y: 161
        text: "PROGRAM NAME"
        color: root.palette.muted
        font.family: root.menuFont; font.pixelSize: 13
      }
      Rectangle {
        x: 176; y: 160; width: 1; height: parent.height - 249
        color: root.palette.line
      }
      Column {
        x: 10; y: 185; width: 156; spacing: 2
        Repeater {
          model: [
            {name: "ALL PROGRAMS", tag: ""},
            {name: "INTERNET", tag: "Network"},
            {name: "MEDIA", tag: "AudioVideo"},
            {name: "GRAPHICS", tag: "Graphics"},
            {name: "WORK", tag: "Office"},
            {name: "DEVELOPMENT", tag: "Development"},
            {name: "GAMES", tag: "Game"},
            {name: "UTILITIES", tag: "Utility"}
          ]
          delegate: Rectangle {
            required property var modelData
            width: 156; height: 32
            color: root.category === modelData.tag ? root.ink : categoryMouse.containsMouse ? root.palette.hover : "transparent"
            Text {
              anchors.verticalCenter: parent.verticalCenter
              x: 5
              text: (root.category === modelData.tag ? "> " : "  ") + modelData.name
              color: root.category === modelData.tag ? root.palette.bg : root.ink
              font.family: root.menuFont; font.pixelSize: 14
            }
            MouseArea {
              id: categoryMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: { root.activity(); root.category = modelData.tag; search.text = ""; root.refresh(); search.forceActiveFocus() }
            }
          }
        }
      }
      ListView {
        id: grid
        x: 188; y: 185
        width: parent.width - x - 12
        height: parent.height - y - 89
        clip: true
        model: root.entries
        onContentYChanged: root.activity()
        onCurrentIndexChanged: root.activity()
        Keys.onReleased: function(event) { root.activity(); event.accepted = false }
        keyNavigationEnabled: true
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar {
          contentItem: Rectangle { implicitWidth: 4; color: root.palette.muted }
          background: Rectangle { color: root.palette.surface }
        }
        Keys.onReturnPressed: root.launch(currentIndex)
        Keys.onEnterPressed: root.launch(currentIndex)
        Keys.onEscapePressed: root.close()
        Keys.onPressed: function(event) {
          if (event.text && event.text.length === 1 && !(event.modifiers & (Qt.ControlModifier | Qt.AltModifier))) {
            search.forceActiveFocus()
            search.insert(search.cursorPosition, event.text)
            event.accepted = true
          }
        }
        delegate: Rectangle {
          id: row
          required property var modelData
          required property int index
          width: grid.width - 10; height: 32
          color: grid.currentIndex === index ? root.ink : "transparent"
          Image {
            x: 8; anchors.verticalCenter: parent.verticalCenter
            width: 24; height: 24
            source: root.library ? root.library.iconSource(row.modelData.icon) : ""
            fillMode: Image.PreserveAspectFit
            smooth: false
          }
          Text {
            x: 42; anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 50
            text: (grid.currentIndex === row.index ? "► " : "  ") + String(row.index + 1).padStart(2, "0") + "  " + (root.library ? root.library.entryName(row.modelData) : "")
            textFormat: Text.PlainText
            color: grid.currentIndex === row.index ? root.palette.bg : root.ink
            font.family: root.menuFont; font.pixelSize: 16
            elide: Text.ElideRight
          }
          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.launch(row.index)
            onPositionChanged: grid.currentIndex = row.index
          }
        }
      }
      Text {
        anchors.centerIn: grid
        visible: grid.count === 0
        text: !root.library ? "APP LIBRARY UNAVAILABLE" : "NO PROGRAMS FOUND"
        color: root.ink
        font.family: root.menuFont; font.pixelSize: 15
      }
      Rectangle {
        x: 10; width: parent.width - 20; height: 1
        anchors.bottom: parent.bottom; anchors.bottomMargin: 78
        color: root.palette.line
      }
      Text {
        x: 12; anchors.bottom: parent.bottom; anchors.bottomMargin: 54
        text: "↑↓ SELECT  ENTER RUN  ESC EXIT" + "    " + grid.count + " FILES"
        color: root.ink
        font.family: root.menuFont; font.pixelSize: 14
      }
      Row {
        id: sessionControls
        x: 10
        width: parent.width - 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        spacing: 8
        Repeater {
          model: [
            {label: "SHUTDOWN", action: "shutdown"},
            {label: "RESTART", action: "reboot"},
            {label: "LOGOUT", action: "logout"},
            {label: "LOCK", action: "lock"}
          ]
          delegate: Controls.Button {
            id: sessionButton
            required property var modelData
            width: (sessionControls.width - sessionControls.spacing * 3) / 4
            height: 34
            text: modelData.label
            hoverEnabled: true
            Accessible.name: text
            contentItem: Text {
              text: sessionButton.text
              color: sessionButton.down || sessionButton.activeFocus ? root.palette.bg : root.ink
              font.family: root.menuFont
              font.pixelSize: 14
              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
              color: sessionButton.down || sessionButton.activeFocus ? root.ink : sessionButton.hovered ? root.palette.hover : root.palette.surface
              border.color: sessionButton.hovered || sessionButton.activeFocus ? root.ink : root.palette.line
            }
            onClicked: {
              root.close()
              Quickshell.execDetached(["/usr/share/omarchy/bin/omarchy", "system", modelData.action])
            }
          }
        }
      }
      // Static phosphor texture: no flicker, timer, or continuous repaint.
      Item {
        anchors.fill: parent
        enabled: false
        Repeater {
          model: Math.ceil(terminal.height / 4)
          Rectangle {
            required property int index
            y: index * 4; width: terminal.width; height: 1
            color: "#000000"; opacity: root.effectsEnabled && preferences.scanlines ? 0.10 * root.effectStrength : 0
          }
        }
      }
      }
      // Slow phosphor sweep runs only while the menu is visible.
      Rectangle {
        id: phosphorSweep
        width: terminal.width; height: 72
        enabled: false
        visible: root.opened && root.interactionActive && root.effectsEnabled && preferences.sweep
        opacity: 0.08 * root.effectStrength
        gradient: Gradient {
          GradientStop { position: 0; color: "transparent" }
          GradientStop { position: 0.65; color: root.ink }
          GradientStop { position: 1; color: "transparent" }
        }
        NumberAnimation on y {
          id: sweepAnimation
          from: -72; to: terminal.height
          duration: preferences.intensity === 2 ? 2800 : 4500
          loops: Animation.Infinite
          running: root.opened && root.interactionActive && root.effectsEnabled && preferences.sweep
        }
      }
      Rectangle {
        anchors.fill: parent
        enabled: false
        color: "transparent"
        border.color: root.ink
        border.width: 2
        opacity: root.effectsEnabled ? 0.35 : 0
        SequentialAnimation on opacity {
          running: root.opened && root.interactionActive && root.effectsEnabled && preferences.sweep
          loops: Animation.Infinite
          NumberAnimation { to: 0.7; duration: 1400 }
          NumberAnimation { to: 0.2; duration: 1400 }
        }
      }
      // CRT vertical expansion and a soft phosphor sweep on power-on.
      Rectangle {
        width: terminal.width
        height: terminal.height * (1 - root.bootProgress) / 2
        color: root.palette.bg
        visible: boot.running
      }
      Rectangle {
        anchors.bottom: parent.bottom
        width: terminal.width
        height: terminal.height * (1 - root.bootProgress) / 2
        color: root.palette.bg
        visible: boot.running
      }
      Rectangle {
        width: terminal.width
        height: 34
        y: root.bootProgress * (terminal.height + height) - height
        visible: boot.running
        opacity: (1 - root.bootProgress) * 0.35 * root.effectStrength
        gradient: Gradient {
          GradientStop { position: 0; color: "transparent" }
          GradientStop { position: 0.5; color: root.ink }
          GradientStop { position: 1; color: "transparent" }
        }
      }
      // Load the tear slices only during a short idle burst; no idle GPU loop.
      Loader {
        anchors.fill: parent
        active: glitch.running
        sourceComponent: Item {
          Repeater {
            model: 3
            ShaderEffectSource {
              required property int index
              readonly property real bandY: terminal.height * (0.23 + index * 0.24)
              x: Math.sin(root.glitchProgress * 35 + index * 2) * (7 + index * 3) * root.effectStrength
              y: bandY
              width: terminal.width
              height: 8 + index * 5
              sourceItem: crtContent
              sourceRect: Qt.rect(0, bandY, terminal.width, height)
              live: true
              opacity: 0.75 * Math.sin(root.glitchProgress * Math.PI)
            }
          }
          Rectangle {
            width: terminal.width; height: 2
            y: root.glitchProgress * terminal.height
            color: root.ink; opacity: 0.15
          }
        }
      }
      Rectangle {
        anchors.fill: parent
        visible: root.settingsOpen
        color: root.palette.bg
        MouseArea { anchors.fill: parent }
        Rectangle {
          anchors.centerIn: parent
          width: Math.min(560, parent.width - 24)
          height: Math.min(470, parent.height - 24)
          color: root.palette.bg; border.color: root.ink
          clip: true
          Column {
            anchors.fill: parent; anchors.margins: 18; spacing: 10
            Text {
              text: "MAGICMENU / SETTINGS"
              color: root.ink; font.family: root.menuFont
              font.pixelSize: 20; font.bold: true
            }
            Row {
              width: parent.width; spacing: 10
              MenuButton {
                width: (parent.width - 10) / 2
                text: (root.appearanceTab ? "> " : "") + "APPEARANCE"
                onClicked: root.appearanceTab = true
              }
              MenuButton {
                width: (parent.width - 10) / 2
                text: (!root.appearanceTab ? "> " : "") + "EFFECTS"
                onClicked: root.appearanceTab = false
              }
            }
            Column {
              visible: root.appearanceTab
              width: parent.width; spacing: 12
              SettingChoice {
                id: fontChooser
                label: "FONT"; model: root.fontChoices
                currentIndex: draft.fontChoice
                onActivated: draft.fontChoice = currentIndex
              }
              SettingChoice {
                label: "FONT SIZE"
                model: [{label: "12 px"}, {label: "13 px"}, {label: "14 px"}, {label: "15 px"}, {label: "16 px"}, {label: "17 px"}, {label: "18 px"}, {label: "19 px"}, {label: "20 px"}]
                currentIndex: draft.fontSize - 12
                onActivated: draft.fontSize = currentIndex + 12
              }
              SettingChoice {
                label: "COLOR"
                model: root.palettes.map(function(p) { return {label: p.name} })
                currentIndex: draft.paletteChoice
                onActivated: draft.paletteChoice = currentIndex
              }
              Rectangle {
                width: parent.width; height: 116
                color: root.palettes[draft.paletteChoice].surface
                border.color: root.palettes[draft.paletteChoice].line
                clip: true
                Text {
                  anchors.fill: parent; anchors.margins: 12
                  text: "C:\\MAGIC> Hello, world!_\nABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz\n0123456789  ╔═╗ ┌─┐ ♥ ►"
                  font.family: root.fontChoices[draft.fontChoice].family || "monospace"
                  font.pixelSize: draft.fontSize
                  color: root.palettes[draft.paletteChoice].ink
                  wrapMode: Text.WrapAnywhere
                }
              }
            }
            Column {
              visible: !root.appearanceTab
              width: parent.width; spacing: 12
              SettingChoice {
                label: "INTENSITY"
                model: [{label: "OFF"}, {label: "SUBTLE"}, {label: "FLASHY"}]
                currentIndex: draft.intensity
                onActivated: draft.intensity = currentIndex
              }
              Repeater {
                model: [{label: "STARTUP ANIMATION", key: "startup"},
                        {label: "SCANLINES", key: "scanlines"},
                        {label: "SWEEP + GLOW", key: "sweep"},
                        {label: "IDLE GLITCHES", key: "glitches"}]
                delegate: SettingChoice {
                  required property var modelData
                  label: modelData.label
                  model: [{label: "OFF"}, {label: "ON"}]
                  currentIndex: draft[modelData.key] ? 1 : 0
                  onActivated: draft[modelData.key] = currentIndex === 1
                }
              }
            }
            Row {
              width: parent.width; spacing: 10
              MenuButton {
                width: (parent.width - 20) / 3; text: "CANCEL"
                onClicked: root.cancelSettings()
              }
              MenuButton {
                width: (parent.width - 20) / 3; text: "APPLY"
                onClicked: root.applySettings()
              }
              MenuButton {
                width: (parent.width - 20) / 3; text: "OK"
                onClicked: { root.applySettings(); root.cancelSettings() }
              }
            }
            Text {
              width: parent.width
              text: "Apply saves and stays here. OK saves and returns to the menu."
              wrapMode: Text.WordWrap
              color: root.palette.muted; font.family: root.menuFont; font.pixelSize: 12
            }
          }
        }
      }
    }
  }
}
