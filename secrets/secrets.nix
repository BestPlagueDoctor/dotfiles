let
  ksam1337 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIsDpZpeEoGDKxRpADdy6EPmXlNCGeJkvuQRDYGrBjoJ";
  users = [ ksam1337 ];

  lithium = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ+hx1WnlthPWP9U8auSNMug8wiA+5caKslcioBrAsy8";
  magi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0ausy0kP6cA3ybLXXVXs2QVQIG1wP4LRZINSxPc2sY";
  motherbrain = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICgGwnnwmT1NmmFXKVoq1N7Z4fqI6NRAhwNldjDz3wFZ";
  systems = [ lithium magi motherbrain ];
in {
  "cloudflare-api-token.age".publicKeys = users ++ [ magi ];
  "wg0.age".publicKeys = users ++ [ magi ];
  "gitlab-runner.age".publicKeys = [ motherbrain ];
}
