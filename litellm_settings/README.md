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

- Prepare [docker-compose.yml](./docker-compose.yml). Because we use config.yaml, we need to uncomment the following. The default settings is commentted. 
```text
    ##################################### Uncomment these lines to start proxy with a config.yaml file ##
    volumes:
     - ./config.yaml:/app/config.yaml
    command:
     - "--config=/app/config.yaml"
    ##############################################
```

- Prepare the file `.env`.
```bash
# Add the master key - you can change this after setup. Please use the master key you use in LiteLLM config
echo 'LITELLM_MASTER_KEY="sk-1234"' > .env

# Add the litellm salt key — cannot be changed after adding a model
# Used to encrypt/decrypt your LLM API key credentials
# Generate a strong random value: https://1password.com/password-generator/
echo 'LITELLM_SALT_KEY="**********"' >> .env

# Add your model credential generated from OpenAI API platform.
OPENAI_API_KEY="sk-proj-*********"
```

- [config.yaml](./config.yaml): please modify the following accordingly.
```text
model_list:
  - model_name: "gpt-5.4"             # all requests where model not in your config go to this deployment
    litellm_params:
      model: openai/gpt-5.4           # set `openai/` to use the openai route
      api_key: os.environ/OPENAI_API_KEY 

litellm_settings:
  set_verbose: true                   # debugging mode
  callbacks: ["prometheus"]           # callback to prometheus

general_settings:
  master_key: sk-1234 # 🔑 your proxy admin key (must start with sk-). it must be master key in litellm.
  database_url: "postgresql://llmproxy:dbpassword9090@db:5432/litellm"
```

- [prometheus.yml](prometheus_conf/prometheus.yml): please modify bearer_token. It should be `master key` of litellm.
```text
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: "litellm"
    metrics_path: '/metrics/'
    static_configs:
      - targets: ["litellm:4000"]
    bearer_token: "sk-1234"
```

- bring it up: Once everything config is ready. please start it up with `docker compose up`
```bash
docker compose up
[+] up 4/4
 ✔ Network litellm_default        Created                                                                                                                                                                        0.2s
 ✔ Container litellm-prometheus-1 Created                                                                                                                                                                        0.1s
 ✔ Container litellm_db           Created                                                                                                                                                                        0.1s
 ✔ Container litellm-litellm-1    Created               
```
- check the status
```bash
docker compose logs -f

```
- when you see the following message, litellm server should be online
```text
litellm-1     | 
litellm-1     |    ██╗     ██╗████████╗███████╗██╗     ██╗     ███╗   ███╗
litellm-1     |    ██║     ██║╚══██╔══╝██╔════╝██║     ██║     ████╗ ████║
litellm-1     |    ██║     ██║   ██║   █████╗  ██║     ██║     ██╔████╔██║
litellm-1     |    ██║     ██║   ██║   ██╔══╝  ██║     ██║     ██║╚██╔╝██║
litellm-1     |    ███████╗██║   ██║   ███████╗███████╗███████╗██║ ╚═╝ ██║
litellm-1     |    ╚══════╝╚═╝   ╚═╝   ╚══════╝╚══════╝╚══════╝╚═╝     ╚═╝
litellm-1     | 
litellm-1     | query-engine ac9d7041ed77bcc8a8dbd2ab6616b39013829574
litellm-1     | INFO:     Application startup complete.
litellm-1     | INFO:     Uvicorn running on http://0.0.0.0:4000 (Press CTRL+C to quit)
litellm-1     | 
litellm-1     | #------------------------------------------------------------#
litellm-1     | #                                                            #
litellm-1     | #               'A feature I really want is...'               #
litellm-1     | #        https://github.com/BerriAI/litellm/issues/new        #
litellm-1     | #                                                            #
litellm-1     | #------------------------------------------------------------#
litellm-1     | 
litellm-1     |  Thank you for using LiteLLM! - Krrish & Ishaan

```

- Give it a try with `curl`
```bash
curl -X POST 'http://0.0.0.0:4000/chat/completions' \                                                                           
-H 'Content-Type: application/json' \
-H 'Authorization: Bearer sk-1234' \
-d '{
    "model": "gpt-5.4",
    "messages": [                               
      {
        "role": "system",
        "content": "You are an LLM named gpt-5.4"
      },                               
      {
        "role": "user",
        "content": "what is your name?"
      }
    ]
}'
```
- Then, you will get the result like.
```
{"id":"chatcmpl-DlFuqHEl7g1a5ZOGKMWpHWvMKqfFy","created":1780154968,"model":"gpt-5.4","object":"chat.completion","choices":[{"finish_reason":"stop","index":0,"message":{"content":"I’m gpt-5.4.","role":"assistant","provider_specific_fields":{"refusal":null},"annotations":[]},"provider_specific_fields":{}}],"usage":{"completion_tokens":12,"prompt_tokens":27,"total_tokens":39,"completion_tokens_details":{"accepted_prediction_tokens":0,"audio_tokens":0,"reasoning_tokens":0,"rejected_prediction_tokens":0},"prompt_tokens_details":{"audio_tokens":0,"cached_tokens":0}},"service_tier":"default"}
```

## Reference
- [Docker compose setup](./docker-compose-install.sh): Only for Amazon Linux and please use linux account which is allowed to use `sudo`.
- [Docker Quick Start](https://docs.litellm.ai/docs/proxy/docker_quick_start): Please focus on `Docker Compose (Proxy + DB)`

