#!/data/data/com.termux/files/usr/bin/bash
# LOCAL LLM INSTALLER v2.1 (FULL VERSION - 100% COMPLETE)
set +e

# กำหนดค่าสีให้แสดงผลถูกต้อง
R="\e[1;31m"; G="\e[1;32m"; Y="\e[1;33m"
C="\e[1;36m"; W="\e[1;37m"; D="\e[0;90m"; N="\e[0m"
INSTALL_DIR=~/.watch-llm; MODELS_DIR=~/models; LOG=~/watch-llm-install.log
mkdir -p "$INSTALL_DIR" "$MODELS_DIR"

# ========== BRANDS ==========
BRANDS=(
    "Google        Gemma 2/3/4"
    "Meta          Llama 3/4"
    "Alibaba       Qwen 2.5/3"
    "Microsoft     Phi 3/4"
    "Mistral       7B/Mixtral/Nemo"
    "DeepSeek      R1/Coder"
    "Zhipu         GLM-4"
    "Falcon        3 series"
    "Databricks    DBRX"
    "xAI           Grok-1"
    "Yi            1.5B-34B"
    "Apple         OpenELM"
    "IBM           Granite"
    "Stability     StableLM"
)

# ========== GET MODELS FOR BRAND ==========
get_models() {
    case $1 in
    0) echo 'Gemma 4 E2B 2B ~1.5GB|1.5GB'
       echo 'Gemma 4 E4B 4B ~2.5GB|2.5GB'
       echo 'Gemma 3 1B ~0.8GB|0.8GB'
       echo 'Gemma 3 2B ~1.5GB|1.5GB'
       echo 'Gemma 3 4B ~2.6GB|2.6GB'
       echo 'Gemma 3 12B ~7.2GB|7.2GB'
       echo 'Gemma 3 27B ~16GB|16GB'
       echo 'Gemma 2 2B ~1.5GB|1.5GB'
       echo 'Gemma 2 9B ~5.5GB|5.5GB'
       echo 'Gemma 2 27B ~16GB|16GB';;
    1) echo 'Llama 4 Scout 109B ~17GB|17GB'
       echo 'Llama 4 Maverick 400B ~17GB|17GB'
       echo 'Llama 3.3 70B ~40GB|40GB'
       echo 'Llama 3.3 8B ~5.2GB|5.2GB'
       echo 'Llama 3.2 3B ~2GB|2GB'
       echo 'Llama 3.2 1B ~0.8GB|0.8GB'
       echo 'Llama 3.1 8B ~5.2GB|5.2GB'
       echo 'Llama 3.1 70B ~40GB|40GB'
       echo 'Llama 3 8B ~5GB|5GB'
       echo 'Llama 3 70B ~40GB|40GB';;
    2) echo 'Qwen3 0.6B ~400MB|0.4GB'
       echo 'Qwen3 1.7B ~1.2GB|1.2GB'
       echo 'Qwen3 4B ~2.6GB|2.6GB'
       echo 'Qwen3 8B ~5.2GB|5.2GB'
       echo 'Qwen3 14B ~8.5GB|8.5GB'
       echo 'Qwen3 32B ~19GB|19GB'
       echo 'Qwen3 72B ~42GB|42GB'
       echo 'Qwen2.5 0.5B ~400MB|0.4GB'
       echo 'Qwen2.5 1.5B ~1GB|1GB'
       echo 'Qwen2.5 3B ~2GB|2GB'
       echo 'Qwen2.5 7B ~4.5GB|4.5GB'
       echo 'Qwen2.5 14B ~8.5GB|8.5GB'
       echo 'Qwen2.5 32B ~19GB|19GB'
       echo 'Qwen2.5 72B ~42GB|42GB'
       echo 'Qwen2.5 Coder 7B ~4.5GB|4.5GB'
       echo 'Qwen2.5 Coder 32B ~19GB|19GB';;
    3) echo 'Phi-4 Mini 3.8B ~2.5GB|2.5GB'
       echo 'Phi-4 14B ~8.5GB|8.5GB'
       echo 'Phi-4 Reasoning 3.8B ~2.5GB|2.5GB'
       echo 'Phi-3 Mini 3.8B ~2.5GB|2.5GB'
       echo 'Phi-3 Small 7B ~4.5GB|4.5GB'
       echo 'Phi-3 Medium 14B ~8.5GB|8.5GB';;
    4) echo 'Mistral 7B ~4.1GB|4.1GB'
       echo 'Mixtral 8x7B ~13GB|13GB'
       echo 'Mixtral 8x22B ~22GB|22GB'
       echo 'Mistral Nemo 12B ~7GB|7GB';;
    5) echo 'DeepSeek R1 1.5B ~1.1GB|1.1GB'
       echo 'DeepSeek R1 7B ~4.5GB|4.5GB'
       echo 'DeepSeek R1 8B ~5.2GB|5.2GB'
       echo 'DeepSeek R1 14B ~8.5GB|8.5GB'
       echo 'DeepSeek R1 32B ~19GB|19GB'
       echo 'DeepSeek R1 70B ~40GB|40GB'
       echo 'DeepSeek Coder 16B ~10GB|10GB';;
    6) echo 'GLM-4 9B ~6.2GB|6.2GB';;
    7) echo 'Falcon 3 1B ~0.8GB|0.8GB'
       echo 'Falcon 3 3B ~2GB|2GB'
       echo 'Falcon 3 7B ~4.5GB|4.5GB'
       echo 'Falcon 3 10B ~6.5GB|6.5GB';;
    8) echo 'DBRX 132B ~36GB|36GB';;
    9) echo 'Grok-1 314B ~314GB|314GB';;
    10) echo 'Yi 1.5B ~1GB|1GB'
        echo 'Yi 6B ~4GB|4GB'
        echo 'Yi 9B ~5.5GB|5.5GB'
        echo 'Yi 34B ~20GB|20GB';;
    11) echo 'OpenELM 270M ~300MB|0.3GB'
        echo 'OpenELM 450M ~400MB|0.4GB'
        echo 'OpenELM 1.1B ~800MB|0.8GB'
        echo 'OpenELM 3B ~2GB|2GB';;
    12) echo 'Granite 3B ~2GB|2GB'
        echo 'Granite 8B ~5GB|5GB';;
    13) echo 'StableLM 3B ~2GB|2GB'
        echo 'Stable Code 3B ~2GB|2GB';;
    esac
}

