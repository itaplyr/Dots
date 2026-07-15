import app from "ags/gtk4/app"
import { Astal, Gtk } from "ags/gtk4"
import WebKit from "gi://WebKit"

export default function SidebarLeft() {
  const { TOP, LEFT, BOTTOM } = Astal.WindowAnchor

  const context = WebKit.WebContext.get_default()

  const settings = new WebKit.Settings({
    enable_javascript: true,
    enable_developer_extras: true,
    enable_media: true,
    enable_webaudio: true,
    user_agent:
      "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/120 Safari/537.36",
  })

  const webview = new WebKit.WebView({
    web_context: context,
    settings,
  })

  webview.set_hexpand(true)
  webview.set_vexpand(true)
  webview.set_can_focus(true)

  webview.connect("load-changed", (_, event) => {
    console.log("Load event:", event)
  })

  webview.connect("load-failed", (_, event, uri, error) => {
    console.error("Load failed:", uri, error.message)
    return false
  })

  webview.load_uri("https://music.youtube.com")

  return (
    <window
      visible={false}
      name="sidebar-left"
      class="SidebarLeft"
      exclusivity={Astal.Exclusivity.NORMAL}
      anchor={TOP | LEFT | BOTTOM}
      application={app}
      layer={Astal.Layer.TOP}
    >
      <box
        class="sidebar sidebar-left"
        orientation={Gtk.Orientation.VERTICAL}
        width_request={400}
        hexpand
        vexpand
      >
        {webview}
      </box>
    </window>
  )
}