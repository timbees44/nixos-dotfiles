let
  # Replace with your printed age public key (age1...).
  fulgrim = "age19reff9ln8pmrwus250ry9szkrmtxgge7sqj94ccqpaemq56ncsuqhumepm";
  horus = "age12ckqq0tfe9t4afz6t6lf4ua9a64l73e97glhssrknxznc47sw5qsh32x2u";
  eisenstein = "age17jkrfgtt682dhdd9wudv30cc4qp00lq0v3wg94va86tpgp5m0prs00yf2m";

in
{
  "secrets/mbsyncrc.age".publicKeys = [ fulgrim horus ];
  "secrets/msmtp-config.age".publicKeys = [ fulgrim horus ];
  "secrets/frigate-reolink-env.age".publicKeys = [ fulgrim eisenstein ];
}
