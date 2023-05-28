#!/usr/bin/bash
#
fn="fabric-server.jar"
curl -J https://meta.fabricmc.net/v2/versions/loader/1.19.4/0.14.21/0.11.2/server/jar -o $fn 

echo -e "#!/usr/bin/bash \njava -Xmx2G -jar $fn nogui" > start.sh
chmod +x start.sh

echo "eula=true" > eula.txt
