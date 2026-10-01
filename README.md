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

## Captures

Les captures du dossier se trouvent dans `docs/captures/`.
