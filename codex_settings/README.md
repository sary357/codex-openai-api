# Description
- Describe what codex (IDE/App) setting we need to modify.

# Folder structure
```text
codex_settings/
├── README.md
└── config.toml
```

# Set up steps
- modify [config.toml](./config.toml). I just list necessary parts we need to modify. Please DO NOT replace your config.toml with mine. 
```text

model = "gpt-5.4" # default setting is gpt-5.4. It should be the one "model_name" of the models in the setting "model_list" of litellm config file "config.yaml".
...
...

base_url = "http://18.183.96.192:4000/v1" # The URL of LiteLLM endpoint. In my exmaple, I put litellm on 18.183.96.192 and listen port is 4000
model_provider = "litellm"               
web_search = "live"
[model_providers.litellm]
name = "LiteLLM"
base_url = "http://18.183.96.192:4000/v1" # The URL of LiteLLM endpoint. In my exmaple, I put litellm on 18.183.96.192 and listen port is 4000
wire_api = "responses"
env_key = "LITELLM_API_KEY"          
...
...
```

- make sure the environment variable has `LITELLM_API_KEY`. In my case, I use master key. On Mac OS, my command is
```bash
echo "LITELLM_API_KEY=\"sk-1234\"" >> ~/.zshenv # for the sessions I launch after reboot
export LITELLM_API_KEY="sk-1234"                # for current session
```

- Launch VS code with codex plugin installed. Supposedly, you are about to see "LITELLM" on bottom-right side and ONLY 1 model in model list.

# Issues
- On codex App, although all traffic to OpenAI models  will go through LiteLLM, other API traffic like (Workspace/Project/Cloud Sync) should go to OpenAI. The evidence is I can see the models access log in LiteLLM log but I still can not see any project settings/chat on my codex App. So, I recommend not to use LiteLLM to control Codex App. (在 Codex App 上，雖然所有傳給 OpenAI 模型的流量都會經過 LiteLLM，但其他像 Workspace、Project 或 Cloud Sync 的 API 流量應該是直接連到 OpenAI 的。證據是：我能在 LiteLLM 的日誌（log）裡看到模型存取的紀錄，但在 Codex App 上卻還是看不到任何專案設定或聊天內容。因此，我建議不要用 LiteLLM 來控制 Codex App) 
- On codex IDE, we should not use the model list in codex plugin(it should be bottom right side). Instead, we should use config.toml to control what models we can use. It seems like we can not define multiple models in config.toml at this moment. (在 Codex IDE 上，我們不應該使用 Codex 外掛程式裡的模型列表（應該是在vscode codex plugin 視窗右下角模型清單）。相反地，我們應該用 config.toml 來控制我們可以使用哪些模型。目前看起來，我們似乎無法在 config.toml 裡同時定義多個模型)
