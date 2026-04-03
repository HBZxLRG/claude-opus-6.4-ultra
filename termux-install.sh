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
echo -e "${YELLOW}      Ultimate God-Tier Agent v7.1 [ TERMUX EDITION ] ${NC}"
echo -e "${BLUE}=======================================================${NC}"
echo ""

# ตรวจสอบว่าเป็น Termux หรือไม่
if [ -z "$PREFIX" ]; then
    echo -e "${RED}❌ สคริปต์นี้ออกแบบมาสำหรับรันบนแอป Termux (Android) เท่านั้น!${NC}"
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
        echo -e "\r${RED}❌ $msg... ล้มเหลว! (เช็ค log: cat $PREFIX/tmp/ai_agent_install.log)${NC}"
        exit 1
    fi
}

# ==========================================
# ⚙️ INSTALLATION STEPS (TERMUX)
# ==========================================
run_bg "เปิดโหมด Wake-Lock (ป้องกันแอนดรอยด์หลับ)" termux-wake-lock

run_bg "อัพเดท Termux และติดตั้ง Packages พื้นฐาน" bash -c "
pkg update -y && \
pkg install -y python git curl wget jq openssh ffmpeg sqlite nmap dnsutils termux-api build-essential libjpeg-turbo clang openssl libffi
"

run_bg "สร้างโฟลเดอร์ระบบและติดตั้ง Python Pip" bash -c "
mkdir -p $AGENT_DIR/{memory,logs,downloads,workspace/tmp,db} && \
cd $AGENT_DIR && \
python -m venv venv && \
$AGENT_DIR/venv/bin/pip install --upgrade pip && \
$AGENT_DIR/venv/bin/pip install boto3==1.34.69 python-telegram-bot==21.1.1 httpx==0.27.0 beautifulsoup4 paramiko aiofiles python-dotenv pytz Pillow
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
# 🧠 AGENT.PY (TERMUX CORE)
# ==========================================
echo -ne "${CYAN}⏳ สร้างระบบประมวลผลหลัก (agent.py)...${NC}"
cat << 'AGENTFILE' > $AGENT_DIR/agent.py
import os, json, asyncio, subprocess, datetime, traceback, platform, boto3, time, sqlite3, logging, glob
from dotenv import load_dotenv
import pytz

AGENT_DIR = os.path.expanduser("~/ai_agent")

