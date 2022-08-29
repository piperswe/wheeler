{ ... }:
{
  services.rsyslogd = {
    enable = true;
    extraConfig = ''
      *.* action(type="omfwd" target="192.168.0.144" port="514" protocol="udp" action.resumeRetryCount="100" queue.type="linkedList" queue.size="10000")
    '';
  };
}
