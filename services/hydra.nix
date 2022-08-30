{ ... }:
let
  narCache = "/var/cache/hydra/nar-cache";
in
{
  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.piperswe.me";
    notificationSender = "hydra@piperswe.me";
    port = 8225;
    extraConfig = ''
      store_uri = s3://nix-cache?secret-key=/var/lib/hydra/queue-runner/keys/nix-cache.piperswe.me/secret&write-nar-listing=1&ls-compression=br&log-compression=br&compression=br&parallel-compression=1&endpoint=https://1c495e64ff5fd527342d7b7bf6731a1f.r2.cloudflarestorage.com
      binary_cache_secret_key_file = /var/lib/hydra/queue-runner/keys/nix-cache.piperswe.me/secret
      server_store_uri = https://nix-cache.piperswe.me?local-nar-cache=${narCache}
      binary_cache_public_uri = https://nix-cache.piperswe.me
      upload_logs_to_binary_cache = true
      max_output_size = 17179869184
      compress_num_threads = 8
    '';
  };

  systemd.tmpfiles.rules =
    [
      "d /var/cache/hydra 0755 hydra hydra -  -"
      "d ${narCache}      0775 hydra hydra 1d -"
    ];

  services.nginx.virtualHosts."hydra.piperswe.me" = {
    locations."/" = {
      extraConfig = ''
        proxy_pass http://localhost:8225;
        proxy_set_header Host              $host;
        proxy_set_header X-Forwarded-Proto "https";
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
      '';
    };
  };
}
