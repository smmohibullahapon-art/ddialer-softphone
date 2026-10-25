import os, re

for gf in ["android/settings.gradle", "android/build.gradle"]:
    if os.path.exists(gf):
        t = open(gf).read()
        t = re.sub(r'(id\s+["\x27]org\.jetbrains\.kotlin\.android["\x27]\s+version\s+["\x27])[0-9.]+(["\x27])', r'\g<1>1.9.24\g<2>', t)
        t = re.sub(r'(ext\.kotlin_version\s*=\s*["\x27])[0-9.]+(["\x27])', r'\g<1>1.9.24\g<2>', t)
        open(gf, "w").write(t)

for root, _, files in os.walk(os.path.expanduser("~/.pub-cache")):
    for f in files:
        p = os.path.join(root, f)
        if f == "build.gradle":
            txt = open(p, "r", encoding="utf-8", errors="ignore").read()
            txt2 = re.sub(r'(kotlin_version\s*=\s*["\x27])[0-9.]+(["\x27])', r'\g<1>1.9.24\g<2>', txt)
            if txt2 != txt:
                open(p, "w", encoding="utf-8").write(txt2)
        elif f.endswith((".java", ".kt")):
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

gdir = os.path.expanduser("~/.gradle")
os.makedirs(gdir, exist_ok=True)
open(os.path.join(gdir, "init.gradle"), "w").write("""allprojects {
    buildscript {
        configurations.all {
            resolutionStrategy.eachDependency { details ->
                if (details.requested.group == 'org.jetbrains.kotlin' && details.requested.name.startsWith('kotlin-')) {
                    details.useVersion '1.9.24'
                }
            }
        }
    }
    configurations.all {
        resolutionStrategy.eachDependency { details ->
            if (details.requested.group == 'org.jetbrains.kotlin' && details.requested.name.startsWith('kotlin-stdlib')) {
                details.useVersion '1.9.24'
            }
            if (details.requested.group == 'androidx.core' && (details.requested.name == 'core' || details.requested.name == 'core-ktx')) {
                details.useVersion '1.13.1'
            }
            if (details.requested.group == 'androidx.activity' && details.requested.name.startsWith('activity')) {
                details.useVersion '1.9.3'
            }
            if (details.requested.group == 'androidx.lifecycle' && details.requested.name.startsWith('lifecycle-')) {
                details.useVersion '2.8.7'
            }
        }
    }
}
""")
