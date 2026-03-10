let
  # Replace with your printed age public key (age1...).
  macbook = "age19reff9ln8pmrwus250ry9szkrmtxgge7sqj94ccqpaemq56ncsuqhumepm";

in
{
  "secrets/mbsyncrc.age".publicKeys = [ macbook ];
  "secrets/msmtp-config.age".publicKeys = [ macbook ];
}
