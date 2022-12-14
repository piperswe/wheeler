{ ... }:
{
  imports = [
    ./users/pmc.nix
  ];
  users.users.scanner = {
    isNormalUser = true;
    group = "scanner";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTHLN8lKHD1Rj98GNORuv+I9iZWZ4OPHT61Gh8MJAObsAeblx5YVrDWT2Pz4oiHg7d3+SP2zLhzJkL/TGoiG61pM8f3Iyw8tPv5AvBHd8LSYjYX1l9s4dhnKIfLVTNI7VzBRAUvzdsLu6s8pJcknozGXuQ+7CY59FS1zF/jstxcjdwsagcXsPy2skErqPt+eY2rPa337ODegfojda0xwCKZVJtEMw6iN66N6/B7JAMdxH7g8yMNmqudD4TT0uT3AJv1xj3eRM9Gp0IMDMA7hjD0xukj8XzaSI01abbbfzlJGOtJQEn/tYWvGW0zkjZMbSKKjFLQL3yTiAKDRR4U2dD root@BR000EC6EE06FE"
    ];
  };
  users.groups.scanner = {};
}
