import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { execAsync } from "ags/process"
import { createPoll } from "ags/time"

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const time = createPoll("", 1000, "date")
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

  const workspaces = (
    <box class="workspaces">
      {Array.from({ length: 10 }, (_, i) => (
        <button
          class="workspace"
          onClicked={() => execAsync(`hyprctl dispatch workspace ${i + 1}`)}
        >
          <label label={`${i + 1}`} />
        </button>
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
        <box $type="center">
          <label class="clock" label={time} />
        </box>
        <box $type="end">
          <label label="dots" />
        </box>
      </centerbox>
    </window>
  )
}
