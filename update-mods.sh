#!/usr/bin/bash 

#declare -a slugs=("lithium" "ferrite-core" "phosphor")
readarray -t slugs < mods.txt
echo "${#slugs[@]} mods to fetch from mods.txt"
MCVERSION="1.19.4" 
echo "Minecraft version: $MCVERSION" 
MODLOADER="fabric" 
echo "Modloader: $MODLOADER" 

API="https://api.modrinth.com"

rm mods/*
for slug in "${slugs[@]}"
do 
    SEARCH="$API/v2/search?query=$slug" 
    echo "-> $SEARCH"
    mod=$(curl -s $SEARCH | jq ".hits[] | select(.slug==\"$slug\")") 
    if [ ! "$mod" ] 
    then
        echo "Mod \"$slug\" was not found on modrinth"
    else
        index=$(echo $mod | jq ".versions | index(\"$MCVERSION\")")
        if [ $index == "null" ]
        then 
            echo "Mod \"$slug\" is not available on minecraft version $MCVERSION"
        else 
            DL="$API/v2/project/$slug/version"
            # echo $DL
            INFO=$(curl -s $DL | jq -r "[.[] | select((.game_versions | index(\"$MCVERSION\")) and (.loaders | index (\"$MODLOADER\")))][0]")
            echo $INFO 
            RFILE=$(echo $INFO | jq -r ".files[0] | {url: .url, sha512: .hashes.sha512, fn: .filename}")
            DEPS=$(echo $INFO | jq -r ".dependencies[]")
            FN=$(echo $RFILE | jq -r ".fn")
            DLURL=$(echo $RFILE | jq -r ".url") 
            echo "GET $DLURL" 

            echo "Dependencies: "
            for dep in "${DEPS[@]}"
            do
                echo $dep
            done 
            curl -sL -o "mods/$FN" $DLURL
        fi
fi
done 

ls -la mods 
