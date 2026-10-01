# Ansible n'est pas supporté nativement sous Windows : on l'exécute dans un conteneur.
# Le socket Docker de l'hôte est monté (DooD) pour piloter les conteneurs DinD du cluster
# via la connexion community.docker.docker (équivalent d'un "docker exec").
FROM python:3.12-alpine
RUN apk add --no-cache docker-cli \
 && pip install --no-cache-dir ansible-core \
 && ansible-galaxy collection install community.docker
WORKDIR /work
