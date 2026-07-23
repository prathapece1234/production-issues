#!/bin/bash
# ══════════════════════════════════════════════════════════════════
#  Telvrix AI — Complete Ubuntu Setup
#  Run as: sudo bash scripts/ubuntu_setup.sh
#  Tested on Ubuntu 22.04 LTS
# ══════════════════════════════════════════════════════════════════

set -e

# ── Suppress ALL interactive popups ───────────────────────────────
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
export NEEDRESTART_SUSPEND=1
sudo mkdir -p /etc/needrestart/conf.d
echo "\$nrconf{restart} = 'a';" | sudo tee /etc/needrestart/conf.d/telvrix.conf > /dev/null
echo "\$nrconf{ucodehints} = 0;" | sudo tee -a /etc/needrestart/conf.d/telvrix.conf > /dev/null

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo ""
echo "====================================================="
echo " TELVRIX AI - Complete Ubuntu Setup"
echo " Root: $ROOT"
echo "====================================================="
echo ""

# ── Step 1: Update system ─────────────────────────────────────────
echo "[1/9] Updating system..."
sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq
echo "  [OK] System updated"

# ── Step 2: Install basic packages ────────────────────────────────
echo "[2/9] Installing basic packages..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold" \
    python3 python3-pip \
    curl wget git \
    build-essential gcc g++ make \
    ca-certificates gnupg \
    libpq-dev -qq
echo "  [OK] Python: $(python3 --version)"

# ── Step 3: Install Node.js v20 ───────────────────────────────────
echo "[3/9] Installing Node.js v20..."
# Remove old Node.js
sudo DEBIAN_FRONTEND=noninteractive apt-get remove -y \
    nodejs nodejs-doc libnode-dev libnode72 2>/dev/null || true
sudo DEBIAN_FRONTEND=noninteractive apt-get autoremove -y -qq 2>/dev/null || true
# Install Node.js v20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash - > /dev/null 2>&1
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs -qq
echo "  [OK] Node.js: $(node --version)"
echo "  [OK] npm: $(npm --version)"

# ── Step 4: Install Python packages ───────────────────────────────
echo "[4/9] Installing Python packages..."
pip3 install \
    fastapi "uvicorn[standard]" httpx python-multipart \
    fpdf2 openpyxl python-pptx python-docx \
    matplotlib pillow PyPDF2 pdfplumber \
    --break-system-packages -q 2>/dev/null || \
pip3 install \
    fastapi "uvicorn[standard]" httpx python-multipart \
    fpdf2 openpyxl python-pptx python-docx \
    matplotlib pillow PyPDF2 pdfplumber -q
echo "  [OK] Python packages installed"

# ── Step 5: Install UI packages ───────────────────────────────────
echo "[5/9] Installing UI packages..."
cd "$ROOT/ui"
npm install --legacy-peer-deps --silent
cd "$ROOT"
echo "  [OK] UI packages installed"

# ── Step 6: Install Ollama ────────────────────────────────────────
echo "[6/9] Installing Ollama..."
if command -v ollama &>/dev/null; then
    echo "  [OK] Ollama already installed"
else
    curl -fsSL https://ollama.com/install.sh | sh
    echo "  [OK] Ollama installed"
fi

# ── Step 7: Start Ollama ──────────────────────────────────────────
echo "[7/9] Starting Ollama..."
if ! pgrep -x ollama > /dev/null; then
    ollama serve > /tmp/ollama.log 2>&1 &
    sleep 10
fi
echo "  [OK] Ollama running"

# ── Step 8: Download AI models ────────────────────────────────────
echo "[8/9] Downloading AI models..."
echo "  Downloading qwen2.5-coder:7b (4.7 GB)..."
if ! ollama list 2>/dev/null | grep -q "qwen2.5-coder:7b"; then
    ollama pull qwen2.5-coder:7b
fi
echo "  [OK] qwen2.5-coder:7b ready"

echo "  Downloading gemma4:e4b (9 GB)..."
if ! ollama list 2>/dev/null | grep -q "gemma4:e4b"; then
    ollama pull gemma4:e4b
fi
echo "  [OK] gemma4:e4b ready"

# ── Step 9: Create directories and config ─────────────────────────
echo "[9/9] Creating directories and config..."
sudo mkdir -p /opt/telvrix/workspaces /opt/telvrix/history
sudo chmod -R 777 /opt/telvrix

cat > "$ROOT/.env" << ENVEOF
LLM_MODEL=qwen2.5-coder:7b
VLLM_BASE_URL=http://localhost:11434
LLM_TIMEOUT=600
SERVICE_PORT=8009
CODE_AGENT_WORKSPACE=/opt/telvrix/workspaces
HISTORY_DIR=/opt/telvrix/history
NEXT_PUBLIC_API_URL=http://localhost:8009
NEXT_PUBLIC_WS_URL=ws://localhost:8009
ENVEOF

echo "  [OK] Config saved: $ROOT/.env"
echo "  [OK] Workspaces: /opt/telvrix/workspaces"

# ── Done ──────────────────────────────────────────────────────────
echo ""
echo "====================================================="
echo " SETUP COMPLETE!"
echo ""
echo " Models installed:"
echo "   qwen2.5-coder:7b  (best for code)"
echo "   gemma4:e4b        (best for speed)"
echo ""
echo " TO START:"
echo "   bash scripts/start.sh"
echo ""
echo " TO OPEN:"
echo "   http://SERVER_IP:3000/code"
echo ""
echo " TO SWITCH MODEL:"
echo "   bash scripts/change_model.sh gemma4:e4b"
echo "====================================================="
echo ""

read -p "Start Telvrix AI now? (y/n): " answer
if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
    bash "$ROOT/scripts/start.sh"
fi
