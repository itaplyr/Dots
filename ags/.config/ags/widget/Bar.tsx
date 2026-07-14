import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { createPoll } from "ags/time"
import Hyprland from "gi://AstalHyprland"
import { createState } from "ags"

const hypr = Hyprland.get_default()

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const time = createPoll("", 1000, "date '+%H:%M'")
  const date = createPoll("", 1000, "date '+%a %-d'")
  const year = createPoll("", 1000, "date '+%Y'")

  const [activeWs, setActiveWs] = createState(
    hypr.get_focused_workspace()?.id ?? 1
  )

  hypr.connect("notify::focused-workspace", () => {
    setActiveWs(hypr.get_focused_workspace()?.id ?? 1)
  })

  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

  const workspaces = (
    <box
      class="workspaces"
      valign={Gtk.Align.CENTER}
      vexpand={false}
      spacing={8}
    >
      {Array.from({ length: 10 }, (_, i) => (
        <button
          class={activeWs.as(ws =>
            `workspace${ws === i + 1 ? " active" : ""}`
          )}
          width-request={4}
          height-request={4}
          hexpand={false}
          vexpand={false}
          valign={Gtk.Align.CENTER}
        />
      ))}
    </box>
  )

  return (
    <window
      visible
      name="bar"
      class="Bar"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={app}
    >
      <centerbox cssName="centerbox">
        <box $type="start">{workspaces}</box>
        <box $type="center" class="clock-container">
          <label class="clock" label={time} />
          <label class="clock-separator" label={' | '} />
          <label class="clock-date" label={date}></label>
        </box>
      </centerbox>
    </window>
  )
}