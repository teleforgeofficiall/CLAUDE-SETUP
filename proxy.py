import http.server, json, sys, os, requests, traceback

KEY_FILE = os.path.join(os.path.expanduser("~"), ".opencode_key")
API_KEY = open(KEY_FILE).read().strip() if os.path.exists(KEY_FILE) else ""
BASE = "https://opencode.ai/zen/v1/chat/completions"
LOG_DIR = os.path.join(os.path.expanduser("~"), ".opencode_proxy")
os.makedirs(LOG_DIR, exist_ok=True)
LOG_FILE = os.path.join(LOG_DIR, "proxy.log")

def plog(msg):
    with open(LOG_FILE, "a") as f:
        f.write(f"{msg}\n")

plog("=== PROXY STARTED ===")

class P(http.server.BaseHTTPRequestHandler):
    def _json(self, code, data):
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())

    def do_GET(self):
        if self.path.startswith("/v1/models"):
            self._json(200, {"data": [
                {"id": "claude-sonnet-4-6", "object": "model"},
                {"id": "claude-opus-4-8", "object": "model"},
                {"id": "deepseek-v4-flash-free", "object": "model"}
            ]})
        else:
            self._json(200, {"ok": True})

    def do_POST(self):
        if not self.path.startswith("/v1/messages"):
            self._json(404, {"error": "not found"})
            return
        try:
            length = int(self.headers.get("Content-Length", 0))
            d = json.loads(self.rfile.read(length).decode())
            m = "deepseek-v4-flash-free"
            ms = d.get("messages", [])
            if d.get("system"):
                ms.insert(0, {"role": "system", "content": d["system"]})
            plog(f"{d.get('model','?')} -> {m} | {len(ms)} msgs")
            r = requests.post(BASE, json={
                "model": m, "messages": ms,
                "max_tokens": d.get("max_tokens", 16384), "stream": False
            }, headers={
                "Authorization": f"Bearer {API_KEY}",
                "User-Agent": "Mozilla/5.0"
            }, timeout=180)
            plog(f"Upstream: {r.status_code}")
            if r.status_code != 200:
                self._json(500, {"error": r.text[:300]})
                return
            j = r.json()
            t = j["choices"][0]["message"]["content"] or ""
            u = j.get("usage", {})
            self._json(200, {
                "id": "msg", "type": "message", "role": "assistant",
                "content": [{"type": "text", "text": t}],
                "model": m, "stop_reason": "end_turn",
                "usage": {"input_tokens": u.get("prompt_tokens", 0), "output_tokens": u.get("completion_tokens", 0)}
            })
            plog("OK")
        except Exception as e:
            plog(f"ERR: {traceback.format_exc()}")
            self._json(500, {"error": str(e)[:200]})

    def log_message(self, *a): pass

if __name__ == "__main__":
    if not API_KEY:
        print("ERROR: API key not found! Run setup.bat first.")
        sys.exit(1)
    http.server.HTTPServer(("127.0.0.1", 4001), P).serve_forever()