# ========== GET DOWNLOAD URL ==========
get_url() {
    local n="$1"
    case "$n" in
    "Gemma 4 E2B")  echo "bartowski/google_gemma-4-2b-it-GGUF/google_gemma-4-2b-it-Q4_K_M.gguf";;
    "Gemma 4 E4B")  echo "bartowski/google_gemma-4-4b-it-GGUF/google_gemma-4-4b-it-Q4_K_M.gguf";;
    "Gemma 3 1B")   echo "bartowski/google_gemma-3-1b-it-GGUF/google_gemma-3-1b-it-Q4_K_M.gguf";;
    "Gemma 3 2B")   echo "bartowski/google_gemma-3-2b-it-GGUF/google_gemma-3-2b-it-Q4_K_M.gguf";;
    "Gemma 3 4B")   echo "bartowski/google_gemma-3-4b-it-GGUF/google_gemma-3-4b-it-Q4_K_M.gguf";;
    "Gemma 3 12B")  echo "bartowski/google_gemma-3-12b-it-GGUF/google_gemma-3-12b-it-Q4_K_M.gguf";;
    "Gemma 3 27B")  echo "bartowski/google_gemma-3-27b-it-GGUF/google_gemma-3-27b-it-Q4_K_M.gguf";;
    "Gemma 2 2B")   echo "bartowski/gemma-2-2b-it-GGUF/gemma-2-2b-it-Q4_K_M.gguf";;
    "Gemma 2 9B")   echo "bartowski/gemma-2-9b-it-GGUF/gemma-2-9b-it-Q4_K_M.gguf";;
    "Gemma 2 27B")  echo "bartowski/gemma-2-27b-it-GGUF/gemma-2-27b-it-Q4_K_M.gguf";;
    "Llama 4 Scout") echo "bartowski/Llama-4-Scout-17B-16E-Instruct-GGUF/Llama-4-Scout-17B-16E-Instruct-Q4_K_M.gguf";;
    "Llama 4 Maverick") echo "bartowski/Llama-4-Maverick-17B-128E-Instruct-GGUF/Llama-4-Maverick-17B-128E-Instruct-Q4_K_M.gguf";;
    "Llama 3.3 70B") echo "bartowski/Llama-3.3-70B-Instruct-GGUF/Llama-3.3-70B-Instruct-Q4_K_M.gguf";;
    "Llama 3.3 8B")  echo "bartowski/Llama-3.3-8B-Instruct-GGUF/Llama-3.3-8B-Instruct-Q4_K_M.gguf";;
    "Llama 3.2 3B")  echo "bartowski/Llama-3.2-3B-Instruct-GGUF/Llama-3.2-3B-Instruct-Q4_K_M.gguf";;
    "Llama 3.2 1B")  echo "bartowski/Llama-3.2-1B-Instruct-GGUF/Llama-3.2-1B-Instruct-Q4_K_M.gguf";;
    "Llama 3.1 8B")  echo "bartowski/Meta-Llama-3.1-8B-Instruct-GGUF/Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf";;
    "Llama 3.1 70B") echo "bartowski/Meta-Llama-3.1-70B-Instruct-GGUF/Meta-Llama-3.1-70B-Instruct-Q4_K_M.gguf";;
    "Llama 3 8B")    echo "bartowski/Meta-Llama-3-8B-Instruct-GGUF/Meta-Llama-3-8B-Instruct-Q4_K_M.gguf";;
    "Llama 3 70B")   echo "bartowski/Meta-Llama-3-70B-Instruct-GGUF/Meta-Llama-3-70B-Instruct-Q4_K_M.gguf";;
    "Qwen3 0.6B")   echo "Qwen/Qwen3-0.6B-GGUF/Qwen3-0.6B-Q4_K_M.gguf";;
    "Qwen3 1.7B")   echo "Qwen/Qwen3-1.7B-GGUF/Qwen3-1.7B-Q4_K_M.gguf";;
    "Qwen3 4B")     echo "Qwen/Qwen3-4B-GGUF/Qwen3-4B-Q4_K_M.gguf";;
    "Qwen3 8B")     echo "Qwen/Qwen3-8B-GGUF/Qwen3-8B-Q4_K_M.gguf";;
    "Qwen3 14B")    echo "Qwen/Qwen3-14B-GGUF/Qwen3-14B-Q4_K_M.gguf";;
    "Qwen3 32B")    echo "Qwen/Qwen3-32B-GGUF/Qwen3-32B-Q4_K_M.gguf";;
    "Qwen3 72B")    echo "Qwen/Qwen3-72B-GGUF/Qwen3-72B-Q4_K_M.gguf";;
    "Qwen2.5 0.5B") echo "Qwen/Qwen2.5-0.5B-Instruct-GGUF/Qwen2.5-0.5B-Instruct-Q4_K_M.gguf";;
    "Qwen2.5 1.5B") echo "Qwen/Qwen2.5-1.5B-Instruct-GGUF/Qwen2.5-1.5B-Instruct-Q4_K_M.gguf";;
    "Qwen2.5 3B")   echo "Qwen/Qwen2.5-3B-Instruct-GGUF/Qwen2.5-3B-Instruct-Q4_K_M.gguf";;
    "Qwen2.5 7B")   echo "Qwen/Qwen2.5-7B-Instruct-GGUF/Qwen2.5-7B-Instruct-Q4_K_M.gguf";;
    "Qwen2.5 14B")  echo "Qwen/Qwen2.5-14B-Instruct-GGUF/Qwen2.5-14B-Instruct-Q4_K_M.gguf";;
    "Qwen2.5 32B")  echo "Qwen/Qwen2.5-32B-Instruct-GGUF/Qwen2.5-32B-Instruct-Q4_K_M.gguf";;
    "Qwen2.5 72B")  echo "Qwen/Qwen2.5-72B-Instruct-GGUF/Qwen2.5-72B-Instruct-Q4_K_M.gguf";;
    "Qwen2.5 Coder 7B")  echo "Qwen/Qwen2.5-Coder-7B-Instruct-GGUF/Qwen2.5-Coder-7B-Instruct-Q4_K_M.gguf";;
    "Qwen2.5 Coder 32B") echo "Qwen/Qwen2.5-Coder-32B-Instruct-GGUF/Qwen2.5-Coder-32B-Instruct-Q4_K_M.gguf";;
    "Phi-4 Mini")   echo "bartowski/Phi-4-mini-instruct-GGUF/Phi-4-mini-instruct-Q4_K_M.gguf";;
    "Phi-4")        echo "bartowski/Phi-4-GGUF/Phi-4-Q4_K_M.gguf";;
    "Phi-4 Reasoning") echo "bartowski/Phi-4-reasoning-GGUF/Phi-4-reasoning-Q4_K_M.gguf";;
    "Phi-3 Mini")   echo "bartowski/Phi-3-mini-4k-instruct-GGUF/Phi-3-mini-4k-instruct-Q4_K_M.gguf";;
    "Phi-3 Small")  echo "bartowski/Phi-3-small-8k-instruct-GGUF/Phi-3-small-8k-instruct-Q4_K_M.gguf";;
    "Phi-3 Medium") echo "bartowski/Phi-3-medium-4k-instruct-GGUF/Phi-3-medium-4k-instruct-Q4_K_M.gguf";;
    "Mistral 7B")   echo "bartowski/Mistral-7B-Instruct-v0.3-GGUF/Mistral-7B-Instruct-v0.3-Q4_K_M.gguf";;
    "Mixtral 8x7B") echo "bartowski/Mixtral-8x7B-Instruct-v0.1-GGUF/Mixtral-8x7B-Instruct-v0.1-Q4_K_M.gguf";;
    "Mixtral 8x22B") echo "bartowski/Mixtral-8x22B-Instruct-v0.1-GGUF/Mixtral-8x22B-Instruct-v0.1-Q4_K_M.gguf";;
    "Mistral Nemo 12B") echo "bartowski/Mistral-Nemo-Instruct-2407-GGUF/Mistral-Nemo-Instruct-2407-Q4_K_M.gguf";;
    "DeepSeek R1 1.5B") echo "bartowski/DeepSeek-R1-Distill-Qwen-1.5B-GGUF/DeepSeek-R1-Distill-Qwen-1.5B-Q4_K_M.gguf";;
    "DeepSeek R1 7B") echo "bartowski/DeepSeek-R1-Distill-Qwen-7B-GGUF/DeepSeek-R1-Distill-Qwen-7B-Q4_K_M.gguf";;
    "DeepSeek R1 8B") echo "bartowski/DeepSeek-R1-Distill-Llama-8B-GGUF/DeepSeek-R1-Distill-Llama-8B-Q4_K_M.gguf";;
    "DeepSeek R1 14B") echo "bartowski/DeepSeek-R1-Distill-Qwen-14B-GGUF/DeepSeek-R1-Distill-Qwen-14B-Q4_K_M.gguf";;
    "DeepSeek R1 32B") echo "bartowski/DeepSeek-R1-Distill-Qwen-32B-GGUF/DeepSeek-R1-Distill-Qwen-32B-Q4_K_M.gguf";;
    "DeepSeek R1 70B") echo "bartowski/DeepSeek-R1-Distill-Llama-70B-GGUF/DeepSeek-R1-Distill-Llama-70B-Q4_K_M.gguf";;
    "DeepSeek Coder 16B") echo "bartowski/DeepSeek-Coder-V2-Lite-Instruct-GGUF/DeepSeek-Coder-V2-Lite-Instruct-Q4_K_M.gguf";;
    "GLM-4 9B")     echo "bartowski/glm-4-9b-chat-1m-GGUF/glm-4-9b-chat-1m-Q4_K_M.gguf";;
    "Falcon 3 1B")  echo "bartowski/Falcon3-1B-Instruct-GGUF/Falcon3-1B-Instruct-Q4_K_M.gguf";;
    "Falcon 3 3B")  echo "bartowski/Falcon3-3B-Instruct-GGUF/Falcon3-3B-Instruct-Q4_K_M.gguf";;
    "Falcon 3 7B")  echo "bartowski/Falcon3-7B-Instruct-GGUF/Falcon3-7B-Instruct-Q4_K_M.gguf";;
    "Falcon 3 10B") echo "bartowski/Falcon3-10B-Instruct-GGUF/Falcon3-10B-Instruct-Q4_K_M.gguf";;
    "DBRX")         echo "bartowski/dbrx-instruct-GGUF/dbrx-instruct-Q4_K_M.gguf";;
    "Grok-1")       echo "bartowski/grok-1-GGUF/grok-1-Q4_K_M.gguf";;
    "Yi 1.5B")      echo "bartowski/Yi-1.5-1.5B-Chat-GGUF/Yi-1.5-1.5B-Chat-Q4_K_M.gguf";;
    "Yi 6B")        echo "bartowski/Yi-1.5-6B-Chat-GGUF/Yi-1.5-6B-Chat-Q4_K_M.gguf";;
    "Yi 9B")        echo "bartowski/Yi-1.5-9B-Chat-GGUF/Yi-1.5-9B-Chat-Q4_K_M.gguf";;
    "Yi 34B")       echo "bartowski/Yi-34B-Chat-GGUF/Yi-34B-Chat-Q4_K_M.gguf";;
    "OpenELM 270M") echo "bartowski/OpenELM-270M-Instruct-GGUF/OpenELM-270M-Instruct-Q4_K_M.gguf";;
    "OpenELM 450M") echo "bartowski/OpenELM-450M-Instruct-GGUF/OpenELM-450M-Instruct-Q4_K_M.gguf";;
    "OpenELM 1.1B") echo "bartowski/OpenELM-1_1B-Instruct-GGUF/OpenELM-1_1B-Instruct-Q4_K_M.gguf";;
    "OpenELM 3B")   echo "bartowski/OpenELM-3B-Instruct-GGUF/OpenELM-3B-Instruct-Q4_K_M.gguf";;
    "Granite 3B")   echo "bartowski/granite-3.0-2b-instruct-GGUF/granite-3.0-2b-instruct-Q4_K_M.gguf";;
    "Granite 8B")   echo "bartowski/granite-3.0-8b-instruct-GGUF/granite-3.0-8b-instruct-Q4_K_M.gguf";;
    "StableLM 3B")  echo "bartowski/stablelm-2-1_6b-chat-GGUF/stablelm-2-1_6b-chat-Q4_K_M.gguf";;
    "Stable Code 3B") echo "bartowski/stable-code-instruct-3b-GGUF/stable-code-instruct-3b-Q4_K_M.gguf";;
    *) echo "";;
    esac
}

