let
  # Replace with your printed age public key (age1...).
  horus = "age12ckqq0tfe9t4afz6t6lf4ua9a64l73e97glhssrknxznc47sw5qsh32x2u";
  eisenstein = "age17jkrfgtt682dhdd9wudv30cc4qp00lq0v3wg94va86tpgp5m0prs00yf2m";

in
{
  "secrets/mbsyncrc.age".publicKeys = [ horus ];
  "secrets/msmtp-config.age".publicKeys = [ horus ];
  "secrets/frigate-reolink-env.age".publicKeys = [ eisenstein ];
}
