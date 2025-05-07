{ config, lib, pkgs, ... }:
let
  portssd = "/mnt/portssd";
  public = "${portssd}/public";
in {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];
  system.stateVersion = "24.11"; # Did you read the comment?

  nas.server.enable = true;
}

# 84 watt no changes with no monitor
# 88 watt no changes with monitor but no window manager
# 88 watt SVID communication turned off
# 88 watt INTEL turbo boost turned off
# 88 watt All the voltage options with a "offset mode" i put to "-" (bruh)
# 88  CPU IOA/IOD Voltage Boost set all the way to -150mV (fuck all is happening)
# 88 c-states cpu feature set to ENABLED FROM AUTO
# 88 ??? changed cpu cores to 1 (brother in christ wtf)
# 88 clicking so neither XMP nor OC Geni was highlighted
# 52 watt removed dedicated graphics card, both power and from motherboard
# 51 watt maybe. I went through ALL the bios settings and turned off AUDIO CARD and EPET and some other stuff.
# 47 watt lets  go. Changed "Package C State Limit" from "Auto" to "C7s"
# 49? dropped CPU Base Clock by 1.5 MHz added TLP
# 49.7 dropped vcore to total -50 mV
# 49.3 maybe. Very minor but a little maybe. dropped vcore to total  -150 mV
# 49.2 maybe. honestly impossible to tell. Ring voltage to total -75mV
# same. VCCIN 1.7V
