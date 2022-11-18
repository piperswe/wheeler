{ ... }:
{
  services.netatalk = {
    enable = true;

    settings = {
      "PiperTimeMachine" = {
        "time machine" = "yes";
        path = "/var/lib/time-machine/pmc";
        "valid users" = "pmc";
      };
    };
  };
}
