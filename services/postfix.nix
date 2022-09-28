{ ... }:
{
  services.postfix = {
    enable = true;
    hostname = "wheeler.piperswe.me";
    extraConfig = ''
      relayhost = [smtp.fastmail.com]:587
      smtp_sasl_auth_enable = yes
      smtp_sasl_password_maps = hash:/var/lib/postfix/relay-credentials
      smtp_sasl_security_options = noanonymous
      smtp_use_tls = yes
      masquerade_domains = piperswe.me
      canonical_maps = regexp:/etc/postfix/canonical
      canonical_classes = envelope_sender,header_sender
    '';
    canonical = ''
      // noreply@piperswe.me
    '';
  };
}
