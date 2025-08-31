# Is the routing table gotten by `ip route` trustworthy?
"for any given network namespace, the kernel's routing table is the absolute and authoritative rulebook for deciding where to send an IP packet"

# Where is it stored on disk?
"the routing table is not stored in a regular configuration file on your disk. It's a dynamic data structure held directly within the Linux kernel's memory."
And it is viewed with ip route.

# Given the earlier mention of a namespace, how does linux know which namespace i am in when i write `ip route`
"Every process on Linux, including your shell, lives within a namespace. The system "automatically" knows which one you're in because your shell is a process just like any other."

# How can you view other namespaces?
"Since your NixOS container is managed by systemd-nspawn, the easiest and recommended tool to use is machinectl"
"machinectl - Control the systemd machine manager", man page
`sudo machinectl shell qbittorrent`
`ip route`

"nsenter lets you run a single command within another process's namespace without starting a full shell"
find pid of a process in the container. we do this by looking for LEADER in the output of `machinectl status qbittorrent`
`sudo nsenter -t LEADER -n ip route`

"Both machinectl and nsenter work by using a special Linux kernel function called the setns() system call. It's a fundamental feature of namespaces that allows one process to tell the kernel, "Hey, please move me into the same set of namespaces that this other process is in."

# Are namespaces just an id with the property that process can only be in one, and generally the ecosystem, in order to support containers and such, make sure that programs work whitin just one such id, thereby effectivly making it easy for linux to create the concept of containers?
"Namespaces are less like a single ID and more like a collection of different "views" of the system that provide isolation. A process has one view for networking, another for the process list, another for the filesystem, and so on."
The different namespace types are explained here: https://man7.org/linux/man-pages/man7/namespaces.7.html

# Earlier when talking about the output of ip route, i was told that the output means that for any given ip and corresponding networking interface listed, it means that for all the process in the same networking namespace if they try to communicate with that ip, it will be handled by corresponding networking interface. Is this correct?
"Yes. The routing table is a set of rules the kernel follows. For any process in a given network namespace, when it tries to send a packet, the kernel looks at the destination IP address and compares it against its routing table to find the best matching rule. That rule then dictates which network interface is used."

# Then what exactly does the networking interface do if its already established where this networking packet is supposed to be sent?
"The routing table makes the high-level, logical decision. The network interface is the specialist that handles the low-level, physical (or virtual) reality of actually sending the data. The routing decision tells the kernel which door to use (eth0, wg0, etc.). The network interface is the machinery of the door itself, responsible for packaging the packet correctly for the world on the other side."


Oh so The IP can be something other than be in the routing table, in which case it gets sent to the default gateway. And when it gets to the router, it has a routing table itself which has a default. So in that case when you say that NAT makes the computer act like a router, that is simply because we have added a new entry to the routing table, the same way a router would.