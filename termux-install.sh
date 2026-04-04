#!/usr/bin/env bash

# ==========================================
# 🎨 COLOR VARIABLES & UI
# ==========================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${BLUE}=======================================================${NC}"
echo -e "${CYAN}   _____                       ___  ____     ___                 __ ${NC}"
echo -e "${CYAN}  / ___/__  ______  ___  _____/   |/  _/    /   | ____  ___  ____/ /_ ${NC}"
echo -e "${CYAN}  \__ \/ / / / __ \/ _ \/ ___/ /| | / /    / /| |/ __ \/ _ \/ __ \ __/${NC}"
echo -e "${CYAN} ___/ / /_/ / /_/ /  __/ /  / ___ |/ /    / ___ / /_/ /  __/ / / / /_ ${NC}"
echo -e "${CYAN}/____/\__,_/ .___/\___/_/  /_/  |_/___/  /_/  |_\__, /\___/_/ /_/\__/ ${NC}"
echo -e "${CYAN}          /_/                                  /____/                 ${NC}"
echo -e "${YELLOW}  Ultimate God-Tier Agent v7.3 [ TERMUX FIX ] ${NC}"
echo -e "${BLUE}=======================================================${NC}"
echo ""

if [ -z "$PREFIX" ]; then
    echo -e "${RED}❌ สคริปต์นี้สำหรับ Termux เท่านั้น!${NC}"
    exit 1
fi

AGENT_DIR="$HOME/ai_agent"

# ==========================================
# 🔑 PROMPT FOR CREDENTIALS
# ==========================================
echo -e "${YELLOW}📌 กรุณากรอกข้อมูลเพื่อตั้งค่าบอท (กด Enter เพื่อใช้ค่าเริ่มต้น):${NC}"
read -p "🔹 Telegram Bot Token: " TG_TOKEN </dev/tty
read -p "🔹 Telegram User ID: " TG_USER_ID </dev/tty
read -p "🔹 AWS Access Key ID: " AWS_KEY </dev/tty
read -p "🔹 AWS Secret Access Key: " AWS_SECRET </dev/tty
read -p "🔹 AWS Region [us-east-1]: " AWS_REGION </dev/tty
AWS_REGION=${AWS_REGION:-us-east-1}
echo ""

# ==========================================
# 🌀 BACKGROUND SPINNER FUNCTION
# ==========================================
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

run_bg() {
    local msg="$1"
    shift
    echo -ne "${CYAN}⏳ $msg...${NC}"
    "$@" > $PREFIX/tmp/ai_agent_install.log 2>&1 &
    local pid=$!
    spinner $pid
    wait $pid
    if [ $? -eq 0 ]; then
        echo -e "\r${GREEN}✅ $msg... เสร็จสิ้น!${NC}"
    else
        echo -e "\r${RED}❌ $msg... ล้มเหลว! (ข้ามเพื่อติดตั้งต่อ)${NC}"
        # ไม่สั่ง exit 1 เพื่อให้การติดตั้งดำเนินต่อไปได้แม้บางคำสั่งจะพลาด
    fi
}

# ==========================================
# ⚙️ INSTALLATION STEPS (FIXED)
# ==========================================

# ลองเปิด Wake-Lock แต่ถ้าพังก็ไม่เป็นไร (ไม่ใช้ run_bg เพื่อไม่ให้หยุดการทำงาน)
echo -ne "${CYAN}⏳ เปิดโหมด Wake-Lock (ถ้ามี Termux:API)...${NC}"
termux-wake-lock > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "\r${GREEN}✅ Wake-Lock เปิดใช้งานแล้ว!${NC}"
else
    echo -e "\r${YELLOW}⚠️ ข้าม Wake-Lock (กรุณาลงแอป Termux:API เพื่อให้บอทไม่หลับ)${NC}"
fi

run_bg "อัพเดท Termux และติดตั้ง Packages" bash -c "
pkg update -y && pkg upgrade -y && \
pkg install -y python git curl wget jq openssh ffmpeg sqlite nmap dnsutils termux-api build-essential libjpeg-turbo clang openssl libffi
"

run_bg "ติดตั้ง Python Packages (No Venv)" bash -c "
mkdir -p $AGENT_DIR/{memory,logs,downloads,workspace/tmp,db} && \
pip install --upgrade pip && \
pip install boto3==1.34.69 python-telegram-bot==21.1.1 httpx==0.27.0 beautifulsoup4 aiofiles python-dotenv pytz Pillow
"

