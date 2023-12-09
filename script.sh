#!/bin/ash
# shellcheck shell=dash

VER_EXISTS=$(curl -s https://api.purpurmc.org/v2/purpur | jq -r --arg VERSION "$MINECRAFT_VERSION" '.versions[] | contains($VERSION)' | grep true)
LATEST_VERSION=$(curl -s https://api.purpurmc.org/v2/purpur | jq -r '.versions' | jq -r '.[-1]')

if [ "${VER_EXISTS}" = "true" ]; then
    printf "Version is valid. Using version %s\n" "${MINECRAFT_VERSION}"
else
    printf "Using the latest purpur version\n"
    MINECRAFT_VERSION=${LATEST_VERSION}
fi

BUILD_EXISTS=$(curl -s https://api.purpurmc.org/v2/purpur/"${MINECRAFT_VERSION}" | jq -r --arg BUILD "${BUILD_NUMBER}" '.builds.all | tostring | contains($BUILD)' | grep true)
LATEST_BUILD=$(curl -s https://api.purpurmc.org/v2/purpur/"${MINECRAFT_VERSION}" | jq -r '.builds.latest')

if [ "${BUILD_EXISTS}" = "true" ]; then
    printf "Build is valid for version %s. Using build %s\n" "${MINECRAFT_VERSION}" "${BUILD_NUMBER}"
else
    printf "Using the latest purpur build for version %s\n" "${MINECRAFT_VERSION}"
    BUILD_NUMBER=${LATEST_BUILD}
fi

DOWNLOAD_URL=https://api.purpurmc.org/v2/purpur/${MINECRAFT_VERSION}/${BUILD_NUMBER}/download

cd /mnt/server || exit
printf "Downloading Purpur version %s build %s\n" "${MINECRAFT_VERSION}" "${BUILD_NUMBER}"

if [ -f "server.jar" ]; then
    mv server.jar server.jar.old
fi

curl -o server.jar "${DOWNLOAD_URL}"

printf "Downloading optimized configuration files\n"

if [ ! -d "config" ]; then
    mkdir config
fi

if [ ! -f "server.properties" ]; then
    curl -o server.properties https://raw.githubusercontent.com/pyrohost/optimized-minecraft-egg/main/configs/server.properties
fi

if [ ! -f "bukkit.yml" ]; then
    curl -o bukkit.yml https://raw.githubusercontent.com/pyrohost/optimized-minecraft-egg/main/configs/bukkit.yml
fi

if [ ! -f "spigot.yml" ]; then
    curl -o spigot.yml https://raw.githubusercontent.com/pyrohost/optimized-minecraft-egg/main/configs/spigot.yml
fi

if [ ! -f "config/paper-global.yml" ]; then
    curl -o paper-global.yml https://raw.githubusercontent.com/pyrohost/optimized-minecraft-egg/main/configs/paper-global.yml
fi

if [ ! -f "config/paper-world-defaults.yml" ]; then
    curl -o paper-world-defaults.yml https://raw.githubusercontent.com/pyrohost/optimized-minecraft-egg/main/configs/paper-world-defaults.yml
fi

if [ ! -f "pufferfish.yml" ]; then
    curl -o pufferfish.yml https://raw.githubusercontent.com/pyrohost/optimized-minecraft-egg/main/configs/pufferfish.yml
fi

if [ ! -f "config/purpur.yml" ]; then
    curl -o purpur.yml https://raw.githubusercontent.com/pyrohost/optimized-minecraft-egg/main/configs/purpur.yml
fi
