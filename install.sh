#!/bin/bash

# 函数定义：生成配置文件内容
generate_config() {
    local vless_id=$1
    local vmess_id=$2
    local api_host=$3
    local api_key=$4

    # 生成config文件内容
    config_content="Log:
  Level: debug
Nodes:
  - PanelType: "GoV2Panel"
    ApiConfig:
      ApiHost: $api_host
      ApiKey: $api_key
      NodeID: $vless_id
      NodeType: Vless
      Timeout: 5
      EnableVless: true
      VlessFlow: "xtls-rprx-vision"
      DisableCustomConfig: true
    ControllerConfig:
      UpdatePeriodic: 5
      DNSType: AsIs
      EnableREALITY: true
      REALITYConfigs:
        Show: true
        Dest: www.microsoft.com:443
        ServerNames:
          - www.microsoft.com
        PrivateKey: MGcbKLA9jtg3SwHviAMH1EVDnYNODWpiz0qdqNvgmHw
        ShortIds:
          - bd5c500d0928efd4
  - PanelType: "GoV2Panel"
    ApiConfig:
      ApiHost: $api_host
      ApiKey: $api_key
      NodeID: $vmess_id
      NodeType: Vmess
      Timeout: 5
    ControllerConfig:
      UpdatePeriodic: 5
"

    # 将内容写入文件
    echo "$config_content" > "config.yml"
}

# 主程序

# 检查参数数量
if [[ $# -ne 4 ]]; then
    echo "Usage: $0 <Vless节点ID> <Vmess节点ID> <前端面板地址> <前端面板密钥>"
    exit 1
fi

# 接收参数
vless_id=$1
vmess_id=$2
api_host=$3
api_key=$4

# 生成配置文件
echo "正在根据输入参数生成配置文件！"
generate_config "$vless_id" "$vmess_id" "$api_host" "$api_key"

# 下载 XrayR2
# 检查是否存在 XrayR
if [ -f "XrayR" ]; then
    echo "XrayR 已经存在。"
else
    echo "下载 XrayR 中..."
    wget "https://github.com/Tie-Tie/AutoXrayRSH/releases/download/V1.0.0/XrayR" -q --show-progress
fi

# 赋予执行权限
echo "赋予XrayR执行权限"
chmod +x XrayR

echo "正在设置环境变量XRAY_BUF_SPLICE=disable，有效提高流量统计准确率！"
export XRAY_BUF_SPLICE=disable

# 查找与 XrayR 相关的进程，并获取其 PID
pids=$(ps aux | grep '[X]rayR' | awk '{print $2}')

# 如果找到了进程
if [ -n "$pids" ]; then
    echo "正在终止 XrayR 进程..."
    # 循环遍历每个 PID 并终止进程
    for pid in $pids; do
        kill "$pid"
        echo "已终止进程 $pid"
    done
else
    echo "没有找到 XrayR 相关的进程。"
fi

# 执行 XrayR
echo "执行 XrayR..."
nohup ./XrayR &

echo "XrayR 执行完成"