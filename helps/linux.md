# Helps Linux

## Print permissions in octal

```sh
stat -c '%A %a %n' .ssh/id_ecdsa
```

## Generate ssh key pair

```sh
ssh-keygen -q -t ecdsa -b 521 -N '' -f ~/.ssh/rancher-key-ecdsa <<<y >/dev/null 2>&1
```

## Copy public key for remote server

```sh
sshpass -p 'vagrant' ssh-copy-id -o StrictHostKeyChecking=no -i ~/.ssh/rancher-key-ecdsa root@debian-server02
```

## Connect in remote

```sh
ssh -o StrictHostKeyChecking=no -i ~/.ssh/rancher-key-ecdsa  root@control-plane02
```

## Codify and Decode string for base64

```sh
# codify string
echo -n "foobarbeercool" | base64

# decode string
echo -n 'Z2lyb3BvcHM=' | base64 -d
```

## TMUX

https://tmuxcheatsheet.com/