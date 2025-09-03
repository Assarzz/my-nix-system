# What is sytemd?
systemd is an init system and system manager for Linux. Its main job is to be the very first process that starts after the kernel (it runs as Process ID 1) and to then manage all other services and processes on your system.

# You mentioned that it is the first process. Does that mean that every other process on the system can be said belong to a service or other unit? 

Cgroups explained: systemd doesn't just start services; it meticulously tracks every process it spawns using a kernel feature called control groups (cgroups). When systemd starts a service, it creates a unique cgroup for it. Any process created by that service (and any process those children create) remains inside that same cgroup.

This is how systemctl stop my-app.service is so effective. Instead of just sending a signal to the main process and hoping it cleans up its children, systemd simply terminates every process inside the service's cgroup, ensuring nothing is left behind.


.scope mentioned: While .service units are the most common, systemd uses a broader categorization to manage all processes, including those that aren't long-running daemons. The main types of units that contain processes are: .scope: A unit for processes that are started externally, not by systemd itself. The most important example is a user login session. When you log in (either via a graphical desktop or SSH), the systemd-logind service creates a scope unit for your entire session. Every application you launch, from your terminal to your web browser, lives inside this scope. This allows systemd to manage user sessions as a whole.
init.scope

view the cgroup with `systemd-cgls`. To me it looks like this is what `systemctl status` uses.

# How to see cgroup of a process?
The cgroup of a process can be seen by `cat /proc/<pid>/cgroup`. its a path so it can effectively be seen by looking at the output of `systemctl status`

# You mentioned that .scope are process that are started externally. How exactly would that work. Assuming we start of by starting all the services all those resulting processes are under corresponding .service's cgroup. But what about any other process you say are external. what system is responsible for starting them, and if that system was a .service shouldn't the process also have the cgroup of that .service?
The new process does initially inherit the cgroup of its parent service. The magic is that it is then immediately and deliberately moved into a new, specially created .scope cgroup. This isn't a default kernel behavior; it's an explicit action orchestrated by the systemd ecosystem to properly manage the lifecycle of user sessions.

# Alright. now lets talk about the services that seem to come directly from systemd itself. like networkd, resolved and journald. How are they any special from other services?
...systemd-networkd (The Network Manager) 🔌: This daemon manages network devices. Its special status allows it to work very closely with other systemd components. For example, when networkd brings a network interface up and it becomes fully configured, it can directly signal systemd (PID 1) that the network-online.target is now reached, allowing all other services that depend on the network to start. This integration provides a more reliable and declarative way of handling network state...

# You mentioned the network-online.target. What are these targets. When looking at the ouput of `systemctl status` i see the systemd-networkd-wait-online.service. are they related?
A .target unit in systemd is a synchronization point in the boot process. It doesn't do anything by itself; instead, it groups other units (.service, .target, etc.) together. Think of a target as a milestone or a goal.

When systemd starts a target, it's really starting all the services that are WantedBy= that target. When all the required services for a target have successfully started, the target is considered "active" or "reached."

A service that needs a configured network will specify two things in its unit file:
[Unit]
Description=My Application
Wants=network-online.target
After=network-online.target

This tells systemd: "Don't even try to start me until the network-online.target milestone has been successfully reached."

So, how does systemd know when the network is truly online? It doesn't, by itself. It needs a service to tell it. This is the job of systemd-networkd-wait-online.service. This service is enabled by default when you use systemd-networkd. It does one simple thing: it starts and then waits. It blocks itself from finishing until the main systemd-networkd daemon reports that all the network interfaces it's configured to manage have reached a fully "configured" state.

# When running `systemctl` I see rows of units each with the columns UNIT, LOAD, ACTIVE, SUB, JOB, DESCRIPTION. Explain these. what are these columns called? Are there more?
`systemctl` = `systemctl list-units`
LOAD: This shows whether systemd successfully parsed the unit's configuration file from disk.
    loaded: The file was read and understood without errors.
    not-found: systemd couldn't find a unit file with that name.
    bad-setting: The file was found, but it contains syntax errors.
    masked: The unit file is linked to /dev/null, making it impossible to start.

ACTIVE: This is a high-level summary of whether the unit is currently active. The meaning depends on the unit type.
    active: The unit is running successfully. For a service, this means its main process is active.
    inactive: The unit is not running.
    failed: The unit tried to start but failed for some reason (e.g., the main process crashed or an error occurred).
    activating: The unit is in the process of starting up.

SUB: Short for "substate," this column provides more detailed, low-level information about the ACTIVE state.
    running: For a service, this means the main process is up and running.
    exited: The service's main process has finished and exited successfully. This is normal for one-shot tasks.
    dead: The service is not running.
    mounted: For a .mount unit, the filesystem is mounted.
    waiting: The service is waiting for an event to occur (e.g., a .socket unit waiting for a connection).

JOB: This column is usually empty. It only shows a value if there is a pending job for the unit in systemd's job queue (e.g., start, stop, restart). Once the job is complete, this column will be blank again.