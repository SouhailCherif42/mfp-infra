#!/bin/bash
# Exécute le playbook Ansible depuis un conteneur (fonctionne sous Linux, macOS et Windows/Git Bash).
# Le socket Docker est monté pour qu'Ansible atteigne les conteneurs DinD via "docker exec".
set -e
cd "$(dirname "$0")"
WORKDIR="$(pwd -W 2>/dev/null || pwd)" # chemin Windows sous Git Bash, chemin POSIX ailleurs
echo "✅ Building Ansible runner image..."
docker build -q -t mfp-ansible ansible >/dev/null
echo "✅ Running Ansible Playbooks..."
MSYS_NO_PATHCONV=1 docker run --rm -e ANSIBLE_FORCE_COLOR=1 \
  -v /var/run/docker.sock:/var/run/docker.sock -v "$WORKDIR":/work \
  mfp-ansible ansible-playbook -i ansible/inventory.ini ansible/init_swarm_cluster.yml "$@"
