import QtQuick
import Quickshell

Item {
  function open(payload) {
    Quickshell.execDetached(["/usr/share/omarchy/bin/omarchy-shell", "magicmike.frontrow", "open"])
  }
  function close() {
    Quickshell.execDetached(["/usr/share/omarchy/bin/omarchy-shell", "magicmike.frontrow", "close"])
  }
  function toggle(payload) { Quickshell.execDetached(["/usr/share/omarchy/bin/omarchy-shell", "magicmike.frontrow", "toggle"]) }
}
