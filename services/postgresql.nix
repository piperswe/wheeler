{ pkgs, lib, ... }:
{
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = lib.mkOverride 10 ''
      local all all ident map=users
      host all all 127.0.0.1/32 md5
      host all all ::1/128 md5
      host all all 192.168.100.0/24 md5
      host all all 192.168.0.0/24 md5
    '';
    initialScript = pkgs.writeText "postgres-init.sql" ''
      CREATE USER pmc SUPERUSER;
      CREATE DATABASE pmc OWNER pmc;

      CREATE USER vaultwarden;
      CREATE DATABASE vaultwarden OWNER vaultwarden;

      -- Hydra creates its own database

      CREATE USER "matrix-synapse";
      CREATE DATABASE "matrix-synapse" OWNER "matrix-synapse"
        TEMPLATE template0
        LC_COLLATE = "C"
        LC_CTYPE = "C";
    '';
    identMap = ''
      users hydra-queue-runner hydra
      users hydra-www hydra
      users root hydra
      users /^(.*)$ \1
    '';
    settings = {
      max_connections = "100";
      shared_buffers = "1GB";
      effective_cache_size = "3GB";
      maintenance_work_mem = "256MB";
      checkpoint_completion_target = "0.9";
      wal_buffers = "16MB";
      default_statistics_target = "100";
      random_page_cost = "4";
      effective_io_concurrency = "2";
      work_mem = "5242kB";
      min_wal_size = "1GB";
      max_wal_size = "4GB";
      max_worker_processes = "4";
      max_parallel_workers_per_gather = "2";
      max_parallel_workers = "4";
      max_parallel_maintenance_workers = "2";
      shared_preload_libraries = "pg_stat_statements";
      "pg_stat_statements.track" = "all";
      "pg_stat_statements.max" = "10000";
      track_activity_query_size = "2048";
    };
  };
  services.prometheus.exporters.postgres = {
    enable = true;
    runAsLocalSuperUser = true;
  };
  services.pgadmin = {
    enable = true;
    port = 5050;
    initialEmail = "contact@piperswe.me";
    initialPasswordFile = "/etc/pgadmin-initial-password";
  };
  services.nginx.virtualHosts."pgadmin.piperswe.me" = {
    locations."/" = {
      proxyPass = "http://localhost:5050";
      proxyWebsockets = true;
    };
  };
}
