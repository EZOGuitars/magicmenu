import QtQuick
import Quickshell

Item {
  function open(payload) {
    Quickshell.execDetached(["omarchy-shell", "magicmike.frontrow", "open"])
  }
  function close() {
    Quickshell.execDetached(["omarchy-shell", "magicmike.frontrow", "close"])
  }
  function toggle(payload) { Quickshell.execDetached(["omarchy-shell", "magicmike.frontrow", "toggle"]) }
}
