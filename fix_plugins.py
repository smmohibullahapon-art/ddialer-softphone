import os, re

for root, _, files in os.walk(os.path.expanduser("~/.pub-cache")):
    for f in files:
        if f.endswith((".java", ".kt")):
            p = os.path.join(root, f)
            txt = open(p, "r", encoding="utf-8", errors="ignore").read()
            if "Registrar" not in txt:
                continue
            orig = txt
            txt = re.sub(r"import\s+io\.flutter\.plugin\.common\.PluginRegistry\.Registrar\s*;?\s*", "", txt)
            pat = re.compile(r"(?:public\s+static\s+void\s+registerWith\s*\(\s*(?:PluginRegistry\.)?Registrar\s+\w+\s*\)|(?:@JvmStatic\s+)?fun\s+registerWith\s*\(\s*\w+\s*:\s*(?:PluginRegistry\.)?Registrar\s*\))\s*\{")
            while True:
                m = pat.search(txt)
                if not m:
                    break
                s, i, d = m.start(), m.end(), 1
                while i < len(txt) and d > 0:
                    if txt[i] == "{": d += 1
                    elif txt[i] == "}": d -= 1
                    i += 1
                txt = txt[:s] + txt[i:]
            if txt != orig:
                open(p, "w", encoding="utf-8").write(txt)
                print("Patched:", p)