logging.basicConfig(
    filename=f'{AGENT_DIR}/logs/agent.log',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

load_dotenv(f"{AGENT_DIR}/.env")
MODEL_ID = os.getenv("MODEL_ID", "global.anthropic.claude-3-5-sonnet-20241022-v2:0")
REGION = os.getenv("AWS_DEFAULT_REGION", "us-east-1")
TIMEZONE = os.getenv("TIMEZONE", "Asia/Bangkok")
WORKSPACE = f"{AGENT_DIR}/workspace"
TMP_DIR = f"{AGENT_DIR}/workspace/tmp"
MEMORY_DIR = f"{AGENT_DIR}/memory"

bedrock = boto3.client(
    service_name="bedrock-runtime",
    region_name=REGION,
    aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY")
)

def get_now(): return datetime.datetime.now(pytz.timezone(TIMEZONE))

class Memory:
    def __init__(self):
        self.db_path = f"{MEMORY_DIR}/brain.db"
        self._init_db()
        self._cleanup_tmp()

    def _init_db(self):
        conn = sqlite3.connect(self.db_path)
        conn.execute("CREATE VIRTUAL TABLE IF NOT EXISTS notes USING fts5(content, timestamp);")
        conn.execute("CREATE TABLE IF NOT EXISTS chat_history (id INTEGER PRIMARY KEY AUTOINCREMENT, role TEXT, content TEXT, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP);")
        conn.commit()
        conn.close()

    def _cleanup_tmp(self):
        try:
            now = time.time()
            for f in glob.glob(f"{TMP_DIR}/*"):
                if os.path.isfile(f) and now - os.path.getmtime(f) > 86400: os.remove(f)
        except: pass

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

    def search_notes(self, keyword):
        conn = sqlite3.connect(self.db_path)
        cur = conn.cursor()
        cur.execute("SELECT content FROM notes WHERE notes MATCH ? ORDER BY rank LIMIT 5", (keyword,))
        rows = cur.fetchall()
        conn.close()
        return [r[0] for r in rows]

memory = Memory()

def smart_truncate(text, max_len=2500):
    if not text: return "(ไม่มี output)"
    if len(text) <= max_len: return text
    tmp_path = f"{TMP_DIR}/out_{int(time.time())}.txt"
    with open(tmp_path, "w") as f: f.write(text)
    return text[:max_len] + f"\n\n... [ข้อความยาวเกินไป ถูกตัดออก] ...\nดูผลลัพธ์ได้ที่: {tmp_path}"

def run_terminal(command):
    try:
        r = subprocess.run(command, shell=True, capture_output=True, text=True, timeout=600, cwd=WORKSPACE)
        out = (r.stdout or "") + (r.stderr or "")
        if r.returncode != 0: out += f"\n[Exit: {r.returncode}]"
        return smart_truncate(out)
    except Exception as e: return f"❌ Error: {str(e)}"

def run_python_code(code):
    tmp_py = f"{TMP_DIR}/script_{int(time.time())}.py"
    with open(tmp_py, "w") as f: f.write(code)
    try:
        # บังคับใช้ VENV Python ของโปรเจกต์
        python_bin = f"{AGENT_DIR}/venv/bin/python"
        r = subprocess.run(f"{python_bin} {tmp_py}", shell=True, capture_output=True, text=True, timeout=120)
        out = (r.stdout or "") + (r.stderr or "")
        return smart_truncate(out)
    except Exception as e: return f"❌ Python Error: {str(e)}"

# Termux Fallback Web Scraper (No Playwright to save size & avoid build errors)
def browse_web_basic(url):
    try:
        import httpx
        from bs4 import BeautifulSoup
        resp = httpx.get(url, timeout=15.0, follow_redirects=True)
        soup = BeautifulSoup(resp.text, 'html.parser')
        for tag in soup(['script', 'style', 'nav', 'footer', 'header']): tag.decompose()
        text = soup.get_text(separator='\n', strip=True)
        return smart_truncate(text, max_len=5000)
    except Exception as e:
        return f"❌ Web Error: {str(e)}"

TOOLS = [
    {"name": "run_terminal", "description": "รันคำสั่ง Termux/Linux (Bash)", "input_schema": {"type": "object", "properties": {"command": {"type": "string"}}, "required": ["command"]}},
    {"name": "run_python_code", "description": "รันโค้ด Python ทันที", "input_schema": {"type": "object", "properties": {"code": {"type": "string"}}, "required": ["code"]}},
    {"name": "browse_web", "description": "เปิดเว็บและดึง Text", "input_schema": {"type": "object", "properties": {"url": {"type": "string"}}, "required": ["url"]}},
    {"name": "save_memory", "description": "จดจำข้อมูลลงสมองกล (VectorDB)", "input_schema": {"type": "object", "properties": {"note": {"type": "string"}}, "required": ["note"]}},
    {"name": "search_memory", "description": "ค้นหาความจำเก่าๆ", "input_schema": {"type": "object", "properties": {"keyword": {"type": "string"}}, "required": ["keyword"]}},
]

def execute_tool(name, params):
    if name == "run_terminal": return run_terminal(params["command"])
    if name == "run_python_code": return run_python_code(params["code"])
    if name == "browse_web": return browse_web_basic(params["url"])
    if name == "save_memory": memory.save_note(params["note"]); return "✅ บันทึกความจำแล้ว"
    if name == "search_memory": return "\n".join(memory.search_notes(params["keyword"])) or "ไม่พบข้อมูล"
    return "❌ Unknown tool"

def call_agent_sync(user_message):
    memory.add_chat("user", user_message)
    messages = memory.get_recent_chats(20)
    
    system_prompt = f"""คุณคือ AI Agent ผู้คุ้มครองมือถือ Android
- คุณกำลังทำงานอยู่บนแอป 'Termux' (Linux environment บน Android)
- **คุณไม่มีสิทธิ์ Root และไม่มี Docker** อย่าพยายามรันคำสั่ง sudo หรือ docker
- คุณสามารถรันคำสั่ง linux พื้นฐาน, จัดการไฟล์, ดึงเว็บ, เขียน python ได้
เวลาปัจจุบัน: {get_now()}
โฟลเดอร์งาน: {WORKSPACE}"""

    all_responses = []
    
    for attempt in range(15):
        try:
            body = json.dumps({
                "anthropic_version": "bedrock-2023-05-31",
                "max_tokens": 4096,
                "system": system_prompt,
                "messages": messages,
                "tools": TOOLS
            })
            
            for retry in range(3):
                try:
                    resp = bedrock.invoke_model(modelId=MODEL_ID, body=body)
                    break
                except Exception as e:
                    if retry == 2: raise e
                    time.sleep(2 ** retry)

            result = json.loads(resp["body"].read())
            stop_reason = result.get("stop_reason")
            content_blocks = result.get("content", [])
            
            text_parts = []
            tool_uses = []
            
            for block in content_blocks:
                if block["type"] == "text": text_parts.append(block["text"])
                elif block["type"] == "tool_use": tool_uses.append(block)
                
            if text_parts:
                out_text = "\n".join(text_parts)
                all_responses.append(out_text)
                
            if stop_reason != "tool_use" or not tool_uses:
                break
                
            messages.append({"role": "assistant", "content": content_blocks})
            tool_results = []
            
            for tool in tool_uses:
                logger.info(f"Executing tool: {tool['name']}")
                result_text = execute_tool(tool["name"], tool["input"])
                tool_results.append({"type": "tool_result", "tool_use_id": tool["id"], "content": result_text})
                
            messages.append({"role": "user", "content": tool_results})
            
        except Exception as e:
            error_msg = f"❌ Error API: {str(e)}"
            logger.error(error_msg)
            all_responses.append(error_msg)
            break

    final = "\n\n".join(all_responses)
    if not final.strip(): final = "✅ ดำเนินการเสร็จสิ้น"
    memory.add_chat("assistant", final)
    return final

AGENTFILE
echo -e "\r${GREEN}✅ สร้างระบบประมวลผลหลัก (agent.py)... เสร็จสิ้น!${NC}"

# ==========================================
# 🤖 BOT.PY (TELEGRAM SYSTEM)
# ==========================================
echo -ne "${CYAN}⏳ สร้างระบบ Telegram Bot (bot.py)...${NC}"
cat << 'BOTFILE' > $AGENT_DIR/bot.py
import os, asyncio, logging
from dotenv import load_dotenv
from telegram import Update
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes
from agent import call_agent_sync, AGENT_DIR

logging.basicConfig(
    format='%(asctime)s - %(levelname)s - %(message)s',
    level=logging.INFO,
    handlers=[logging.FileHandler(f"{AGENT_DIR}/logs/bot.log"), logging.StreamHandler()]
)
logger = logging.getLogger(__name__)

load_dotenv(f"{AGENT_DIR}/.env")
TG_TOKEN = os.getenv("TG_TOKEN")
TG_USER_ID = int(os.getenv("TG_USER_ID"))

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

@auth
async def start(update, context):
    await update.message.reply_text("📱 Ultimate Agent v7.1 [Termux Edition] พร้อมใช้งานบนมือถือครับเจ้านาย!")

async def process_message(update, context, user_msg):
    chat = update.effective_chat
    lock = get_user_lock(update.effective_user.id)

    if lock.locked():
        await update.message.reply_text("⏳ บอทกำลังประมวลผลคำสั่งก่อนหน้า...")
        return

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
        except Exception as e:
            await context.bot.send_message(chat.id, f"❌ System Error: {str(e)[:4000]}")
        finally:
            typing_task.cancel()

@auth
async def handle_message(update, context):
    await process_message(update, context, update.message.text)

def main():
    app = Application.builder().token(TG_TOKEN).build()
    app.add_handler(CommandHandler("start", start))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))
    app.run_polling(drop_pending_updates=True)

