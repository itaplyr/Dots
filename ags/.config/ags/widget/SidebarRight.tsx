import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"

export default function SidebarRight() {
  const { RIGHT } = Astal.WindowAnchor

  return (
    <window
      visible={false}
      name="sidebar-right"
      class="SidebarRight"
      exclusivity={Astal.Exclusivity.IGNORE}
      anchor={RIGHT}
      application={app}
      layer={Astal.Layer.OVERLAY}
    >
      <box class="sidebar sidebar-right" orientation={Gtk.Orientation.VERTICAL} width_request={300}>
        <label label="Right Sidebar" class="sidebar-title" />
        <Gtk.Separator />
        <label label="Volume Controls" />
        <Gtk.Separator />
        <label label="Network Info" />
      </box>
    </window>
  )
}
