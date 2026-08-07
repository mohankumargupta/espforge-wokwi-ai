set shell:= ["bash", "-c"]
set windows-shell := ["powershell", "-c"]
set fallback := true

deepseek_pro := "nvidia/deepseek-ai/deepseek-v4-pro"
deepseek_flash := "opencode/deepseek-v4-flash-free"
glm := "nvidia/z-ai/glm-5.2"
minimax_m3 := "nvidia/minimaxai/minimax-m3"
minimax_m27 := "nvidia/minimaxai/minimax-m2.7"
nemotron_ultra := "nvidia/nvidia/nemotron-3-ultra-550b-a55b"

prompt0a device:  ( _execute "prompt0a"  device deepseek_flash   )
prompt0b device:  ( _execute "prompt0b"  device deepseek_flash   )
prompt0c device:  ( _execute "prompt0c"  device deepseek_flash   )
prompt2a device:  ( _execute "prompt2a"  device deepseek_flash   )
prompt2b device:  ( _execute "prompt2b"  device deepseek_flash   )
prompt2c device:  ( _execute "prompt2c"  device deepseek_flash   )
prompt2d device:  ( _execute "prompt2d"  device deepseek_flash   )
prompt2e device:
    cd artifacts/{{device}}/outputs ; pwd ; esphome compile {{device}}.yaml

_execute prompt device model:
    ./runprompt.sh {{ prompt }}.txt {{ device }} {{ model }}

