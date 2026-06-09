{ lib, primaryUser, linuxHome, ... }:
let
  ageKeyPath = "${linuxHome}/.config/age/keys.txt";
  hasAgeKey = builtins.pathExists ageKeyPath;
in
{
  # Bootstrap cleanly without secrets; once the age key exists, a rebuild
  # enables the encrypted mail config automatically.
  age.identityPaths = lib.mkIf hasAgeKey [ ageKeyPath ];
  age.secrets = lib.mkIf hasAgeKey {
    mbsyncrc = {
      file = ../../secrets/mbsyncrc.age;
      path = "${linuxHome}/.config/isync/mbsyncrc";
      owner = primaryUser;
      group = "users";
      mode = "0400";
    };
    msmtp-config = {
      file = ../../secrets/msmtp-config.age;
      path = "${linuxHome}/.config/msmtp/config";
      owner = primaryUser;
      group = "users";
      mode = "0400";
    };
  };
}
