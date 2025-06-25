import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { Variable } from "astal"

const pollTime = 1000
const time = Variable("").poll(pollTime, "date")

export default function Overlay(gdkmonitor: Gdk.Monitor) {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

    return <window
        className="Overlay"
        gdkmonitor={gdkmonitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={TOP | LEFT | RIGHT}
        application={App}>

        // power
        <centerbox>
            <button
                onClicked="echo hello"
                halign={Gtk.Align.CENTER}>
                    Welcome again we are so back!
            </button>
        </centerbox>
    
    </window>
}