if __name__ == "__main__":
    main()
BOTFILE
echo -e "\r${GREEN}✅ สร้างระบบ Telegram Bot (bot.py)... เสร็จสิ้น!${NC}"

# ==========================================
# 🚀 AUTO START SCRIPT (nohup)
# ==========================================
run_bg "สร้างสคริปต์เปิด/ปิดบอทสำหรับ Termux" bash -c "
cat << 'STARTFILE' > $AGENT_DIR/start_bot.sh
#!/usr/bin/env bash
termux-wake-lock
pkill -f 'python.*bot.py'
nohup $AGENT_DIR/venv/bin/python $AGENT_DIR/bot.py > $AGENT_DIR/logs/nohup.log 2>&1 &
echo \"✅ บอททำงานแล้ว! (ทำงานเบื้องหลัง)\"
STARTFILE

cat << 'STOPFILE' > $AGENT_DIR/stop_bot.sh
#!/usr/bin/env bash
pkill -f 'python.*bot.py'
echo \"🛑 ปิดบอทเรียบร้อยแล้ว\"
STOPFILE

chmod +x $AGENT_DIR/start_bot.sh $AGENT_DIR/stop_bot.sh
"

# สั่งรันบอททันที
bash $AGENT_DIR/start_bot.sh > /dev/null 2>&1

# ==========================================
# 🎉 SUCCESS SUMMARY
# ==========================================
echo ""
echo -e "${BLUE}=======================================================${NC}"
if pgrep -f "python.*bot.py" > /dev/null; then
    echo -e "${GREEN} 🚀 การติดตั้งเสร็จสมบูรณ์! บอทออนไลน์บน Termux แล้ว!${NC}"
else
    echo -e "${RED} ⚠️ บอทอาจจะไม่ทำงาน ลองสั่งรันด้วยตัวเอง: ${CYAN}~/ai_agent/start_bot.sh${NC}"
fi
echo -e "${BLUE}=======================================================${NC}"
echo -e "👉 ${YELLOW}เปิดแอป Telegram แล้วทัก /start ไปที่บอทของคุณได้เลยครับ${NC}"
echo -e "⚙️ คำสั่งจัดการบอท:"
echo -e "   ▶️ เปิดบอท:  ${CYAN}~/ai_agent/start_bot.sh${NC}"
echo -e "   ⏹️ ปิดบอท:  ${CYAN}~/ai_agent/stop_bot.sh${NC}"
echo -e "   📂 ดู Logs: ${CYAN}tail -f ~/ai_agent/logs/bot.log${NC}"
echo -e "${BLUE}=======================================================${NC}"
