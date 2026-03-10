# n8n + Qdrant Docker Stack

A self-hosted AI workflow automation stack combining **n8n**, **Qdrant**, **PostgreSQL**, and **Traefik**. It comes pre-configured with a Qdrant credential in n8n, making it ready for RAG (Retrieval-Augmented Generation) and LangChain-based workflows out of the box.

## Services

| Service | Image | Description | Port |
|---|---|---|---|
| **n8n** | `docker.n8n.io/n8nio/n8n:latest` | Workflow automation platform | `5678` (internal) |
| **Qdrant** | `qdrant/qdrant` | Vector database for AI/embeddings | `6333` |
| **PostgreSQL** | `postgres:latest` | Relational database (n8n backend) | `5432` |
| **Traefik** | `traefik` | Reverse proxy with automatic HTTPS | `80`, `443` |

n8n is exposed publicly via Traefik at `https://<SUBDOMAIN>.<DOMAIN_NAME>` with a Let's Encrypt TLS certificate. Qdrant and PostgreSQL are available on their standard ports for local/internal use.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/)
- A domain name with a DNS A record pointing to your server's IP address
- Ports `80` and `443` open on your server's firewall

## Setup

### 1. Clone the repository

```bash
git clone <your-repo-url>
cd "n8n with qdrant"
```

### 2. Configure environment variables

Create a `.env` file in the project root with the following variables:

```env
# Domain
DOMAIN_NAME=example.com
SUBDOMAIN=n8n

# SSL
SSL_EMAIL=you@example.com

# PostgreSQL
POSTGRES_USER=n8n
POSTGRES_PASSWORD=changeme
POSTGRES_DB=n8n

# Timezone (e.g. America/New_York, Europe/London, Asia/Bangkok)
GENERIC_TIMEZONE=UTC
```

> **Security note:** Never commit your `.env` file to version control. Add it to `.gitignore`.

### 3. Start the stack

```bash
docker compose up -d
```

### 4. Access n8n

Once running, open your browser and navigate to:

```
https://<SUBDOMAIN>.<DOMAIN_NAME>
```

On first launch, n8n will prompt you to create an admin account.

## Pre-loaded Credentials

On startup, the custom entrypoint (`docker-entrypoint.sh`) automatically imports any credential files found in the `nodes-info/` directory into n8n.

This stack ships with a pre-configured **Qdrant API** credential (`Local QdrantApi database`) that points to the local Qdrant container. It is wired up for use with n8n's LangChain Qdrant Vector Store node (`@n8n/n8n-nodes-langchain.vectorStoreQdrant`), so you can build AI/RAG workflows immediately without manual credential setup.

## Project Structure

```
.
├── docker-compose.yml        # Service definitions
├── docker-entrypoint.sh      # n8n startup script (auto-imports credentials)
├── nodes-info/               # Credential JSON files auto-imported into n8n
│   └── sFfERYppMeBnFNeA.json # Pre-configured local Qdrant credential
├── local-files/              # Files accessible inside n8n at /files (create if needed)
└── .env                      # Environment variables (not committed)
```

## Stopping the Stack

```bash
docker compose down
```

To also remove all persistent volumes (this will erase all n8n workflows, Qdrant data, and the database):

```bash
docker compose down -v
```

## Persistent Volumes

| Volume | Contents |
|---|---|
| `n8n_data` | n8n workflows, credentials, and settings |
| `qdrant_storage` | Qdrant vector collections |
| `postgres_storage` | PostgreSQL database files |
| `traefik_data` | Let's Encrypt certificates |

## Troubleshooting

**Traefik certificate not issuing**
- Ensure your DNS A record is correctly pointing to your server and has propagated.
- Verify ports 80 and 443 are open and not used by another process.
- Check Traefik logs: `docker logs traefik`

**n8n not starting**
- Check that all required environment variables are set in `.env`.
- View n8n logs: `docker logs n8n`

**Credential import failures**
- The entrypoint prints a warning if import fails but still starts n8n. Check `docker logs n8n` for details.
- Ensure JSON files in `nodes-info/` are valid n8n credential exports.
