import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { exec } from "ags/process"
import { createPoll } from "ags/time"
import { createState } from "ags"
import Hyprland from "gi://AstalHyprland"
import Network from "gi://AstalNetwork"
import Bluetooth from "gi://AstalBluetooth"
import Wp from "gi://AstalWp"
import Tray from "gi://AstalTray"

const hypr = Hyprland.get_default()
const network = Network.get_default()
const bluetooth = Bluetooth.get_default()
const wp = Wp.get_default()
const tray = Tray.get_default()
const nproc = parseInt(exec("nproc").trim())

const UsageCircle = ({ value, size = 15 }: { value: Binding<number>, size?: number }) => (
  <box
    width-request={size}
    height-request={size}
    hexpand={false}
    vexpand={false}
    css={value.as(v => `
      min-width: ${size}px;
      min-height: ${size}px;
      border-radius: 50%;
      background: conic-gradient(
        rgba(255, 255, 255, 0.85) ${v}%,
        rgba(255, 255, 255, 0.15) ${v}%
      );
    `)}
  />
)

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const time = createPoll("", 1000, "date '+%H:%M'")
  const date = createPoll("", 1000, "date '+%a %-d'")

  const cpuUsage = createPoll(0, 2000, () => {
    try {
      const loadavg = exec("cat /proc/loadavg")
      const load = parseFloat(loadavg.split(/\s+/)[0])
      return Math.min(100, Math.round(load / nproc * 100))
    } catch { return 0 }
  })

  const ramUsage = createPoll(0, 2000, () => {
    try {
      const meminfo = exec("cat /proc/meminfo")
      const lines = meminfo.split("\n")
      const totalLine = lines.find(l => l.startsWith("MemTotal"))
      const availLine = lines.find(l => l.startsWith("MemAvailable"))
      if (!totalLine || !availLine) return 0
      const total = parseInt(totalLine.split(/\s+/)[1])
      const avail = parseInt(availLine.split(/\s+/)[1])
      return Math.round((1 - avail / total) * 100)
    } catch { return 0 }
  })

  const swapUsage = createPoll(0, 2000, () => {
    try {
      const meminfo = exec("cat /proc/meminfo")
      const lines = meminfo.split("\n")
      const totalLine = lines.find(l => l.startsWith("SwapTotal"))
      const freeLine = lines.find(l => l.startsWith("SwapFree"))
      if (!totalLine || !freeLine) return 0
      const total = parseInt(totalLine.split(/\s+/)[1])
      const free = parseInt(freeLine.split(/\s+/)[1])
      if (total === 0) return 0
      return Math.round((1 - free / total) * 100)
    } catch { return 0 }
  })

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

  const networkIcon = createPoll("󰈀", 3000, () => {
    try {
        const strength = parseInt(exec("nmcli -t -f IN-USE,SIGNAL dev wifi | grep '^*' | cut -d: -f2"))

        if (strength >= 75) return "󰤨"
        if (strength >= 50) return "󰤥"
        if (strength >= 25) return "󰤢"
        return "󰤟"
    } catch {
        return "󰈀"
    }
  })
  const bluetoothIcon = createPoll("󰂲", 3000, () => {
    try {
        const powered = exec("bluetoothctl show | grep 'Powered:' | awk '{print $2}'").trim()
        return powered === "yes" ? "󰂯" : "󰂲"
    } catch {
        return "󰂲"
    }
  })

  const volumeIcon = createPoll("󰕾", 1000, () => {
    try {
        const out = exec("wpctl get-volume @DEFAULT_AUDIO_SINK@")

        if (out.includes("MUTED"))
            return "󰝟"

        return "󰕾"
    } catch {
        return "󰕾"
    }
  })

  /* const systemTray = tray.bind("items").as(items =>
    items.map((item: any) => (
      <image
        icon_name={item.icon_name}
        pixel_size={14}
        tooltip_text={item.title}
      />
    ))
  ) */

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
        <box $type="start" spacing={12} valign={Gtk.Align.CENTER}>
          {workspaces}
          <box class="usages" spacing={12} valign={Gtk.Align.CENTER}>
            <UsageCircle value={cpuUsage} size={12.5} />
            <UsageCircle value={ramUsage} size={12.5} />
            <UsageCircle value={swapUsage} size={12.5} />
          </box>
        </box>
        <box $type="center" class="clock-container">
          <label class="clock" label={time} />
          <label class="clock-separator" label={' | '} />
          <label class="clock-date" label={date} />
        </box>
        <box $type="end" spacing={8} valign={Gtk.Align.CENTER}>
          <box class="system-tray" spacing={4} valign={Gtk.Align.CENTER}>
            {/* {systemTray} */}
          </box>
          <label class="section-separator" label="│" />
          <box class="status-icons" spacing={15} valign={Gtk.Align.CENTER}>
            <label class="tray-icon" label={networkIcon} />
            <label class="tray-icon" label={bluetoothIcon} />
            <label class="tray-icon" label={volumeIcon} />
          </box>
        </box>
      </centerbox>
    </window>
  )
}