echo -ne "${CYAN}⏳ สร้างไฟล์การตั้งค่า (.env)...${NC}"
cat << EOF > $AGENT_DIR/.env
TG_TOKEN=${TG_TOKEN}
TG_USER_ID=${TG_USER_ID}
AWS_ACCESS_KEY_ID=${AWS_KEY}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET}
AWS_DEFAULT_REGION=${AWS_REGION}
MODEL_ID=global.anthropic.claude-3-5-sonnet-20241022-v2:0
TIMEZONE=Asia/Bangkok
EOF
echo -e "\r${GREEN}✅ สร้างไฟล์การตั้งค่า (.env)... เสร็จสิ้น!${NC}"

# ==========================================
# 🧠 AGENT.PY (CORE)
# ==========================================
echo -ne "${CYAN}⏳ สร้างระบบประมวลผลหลัก (agent.py)...${NC}"
cat << 'AGENTFILE' > $AGENT_DIR/agent.py
import os, json, subprocess, datetime, boto3, time, sqlite3, logging, glob
from dotenv import load_dotenv
import pytz

AGENT_DIR = os.path.expanduser("~/ai_agent")
logging.basicConfig(filename=f'{AGENT_DIR}/logs/agent.log', level=logging.INFO, format='%(asctime)s - %(message)s')
logger = logging.getLogger(__name__)

load_dotenv(f"{AGENT_DIR}/.env")
MODEL_ID = os.getenv("MODEL_ID", "global.anthropic.claude-3-5-sonnet-20241022-v2:0")
REGION = os.getenv("AWS_DEFAULT_REGION", "us-east-1")
TIMEZONE = os.getenv("TIMEZONE", "Asia/Bangkok")
WORKSPACE = f"{AGENT_DIR}/workspace"
TMP_DIR = f"{AGENT_DIR}/workspace/tmp"
MEMORY_DIR = f"{AGENT_DIR}/memory"
DOWNLOADS = f"{AGENT_DIR}/downloads"
FILE_QUEUE = f"{TMP_DIR}/tg_file_queue.txt"

bedrock = boto3.client(service_name="bedrock-runtime", region_name=REGION, aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"), aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"))

def get_now(): return datetime.datetime.now(pytz.timezone(TIMEZONE))

class Memory:
    def __init__(self):
        self.db_path = f"{MEMORY_DIR}/brain.db"
        self._init_db()
    def _init_db(self):
        conn = sqlite3.connect(self.db_path)
        conn.execute("CREATE VIRTUAL TABLE IF NOT EXISTS notes USING fts5(content, timestamp);")
        conn.execute("CREATE TABLE IF NOT EXISTS chat_history (id INTEGER PRIMARY KEY AUTOINCREMENT, role TEXT, content TEXT, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP);")
        conn.commit()
        conn.close()
    def add_chat(self, role, content):
        conn = sqlite3.connect(self.db_path)
        conn.execute("INSERT INTO chat_history (role, content) VALUES (?, ?)", (role, content))
        conn.commit()
        conn.close()
    def get_recent_chats(self, limit=20):
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        cur = conn.cursor()
        cur.execute("SELECT role, content FROM chat_history ORDER BY id DESC LIMIT ?", (limit,))
        rows = cur.fetchall()
        conn.close()
        return [{"role": r["role"], "content": r["content"]} for r in reversed(rows)]
    def save_note(self, note):
        conn = sqlite3.connect(self.db_path)
        conn.execute("INSERT INTO notes (content, timestamp) VALUES (?, ?)", (note, str(get_now())))
        conn.commit()
        conn.close()

memory = Memory()

def smart_truncate(text, max_len=2500):
    if not text: return "(ไม่มี output)"
    if len(text) <= max_len: return text
    tmp_path = f"{TMP_DIR}/out_{int(time.time())}.txt"
    with open(tmp_path, "w") as f: f.write(text)
    return text[:max_len] + f"\n\n... [ข้อความถูกตัด] ... ดูไฟล์ที่: {tmp_path}"

def run_terminal(command):
    try:
        r = subprocess.run(command, shell=True, capture_output=True, text=True, timeout=300, cwd=WORKSPACE)
        out = (r.stdout or "") + (r.stderr or "")
        return smart_truncate(out)
    except Exception as e: return f"❌ Error: {str(e)}"

def run_python_code(code):
    tmp_py = f"{TMP_DIR}/script_{int(time.time())}.py"
    with open(tmp_py, "w") as f: f.write(code)
    try:
        r = subprocess.run(f"python {tmp_py}", shell=True, capture_output=True, text=True, timeout=120)
        out = (r.stdout or "") + (r.stderr or "")
        return smart_truncate(out)
    except Exception as e: return f"❌ Python Error: {str(e)}"

