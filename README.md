# My Favorite Places — Infrastructure & DevOps

Projet support du module Infrastructure & DevOps (ESGI Lyon, 5ESGI ALT).
Application : API Node.js/TypeScript (Express + TypeORM), front React (Vite), base PostgreSQL.

## Lancer le projet en local

### Avec Docker Compose (recommandé)

```bash
docker compose up -d --build
```

| Service | URL |
|---------|-----|
| Front (Nginx) | http://localhost:8080 |
| API | http://localhost:3000/api |
| PostgreSQL | localhost:5432 (postgres / supersecret) |

Nginx sert le front et relaie `/api` vers le service `server` : le navigateur ne parle qu'à une seule origine.

### En mode développement

```bash
docker compose up -d db      # uniquement la base
cd server && yarn install && yarn dev
cd client && yarn install && yarn dev
```

Variables d'environnement du serveur : `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`,
`DB_LOGGING` (`true` pour afficher les requêtes SQL), `SESSION_SECRET`, `PORT`.

## Tests d'API (Bruno)

La collection se trouve dans `bruno/` :

```bash
npm i -g @usebruno/cli
cd bruno
bru run --env local     # API sur :3000
bru run --env compose   # via Nginx sur :8080
```

## Cluster Docker Swarm local (DinD + Ansible)

Chaque conteneur Docker-in-Docker de `swarm/compose.yml` simule une machine du cluster.

```bash
cd swarm
docker compose up -d --build --scale node=3 --wait   # 1 manager + 3 noeuds
cd ..
./ansible.sh                                          # init du Swarm + jonction des workers
docker exec swarm-manager-1 docker node ls
```

- `ansible.sh` lance Ansible **dans un conteneur** (Ansible n'existe pas nativement sous Windows) ;
  le socket Docker est monté et la connexion `community.docker.docker` remplace SSH par `docker exec`.
- Le playbook `ansible/init_swarm_cluster.yml` est idempotent : il lit l'état Swarm de chaque noeud
  et n'exécute `swarm init` / `swarm join` que si nécessaire (relance = `changed=0`).
- Ajouter un noeud : `docker compose up -d --scale node=4`, ajouter `swarm-node-4` dans
  `ansible/inventory.ini`, relancer `./ansible.sh`.

### Utiliser le playbook sur de vraies VMs / VPS

Seul l'inventaire change : `ansible_connection=ssh`, `ansible_host=<IP>`, `ansible_user=<user>`,
`ansible_become=true`, une clé SSH autorisée sur les machines, et `swarm_manager_addr=<IP privée du manager>`.
Il faut aussi installer Docker sur les machines (tâche supplémentaire, ex. rôle `geerlingguy.docker`)
et ouvrir les ports Swarm (2377/tcp, 7946/tcp+udp, 4789/udp).

## Stacks déployées sur le cluster (`stacks/`)

| Stack | Fichier | URL |
|-------|---------|-----|
| Traefik (reverse proxy) + whoami | `traefik.yml` | http://traefik.swarm.localhost, http://whoami.swarm.localhost |
| App de vote (dockersamples) | `voting.yml` | http://vote.swarm.localhost, http://result.swarm.localhost |
| Portainer (agent + serveur) | `portainer.yml` | http://portainer.swarm.localhost |

Les sous-domaines `*.localhost` sont résolus vers `127.0.0.1` par les navigateurs et curl ;
sinon, ajouter dans le fichier `hosts` : `127.0.0.1 traefik.swarm.localhost whoami.swarm.localhost ...`.

```bash
# réseau overlay partagé entre Traefik et les services publiés
docker exec swarm-manager-1 docker network create --driver overlay --attachable web
# déploiement d'une stack depuis le manager
docker cp stacks/traefik.yml swarm-manager-1:/home/manager/
docker exec -w /home/manager swarm-manager-1 docker stack deploy -c traefik.yml traefik
```

Un service est publié par Traefik dès qu'il est sur le réseau `web` et porte les labels
`traefik.enable=true`, `traefik.http.routers.<nom>.rule=Host(...)` et
`traefik.http.services.<nom>.loadbalancer.server.port=<port interne>` (dans `deploy.labels`).

Au premier lancement de Portainer, créer le compte admin (le *setup token* est dans
`docker service logs portainer_portainer`). Les stacks créées depuis Portainer sont en contrôle
« Total » (modifiables dans l'interface), celles créées en CLI en contrôle « Limited ».

## Captures

Les captures du dossier se trouvent dans `docs/captures/`.
