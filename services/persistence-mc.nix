{ pkgs, ... }:
let
  stopScript = pkgs.writeShellScript "persistence-mc-stop" ''
    echo stop > /run/persistence-mc.stdin

    # Wait for the PID of the minecraft server to disappear before
    # returning, so systemd doesn't attempt to SIGKILL it.
    while kill -0 "$1" 2> /dev/null; do
      sleep 1s
    done
  '';
in
{
  users.groups.persistence-mc = {
    members = [ "pmc" ];
  };
  users.users.persistence-mc = {
    isSystemUser = true;
    home = "/var/lib/persistence-mc/home";
    group = "persistence-mc";
  };
  systemd.sockets.persistence-mc = {
    bindsTo = [ "persistence-mc.service" ];
    socketConfig = {
      ListenFIFO = "/run/persistence-mc.stdin";
      SocketMode = "0660";
      SocketUser = "persistence-mc";
      SocketGroup = "persistence-mc";
      RemoveOnStop = true;
      FlushPending = true;
    };
  };
  systemd.services.persistence-mc = {
    description = "Persistence Minecraft Server";
    wantedBy = [ "multi-user.target" ];
    requires = [ "persistence-mc.socket" ];
    after = [ "network.target" "persistence-mc.socket" ];
    serviceConfig = {
      ExecStart = "${pkgs.jdk17_headless}/bin/java -Xmx10G -Xms10G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -Dpaper.log-level=FINE -jar minecraft.jar --nogui";
      ExecStop = "${stopScript} $MAINPID";
      Restart = "always";
      User = "persistence-mc";
      WorkingDirectory = "/var/lib/persistence-mc";
      StandardInput = "socket";
      StandardOutput = "journal";
      StandardError = "journal";
      # Hardening
      CapabilityBoundingSet = [ "" ];
      DeviceAllow = [ "" ];
      LockPersonality = true;
      PrivateDevices = true;
      PrivateTmp = true;
      PrivateUsers = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      UMask = "0007";
    };
  };
  networking.firewall = {
    allowedTCPPorts = [ 25565 ];
    allowedUDPPorts = [ 25565 ];
  };
}
