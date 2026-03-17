let
  # Replace with your printed age public key (age1...).
  macbook = "age19reff9ln8pmrwus250ry9szkrmtxgge7sqj94ccqpaemq56ncsuqhumepm";
  server = "age17jkrfgtt682dhdd9wudv30cc4qp00lq0v3wg94va86tpgp5m0prs00yf2m";

in
{
  "secrets/mbsyncrc.age".publicKeys = [ macbook ];
  "secrets/msmtp-config.age".publicKeys = [ macbook ];
  "secrets/frigate-reolink-env.age".publicKeys = [ macbook server ];
}