# ========== MAIN ==========
clear
echo -e "${C}╔════════════════════════════════════════════════════════════╗${N}"
echo -e "${C}║${N} 🚀 ${C}AI Agent v2.0 Installer                                  ${C}║${N}"
echo -e "${C}║${N}    ${C}(Local LLM Background Server)${N}                           ${C}║${N}"
echo -e "${C}╚════════════════════════════════════════════════════════════╝${N}"
echo ""

# Show RAM info
ram_kb=$(grep MemTotal /proc/meminfo 2>/dev/null|awk '{print $2}'||echo 0)
ram_mb=$((ram_kb/1024))
disk=$(df -h /data 2>/dev/null|awk 'NR==2{print $4}'||echo "?")

echo -e "${Y}📌 ข้อมูลระบบของคุณ (สเปคที่แนะนำคือ RAM 8GB)${N}"
echo -e "   RAM: ${ram_mb}MB | Storage: ${disk}"
echo ""

echo -e "${Y}📌 กรุณาเลือกข้อมูลแบรนด์และโมเดลที่ต้องการติดตั้ง (พิมพ์เลขแล้วกด Enter)${N}"
echo -e "${Y}   (กด 0 เพื่อยกเลิก)${N}"
echo ""

for i in "${!BRANDS[@]}"; do
    echo -e "    ${G}[$((i+1))]${N} ${BRANDS[$i]}"