def send_file_to_telegram(file_path):
    if not os.path.exists(file_path): return f"❌ ไม่พบไฟล์: {file_path}"
    with open(FILE_QUEUE, "a") as f: f.write(file_path + "\n")
    return f"✅ ส่งคำขอส่งไฟล์ {file_path} แล้ว"

TOOLS = [
    {"name": "run_terminal", "description": "รัน Bash ใน Termux", "input_schema": {"type": "object", "properties": {"command": {"type": "string"}}, "required": ["command"]}},
    {"name": "run_python_code", "description": "รันโค้ด Python", "input_schema": {"type": "object", "properties": {"code": {"type": "string"}}, "required": ["code"]}},
    {"name": "send_file_to_telegram", "description": "ส่งไฟล์จากมือถือเข้า Telegram", "input_schema": {"type": "object", "properties": {"file_path": {"type": "string"}}, "required": ["file_path"]}},
    {"name": "save_memory", "description": "บันทึกความจำ", "input_schema": {"type": "object", "properties": {"note": {"type": "string"}}, "required": ["note"]}},
]

def execute_tool(name, params):
    if name == "run_terminal": return run_terminal(params["command"])
    if name == "run_python_code": return run_python_code(params["code"])
    if name == "send_file_to_telegram": return send_file_to_telegram(params["file_path"])
    if name == "save_memory": memory.save_note(params["note"]); return "✅ บันทึกแล้ว"
    return "❌ Unknown tool"

def call_agent_sync(user_message):
    memory.add_chat("user", user_message)
    messages = memory.get_recent_chats(20)
    system_prompt = f"คุณคือ AI Agent บน Termux Android\nเวลาปัจจุบัน: {get_now()}\nโฟลเดอร์งาน: {WORKSPACE}"
    all_responses = []
    for attempt in range(10):
        try:
            body = json.dumps({"anthropic_version": "bedrock-2023-05-31", "max_tokens": 4096, "system": system_prompt, "messages": messages, "tools": TOOLS})
            resp = bedrock.invoke_model(modelId=MODEL_ID, body=body)
            result = json.loads(resp["body"].read())
            stop_reason = result.get("stop_reason")
            content_blocks = result.get("content", [])
            text_parts = [b["text"] for b in content_blocks if b["type"] == "text"]
            if text_parts: all_responses.append("\n".join(text_parts))
            if stop_reason != "tool_use": break
            messages.append({"role": "assistant", "content": content_blocks})
            tool_results = []
            for tool in result.get("content", []):
                if tool["type"] == "tool_use":
                    res = execute_tool(tool["name"], tool["input"])
                    tool_results.append({"type": "tool_result", "tool_use_id": tool["id"], "content": res})
            messages.append({"role": "user", "content": tool_results})
        except Exception as e:
            all_responses.append(f"❌ API Error: {str(e)}")
            break
    final = "\n\n".join(all_responses)
    memory.add_chat("assistant", final)
    return final if final.strip() else "✅ ดำเนินการเสร็จสิ้น"
AGENTFILE
echo -e "\r${GREEN}✅ สร้างระบบประมวลผลหลัก (agent.py)... เสร็จสิ้น!${NC}"

# ==========================================
# 🤖 BOT.PY (TELEGRAM + FILES)
# ==========================================
echo -ne "${CYAN}⏳ สร้างระบบ Telegram Bot (bot.py)...${NC}"
cat << 'BOTFILE' > $AGENT_DIR/bot.py
import os, asyncio, logging
from dotenv import load_dotenv
from telegram import Update
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes
from agent import call_agent_sync, AGENT_DIR

logging.basicConfig(format='%(asctime)s - %(message)s', level=logging.INFO)
logger = logging.getLogger(__name__)

load_dotenv(f"{AGENT_DIR}/.env")
TG_TOKEN = os.getenv("TG_TOKEN")
TG_USER_ID = int(os.getenv("TG_USER_ID"))
DOWNLOADS = f"{AGENT_DIR}/downloads"
FILE_QUEUE = f"{AGENT_DIR}/workspace/tmp/tg_file_queue.txt"

user_locks = {}
def get_user_lock(user_id):
    if user_id not in user_locks: user_locks[user_id] = asyncio.Lock()
    return user_locks[user_id]

def auth(func):
    async def wrapper(update: Update, context: ContextTypes.DEFAULT_TYPE):
        if update.effective_user.id != TG_USER_ID: return
        return await func(update, context)
    return wrapper

