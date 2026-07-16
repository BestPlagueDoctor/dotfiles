let
  lithium = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDPa5rTUqXG/KyDtwOPgIU//4MF+YxdRXFUoziQ+nY+5";
  magi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8fE/7jy6+Q5CM+6tymMyJjv2QAvLFs30SQ0Cqjdsij";
  navi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzWFxJHJyWrXN7sVCHc7UMaJAFyQ7DH1BUdEVvdT9ot";
  motherbrain = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICgGwnnwmT1NmmFXKVoq1N7Z4fqI6NRAhwNldjDz3wFZ";
  systems = [ lithium magi navi motherbrain ];
in {
  "cloudflare-api-token.age".publicKeys = [ magi ];
  "dufs.age".publicKeys = [ magi ];
  "igor.age".publicKeys = [ magi ];
  "magi-remote-incoming.age".publicKeys = [ magi ];
  "gitlab-runner.age".publicKeys = [ motherbrain ];
}
