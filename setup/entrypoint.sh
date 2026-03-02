#!/bin/bash
set -e

# 检查是否配置了 LLM API Key
check_api_keys() {
    local keys=(
        "ANTHROPIC_API_KEY"
        "OPENAI_API_KEY"
        "GEMINI_API_KEY"
        "GOOGLE_API_KEY"
        "GROQ_API_KEY"
        "DEEPSEEK_API_KEY"
        "OPENROUTER_API_KEY"
        "TOGETHER_API_KEY"
        "MISTRAL_API_KEY"
        "FIREWORKS_API_KEY"
    )

    for key in "${keys[@]}"; do
        if [ -n "${!key}" ]; then
            echo "✓ Found API key: $key"
            return 0
        fi
    done

    # 检查本地 LLM 配置
    if [ -n "$OLLAMA_BASE_URL" ] || [ -n "$VLLM_BASE_URL" ] || [ -n "$LMSTUDIO_BASE_URL" ]; then
        echo "✓ Found local LLM configuration"
        return 0
    fi

    return 1
}

# 启动配置引导页面
start_setup_page() {
    echo "⚠️  No LLM API Key configured!"
    echo "📋 Starting setup guide page on port 4200..."

    cd /opt/openfang/setup

    # 使用 busybox httpd 或 python 启动简单 HTTP 服务器
    if command -v busybox &> /dev/null; then
        exec busybox httpd -f -p 4200 -h .
    elif command -v python3 &> /dev/null; then
        exec python3 -m http.server 4200
    elif command -v python &> /dev/null; then
        exec python -m SimpleHTTPServer 4200
    else
        # 回退：使用 netcat (如果没有其他选项)
        echo "No HTTP server available, showing message..."
        while true; do
            echo "Please configure LLM API Key in environment variables"
            sleep 60
        done
    fi
}

# 主逻辑
echo "🔍 Checking LLM API Key configuration..."

if check_api_keys; then
    echo "✅ API Key configured, starting OpenFang..."
    exec openfang start
else
    start_setup_page
fi
