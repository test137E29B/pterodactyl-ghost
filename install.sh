#!/bin/ash

cd /mnt/server

apk --no-cache add curl sudo nodejs npm
apk add --no-cache 'su-exec>=0.2'
npm install ghost-cli@latest -g

cp -r ./temp/caddy /mnt/server/
cp ./temp/start.sh /mnt/server
curl "https://caddyserver.com/api/download?os=linux&arch=amd64&idempotency=33572405766393" -s --output /mnt/server/caddy-server

chmod +x /mnt/server/caddy-server
chmod +x /mnt/server/start.sh

mkdir /mnt/server/.ghost
# route ghost config location to mount
ln -s /mnt/server/.ghost /.ghost
chown -R nobody: /mnt/server/
chmod -R u+w /mnt/server/
# route yarn install location
mkdir -p /.cache/yarn
chown -R nobody: /.cache/yarn/
chmod -R u+w /.cache/yarn/

mkdir -p /home/container
chown -R nobody: /home/container/
chmod -R u+w /home/container/

# Some arguments passed to the install script
# $1 is 

# This is the command that installs ghost headlessly
# https://ghost.org/docs/ghost-cli/#ghost-install - Please refer to this for some info. I'll try to explain the args.
# --no-start prevents ghost from starting automatically after installation
# --no-enable Tells the process manager not to restart Ghost on server reboot
# --no-prompt Install without prompting (disable setup, or pass all required parameters as arguments)

# Here are the ones that I'm adding for production installs
su -s /bin/ash "nobody" -c "ghost install --no-start --no-enable --no-prompt --dir /home/container/ghost --db MySQL --dbhost localhost"
unlink /.ghost



mv /home/container/ghost /mnt/server

# ghostlink=$(readlink /mnt/server/ghost/current)
# if [[ "${ghostlink:0:12}" == "/mnt/server/" ]]; then
#     ln -sfn /home/container/${ghostlink:12} /mnt/server/ghost/current
# fi

# sed 's/\/mnt\/server\//\/home\/container\//g' /mnt/server/ghost/config.development.json > temp.json
# mv temp.json /mnt/server/ghost/config.development.json