async def typing_loop(chat):
    try:
        while True:
            await chat.send_action("typing")
            await asyncio.sleep(4)
    except asyncio.CancelledError: pass

async def send_queued_files(chat, bot):
    if not os.path.exists(FILE_QUEUE): return
    with open(FILE_QUEUE, "r") as f: files = f.read().splitlines()
    os.remove(FILE_QUEUE)
    for file_path in files:
        if os.path.exists(file_path):
            try: await chat.send_document(document=open(file_path, 'rb'))
            except: pass

@auth
async def start(update, context):
    await update.message.reply_text("📱 Ultimate Agent v7.3 [Termux] พร้อมรบครับเจ้านาย!")

@auth
async def handle_document(update, context):
    doc = update.message.document
    file = await context.bot.get_file(doc.file_id)
    save_path = f"{DOWNLOADS}/{doc.file_name}"
    await file.download_to_drive(save_path)
    await process_message(update, context, f"เจ้านายส่งไฟล์ {doc.file_name} มาที่ {save_path}")
    await update.message.reply_text(f"📁 ได้รับไฟล์ {doc.file_name} แล้ว!")

@auth
async def handle_photo(update, context):
    photo = update.message.photo[-1]
    file = await context.bot.get_file(photo.file_id)
    save_path = f"{DOWNLOADS}/photo_{photo.file_id}.jpg"
    await file.download_to_drive(save_path)
    await process_message(update, context, f"เจ้านายส่งรูปมา บันทึกที่ {save_path}")
    await update.message.reply_text("📷 ได้รับรูปภาพแล้ว!")

async def process_message(update, context, user_msg):
    chat = update.effective_chat
    lock = get_user_lock(update.effective_user.id)
    if lock.locked(): return
    async with lock:
        typing_task = asyncio.create_task(typing_loop(chat))
        try:
            loop = asyncio.get_event_loop()
            final_response = await loop.run_in_executor(None, call_agent_sync, user_msg)
            if len(final_response) > 4000:
                for i in range(0, len(final_response), 4000):
                    await context.bot.send_message(chat.id, final_response[i:i+4000])
            else:
                await context.bot.send_message(chat.id, final_response)
            await send_queued_files(chat, context.bot)
        except Exception as e:
            await context.bot.send_message(chat.id, f"❌ Error: {str(e)[:4000]}")
        finally:
            typing_task.cancel()

@auth
async def handle_text(update, context):
    await process_message(update, context, update.message.text)

def main():
    app = Application.builder().token(TG_TOKEN).build()
    app.add_handler(CommandHandler("start", start))
    app.add_handler(MessageHandler(filters.Document.ALL, handle_document))
    app.add_handler(MessageHandler(filters.PHOTO, handle_photo))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_text))
    app.run_polling(drop_pending_updates=True)

if __name__ == "__main__":
    main()
BOTFILE
echo -e "\r${GREEN}✅ สร้างระบบ Telegram Bot (bot.py)... เสร็จสิ้น!${NC}"

# ==========================================
# 🚀 AUTO START SCRIPT (nohup)
# ==========================================
run_bg "สร้างสคริปต์จัดการบอท" bash -c "
cat << 'STARTFILE' > $AGENT_DIR/start_bot.sh
#!/usr/bin/env bash
termux-wake-lock
pkill -f 'python.*bot.py'
nohup python $AGENT_DIR/bot.py > $AGENT_DIR/logs/nohup.log 2>&1 &
echo \"✅ บอททำงานแล้ว!\"
STARTFILE

cat << 'STOPFILE' > $AGENT_DIR/stop_bot.sh
#!/usr/bin/env bash
pkill -f 'python.*bot.py'
echo \"🛑 ปิดบอทเรียบร้อยแล้ว\"
STOPFILE
chmod +x $AGENT_DIR/start_bot.sh $AGENT_DIR/stop_bot.sh
"

bash $AGENT_DIR/start_bot.sh > /dev/null 2>&1

echo ""
echo -e "${BLUE}=======================================================${NC}"
if pgrep -f "python.*bot.py" > /dev/null; then
    echo -e "${GREEN} 🚀 ติดตั้งเสร็จสมบูรณ์! บอทออนไลน์แล้ว!${NC}"
else
    echo -e "${RED} ⚠️ บอทไม่ทำงาน ลองรัน: ${CYAN}~/ai_agent/start_bot.sh${NC}"
fi
echo -e "${BLUE}=======================================================${NC}"
