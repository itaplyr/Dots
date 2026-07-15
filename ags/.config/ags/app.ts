import app from "ags/gtk4/app"
import style from "./style.css"
import Bar from "./widget/Bar"
import SidebarLeft from "./widget/SidebarLeft"
import SidebarRight from "./widget/SidebarRight"

app.start({
  css: style,
  instanceName: "ags",
  main() {
    app.get_monitors().map(Bar)
    SidebarLeft()
    SidebarRight()
  },
})
