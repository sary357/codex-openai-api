# codex-openai-api

This repository documents how to route Codex model traffic through a LiteLLM proxy backed by OpenAI API credentials. It contains two main configuration areas:

- `litellm_settings/`: Docker Compose, LiteLLM proxy configuration, Prometheus metrics configuration, and deployment helper scripts.
- `codex_settings/`: the Codex `config.toml` settings needed to point Codex at the LiteLLM-compatible OpenAI endpoint.

## Repository Structure

```text
.
├── LICENSE
├── README.md
├── codex_settings/
│   ├── README.md
│   └── config.toml
└── litellm_settings/
    ├── .env
    ├── README.md
    ├── config.yaml
    ├── docker-compose-install.sh
    ├── docker-compose.yml
    ├── prometheus_conf/
    │   └── prometheus.yml
    └── prometheus_data/
        └── README.md
```

## Architecture

Codex is configured to use LiteLLM as a model provider:

```text
Codex IDE/App
  -> http://<litellm-host>:4000/v1
  -> LiteLLM proxy
  -> OpenAI API
```

LiteLLM runs with three Docker Compose services:

- `litellm`: the proxy server exposed on port `4000`.
- `db`: PostgreSQL 16 used by LiteLLM for persistent configuration and model storage.
- `prometheus`: Prometheus exposed on port `9090` for LiteLLM metrics.

## LiteLLM Settings

Ref: [litellm_settings/README.md](litellm_settings/README.md)

The LiteLLM proxy is configured in [litellm_settings/config.yaml](litellm_settings/config.yaml).

Current model mapping:

```yaml
model_list:
  - model_name: "gpt-5.4"
    litellm_params:
      model: openai/gpt-5.4
      api_key: os.environ/OPENAI_API_KEY
```

The proxy also enables verbose logging and Prometheus callbacks:

```yaml
litellm_settings:
  set_verbose: true
  callbacks: ["prometheus"]
```

The `.env` file in `litellm_settings/` provides runtime secrets for Docker Compose. It should contain these variable names:

```bash
LITELLM_MASTER_KEY="sk-..."
LITELLM_SALT_KEY="..."
OPENAI_API_KEY="sk-proj-..."
```

Do not commit real production secrets. Rotate keys immediately if a real key is accidentally shared.

## Run LiteLLM

From the LiteLLM settings directory:

```bash
cd litellm_settings
docker compose up
```

The LiteLLM API should become available at:

```text
http://localhost:4000/v1
```

Prometheus should become available at:

```text
http://localhost:9090
```

To watch logs:

```bash
docker compose logs -f
```

To test the LiteLLM proxy:

```bash
curl -X POST "http://localhost:4000/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <LITELLM_MASTER_KEY>" \
  -d '{
    "model": "gpt-5.4",
    "messages": [
      {
        "role": "user",
        "content": "what is your name?"
      }
    ]
  }'
```

## Prometheus

Prometheus is configured in [litellm_settings/prometheus_conf/prometheus.yml](litellm_settings/prometheus_conf/prometheus.yml).

It scrapes LiteLLM metrics from:

```text
litellm:4000/metrics/
```

The `bearer_token` value must match the LiteLLM master key used by the proxy.

## Codex Settings

Ref: [codex_settings/README.md](codex_settings/README.md)

The Codex example config is in [codex_settings/config.toml](codex_settings/config.toml).

The important LiteLLM provider section is:

```toml
model = "gpt-5.4"
model_reasoning_effort = "medium"

base_url = "http://18.183.96.192:4000/v1" # just an example
model_provider = "litellm"
web_search = "live"

[model_providers.litellm]
name = "LiteLLM"
base_url = "http://18.183.96.192:4000/v1" # just an example
wire_api = "responses"
env_key = "LITELLM_API_KEY"
```

Update `base_url` to match the host where LiteLLM is running. For local testing, this is usually:

```toml
base_url = "http://localhost:4000/v1"
```

Codex must also have the LiteLLM API key available in the environment:

```bash
export LITELLM_API_KEY="<LITELLM_MASTER_KEY>"
```

For future terminal sessions on macOS:

```bash
echo 'export LITELLM_API_KEY="<LITELLM_MASTER_KEY>"' >> ~/.zshenv
```

## Amazon Linux Docker Setup

[litellm_settings/docker-compose-install.sh](litellm_settings/docker-compose-install.sh) is a helper script for Amazon Linux. It installs:

- Docker Compose CLI plugin
- Docker Buildx CLI plugin

Run it only on a Linux host where the current user is allowed to use `sudo`.

## Notes And Known Issues

- Codex model traffic can be routed through LiteLLM, but non-model Codex traffic such as workspace, project, and cloud sync behavior may still go directly to OpenAI services.
- For Codex IDE usage, prefer controlling the model through `config.toml` instead of relying on the model picker UI.
- The example config currently defines one model, `gpt-5.4`. Keep the Codex `model` value aligned with the `model_name` entries in LiteLLM `config.yaml`.
- `litellm_settings/prometheus_data/` is mounted as Prometheus storage. It currently contains only a placeholder README in this repository.