done
echo ""
echo -ne "${C}🤖 [1/2]${N} เลือกแบรนด์ AI [1-${#BRANDS[@]}]: "
read bchoice

if [ -z "$bchoice" ] || [ "$bchoice" = "0" ]; then
    echo -e "  ${R}ยกเลิกการติดตั้ง${N}"; exit 0
fi

brand_idx=$((bchoice-1))
if [ "$brand_idx" -lt 0 ] || [ "$brand_idx" -ge "${#BRANDS[@]}" ]; then
    echo -e "  ${R}ตัวเลือกไม่ถูกต้อง${N}"; exit 0
fi

# ===== SELECT MODEL =====
mapfile -t model_list < <(get_models "$brand_idx")
model_count=${#model_list[@]}

echo ""
for i in "${!model_list[@]}"; do
    display=$(echo "${model_list[$i]}" | cut -d'|' -f1)
    echo -e "    ${G}[$((i+1))]${N} ${display}"
done
echo ""
echo -ne "${C}📦 [2/2]${N} เลือกรุ่นโมเดล [1-$model_count]: "
read mchoice

if [ -z "$mchoice" ] || [ "$mchoice" = "0" ]; then
    echo -e "  ${R}ยกเลิกการติดตั้ง${N}"; exit 0
fi

model_idx=$((mchoice-1))
if [ "$model_idx" -lt 0 ] || [ "$model_idx" -ge "$model_count" ]; then
    echo -e "  ${R}ตัวเลือกไม่ถูกต้อง${N}"; exit 0
fi

model_line="${model_list[$model_idx]}"
MODEL_NAME=$(echo "$model_line" | cut -d'|' -f1 | sed 's/ $//')
ram_need=$(echo "$model_line" | cut -d'|' -f2)

# Warn if RAM insufficient
ram_num=$(echo "$ram_need" | sed 's/GB//' | awk '{printf "%d", $1 * 1024}' 2>/dev/null)
[ -z "$ram_num" ] && ram_num=0
if [ "$ram_mb" -lt "$ram_num" ] && [ "$ram_num" -gt 2048 ]; then
    echo ""
    echo -e "  ${R}⚠️ คำเตือน: ${MODEL_NAME} ต้องการ RAM ประมาณ ~${ram_need}${N}"
    echo -e "  ${R}⚠️ อุปกรณ์ของคุณมี RAM ~${ram_mb}MB${N}"
    echo ""
    read -p "  ต้องการดำเนินการต่อหรือไม่? (y/N): " confirm
    [[ ! "$confirm" =~ ^[Yy]$ ]] && { echo -e "  ${R}ยกเลิกการติดตั้ง${N}"; exit 0; }
fi

echo ""
echo -e "${G}✅ รับข้อมูลเรียบร้อย! กำลังเริ่มอัปเกรดระบบเบื้องหลัง...${N}"
echo ""

# ===== STEP 1: TERMUX SETUP =====
echo -e "${C}[i]${N} กำลังติดตั้งแพ็กเกจระบบ Termux..."
termux-setup-storage 2>/dev/null || true
(
    pkg update -y
    pkg upgrade -y -o Dpkg::Options::="--force-confnew"
    pkg install -y git cmake clang make wget curl python termux-tools tmux
) >> "$LOG" 2>&1
echo -e "${G}[√]${N} กำลังติดตั้งแพ็กเกจระบบ Termux... เสร็จสิ้น!"

# ===== STEP 2: BUILD LLAMA.CPP =====
echo -e "${C}[i]${N} กำลังดาวน์โหลดและคอมไพล์ Engine (llama.cpp)..."
(
    [ -d ~/llama.cpp ] && rm -rf ~/llama.cpp
    git clone --depth 1 https://github.com/ggml-org/llama.cpp.git ~/llama.cpp
    mkdir -p ~/llama.cpp/build && cd ~/llama.cpp/build
    cmake .. -DCMAKE_BUILD_TYPE=Release
    CORES=$(nproc)
    cmake --build . --config Release -j"$CORES"
) >> "$LOG" 2>&1

if [ -f ~/llama.cpp/build/bin/llama-cli ] || [ -f ~/llama.cpp/build/llama-cli ]; then
    echo -e "${G}[√]${N} กำลังดาวน์โหลดและคอมไพล์ Engine (llama.cpp)... เสร็จสิ้น!"
else
    echo -e "${R}[x]${N} การคอมไพล์ล้มเหลว! ตรวจสอบที่ $LOG"
    exit 1
fi

# ===== STEP 3: DOWNLOAD MODEL =====
echo -e "${C}[i]${N} กำลังดาวน์โหลดโมเดล ${MODEL_NAME}..."
rel=$(get_url "$MODEL_NAME")
repo=$(dirname "$rel")
file=$(basename "$rel")
url="https://huggingface.co/${repo}/resolve/main/${file}"
mkdir -p ~/models

if [ -f ~/models/"$file" ]; then
    echo -e "${G}[√]${N} มีไฟล์โมเดลนี้อยู่แล้ว... ข้ามการดาวน์โหลด!"
else
    wget -c --show-progress -O ~/models/"$file" "$url"
    if [ $? -eq 0 ] && [ -f ~/models/"$file" ]; then
        echo -e "${G}[√]${N} ดาวน์โหลดโมเดล... เสร็จสิ้น!"
    else
        echo -e "${R}[x]${N} การดาวน์โหลดล้มเหลว หรือ ลิงก์ไฟล์ผิดพลาด!"
        exit 1
    fi
fi

# ===== STEP 4: CREATE SCRIPTS =====
echo -e "${C}[i]${N} กำลังสร้างสคริปต์ควบคุมและตั้งค่าเบื้องหลัง..."
CORES=$(nproc)

LLAMA_CLI="~/llama.cpp/build/bin/llama-cli"
LLAMA_SERVER="~/llama.cpp/build/bin/llama-server"
[ ! -f ~/llama.cpp/build/bin/llama-cli ] && LLAMA_CLI="~/llama.cpp/build/llama-cli"
[ ! -f ~/llama.cpp/build/bin/llama-server ] && LLAMA_SERVER="~/llama.cpp/build/llama-server"

cat > ~/chat.sh << CHAT
#!/data/data/com.termux/files/usr/bin/bash
clear
echo ""
echo "  CHAT MODE: ${MODEL_NAME}"
echo "  Ctrl+C to quit"
echo ""
$LLAMA_CLI -m ~/models/${file} -ngl 0 -t ${CORES} -c 2048 --temp 0.7 --top-p 0.9 --repeat-penalty 1.1 -i -p "You are a helpful AI assistant. Reply in Thai when spoken to in Thai. Be concise."
CHAT
chmod +x ~/chat.sh

cat > ~/server.sh << SERV
#!/data/data/com.termux/files/usr/bin/bash
clear
echo ""
echo "  API SERVER: ${MODEL_NAME}"
echo "  http://localhost:8080/v1"
echo ""
$LLAMA_SERVER -m ~/models/${file} -ngl 0 -t ${CORES} -c 2048 --host 0.0.0.0 --port 8080
SERV
chmod +x ~/server.sh

cat > ~/watchdog.sh << WD
#!/data/data/com.termux/files/usr/bin/bash
termux-wake-lock 2>/dev/null
while true; do
    if ! curl -s http://localhost:8080/health > /dev/null 2>&1; then
        pkill -f llama-server 2>/dev/null; sleep 2
        $LLAMA_SERVER -m ~/models/${file} -ngl 0 -t ${CORES} -c 2048 --host 0.0.0.0 --port 8080 > ~/server.log 2>&1 &
        sleep 10
    fi
    sleep 30
done
WD
chmod +x ~/watchdog.sh

echo -e "${G}[√]${N} กำลังสร้างสคริปต์ควบคุม... เสร็จสิ้น!"

# ===== STEP 5: AUTO-START & DONE =====
echo -e "${C}[i]${N} กำลังเปิดระบบ AI ให้ทำงานเบื้องหลัง..."
nohup ~/watchdog.sh > /dev/null 2>&1 &
sleep 2

echo ""
echo -e "${C}╔════════════════════════════════════════════════════════════╗${N}"
echo -e "${C}║${N} 🎉 ${G}ติดตั้งและรันเซิร์ฟเวอร์เสร็จสมบูรณ์เรียบร้อย!              ${C}║${N}"
echo -e "${C}╚════════════════════════════════════════════════════════════╝${N}"
echo ""
echo -e "  ${W}โมเดลที่รัน:${N} ${MODEL_NAME}"
echo -e "  ${W}สถานะ:${N} ${G}🟢 ออนไลน์เบื้องหลังที่ Port 8080${N}"
echo ""
echo -e "  ${C}~/chat.sh${N}    - คุยกับ AI ทันทีผ่านหน้าจอแชท"
echo -e "  ${C}~/watchdog.sh${N} - สคริปต์เฝ้าระวัง (ทำงานอยู่เบื้องหลังแล้ว)"
echo -e "  ${C}pkill llama${N}  - คำสั่งสำหรับปิดเซิร์ฟเวอร์"
echo ""
read -p "  ต้องการเข้าสู่หน้าต่างแชทตอนนี้เลยหรือไม่? (y/N): " ans
[[ "$ans" =~ ^[Yy]$ ]] && ~/chat.sh
