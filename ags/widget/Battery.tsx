// // Import necessary modules from ags
// import Widget from 'resource:///com/github/Aylur/ags/widget.js';
// import { Gtk } from 'gi://Gtk';
// const Battery = await Service.import('battery')
// // Define a function for our Battery widget
// export function BatteryWidget(): JSX.Element {
//     // A container for the battery bar
//     const batteryContainer = Widget.Box({
//         className: 'battery-container',
//         // Set a minimum width for the container if desired
//         css: 'min-width: 120px;',
//     });

//     // The visual battery bar itself
//     const batteryBar = Widget.Box({
//         className: 'battery-bar',
//         // We will dynamically update the style of this box
//     });

//     // Function to determine the color based on battery percentage
//     const getBatteryColor = (percent: number): string => {
//         if (percent > 75) {
//             return '#00FF00'; // Green
//         } else if (percent > 30) {
//             return '#FFFF00'; // Yellow
//         } else {
//             return '#FF0000'; // Red
//         }
//     };

//     // This is the core of the dynamic behavior.
//     // We bind the 'percent' property of the battery service to the 'css' property of our bar.
//     batteryBar.css = Battery.bind('percent').as(p => `
//         background-color: ${getBatteryColor(p)};
//         min-width: ${p}%;
//     `);

//     // A label to display the percentage text
//     const batteryLabel = Widget.Label({
//         className: 'battery-label',
//         // Bind the label to the battery percentage
//         label: Battery.bind('percent').as(p => `${p}%`),
//     });

//     // Assemble the widget
//     batteryContainer.child = Widget.Overlay({
//         child: batteryBar,
//         overlays: [batteryLabel],
//     });

//     return batteryContainer;
// }
// Import necessary modules from ags
