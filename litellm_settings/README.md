# LiteLLM settings
## Description
- The purpose of this project is to consolidate all LiteLLM configurations. It covers the parameters and container settings for three core components, as well as the complete configuration files and deployment steps. (本專案的目的，是為了整合所有 LiteLLM 的配置。內容涵蓋三個核心組件的參數與 Container（容器）設定，並包含完整的設定檔及部署步驟。)
- Here, I assume we're using OpenAI API rather than Azure OpenAI.

## Folder structure

```text
litellm_settings/
├── .env
├── README.md
├── config.yaml
├── docker-compose-install.sh
├── docker-compose.yml
├── prometheus_conf/
│   └── prometheus.yml
└── prometheus_data/
```


## Installation steps
- `cd` into this folder.
```bash
cd litellm_settings

```

- Pull the latest Litellm db

```bash
$ docker pull ghcr.io/berriai/litellm-database:main-latest
```

- Set up db - pull the docker compose file and prepare the file `.env`.
```
# Get the docker compose file
curl -O https://raw.githubusercontent.com/BerriAI/litellm/main/docker-compose.yml

# Add the master key - you can change this after setup. Please use the master key you use in LiteLLM config
echo 'LITELLM_MASTER_KEY="sk-1234"' > .env

# Add the litellm salt key — cannot be changed after adding a model
# Used to encrypt/decrypt your LLM API key credentials
# Generate a strong random value: https://1password.com/password-generator/
echo 'LITELLM_SALT_KEY="**********"' >> .env

# Add your model credential generated from OpenAI API platform.
OPENAI_API_KEY="sk-proj-*********"
```
- Set up litellm config


## Reference
- [Docker compose setup](./docker-compose-install.sh)
- [Docker Quick Start](https://docs.litellm.ai/docs/proxy/docker_quick_start): Please focus on `Docker Compose (Proxy + DB)`

