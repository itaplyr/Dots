import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { execAsync } from "ags/process"

export default function SidebarLeft() {
  const { LEFT } = Astal.WindowAnchor

  return (
    <window
      visible={false}
      name="sidebar-left"
      class="SidebarLeft"
      exclusivity={Astal.Exclusivity.IGNORE}
      anchor={LEFT}
      application={app}
      layer={Astal.Layer.OVERLAY}
    >
      <box class="sidebar sidebar-left" orientation={Gtk.Orientation.VERTICAL} width_request={300}>
        <label label="Left Sidebar" class="sidebar-title" />
        <Gtk.Separator />
        <button onClicked={() => execAsync("kitty")}>
          <label label="Terminal" />
        </button>
        <button onClicked={() => execAsync("thunar")}>
          <label label="Files" />
        </button>
      </box>
    </window>
  )
}
