#!/usr/bin/env bash
# spotfolk.eu = the same site as fabiocostaph.com, which on this domain shows only SpotFolk.
# Copies the site from fabiocostaph-ph (in ./_src) into this repo, keeping this repo's own files.
set -euo pipefail
SRC="${1:-_src}"
python3 - "$SRC" <<'PY'
import os, shutil, sys
src = sys.argv[1]
KEEP = {".git", ".github", "_src", "CNAME", "README.md", "sync.sh", "robots.txt", "og-spotfolk.jpg"}
SKIP = KEEP | {"sitemap.xml", ".pages.yml", "pages-yml-da-copiare.txt", "spotfolk-prova.html", "wayfolk-prova.html"}
for name in os.listdir("."):            # remove what is no longer in the site (never this repo's own files)
    if name not in KEEP and not os.path.exists(os.path.join(src, name)):
        shutil.rmtree(name) if os.path.isdir(name) else os.remove(name)
for name in os.listdir(src):
    if name in SKIP: continue
    a = os.path.join(src, name)
    if os.path.isdir(a):
        if os.path.exists(name): shutil.rmtree(name)
        shutil.copytree(a, name)
    else: shutil.copy2(a, name)
PY
# search engines and previews: SpotFolk's own description and image
python3 - <<'PY'
import re
p = "index.html"; s = open(p, encoding="utf-8").read()
s = re.sub(r"<title>.*?</title>", "<title>SpotFolk — the community map</title>", s, count=1, flags=re.S)
s = re.sub(r'(<meta name="description" content=")[^"]*', r"\1Places scouted with a photographer's eye, signed by the folk who go. A free travel community: places, trips, Pass it on and Field Notes.", s, count=1)
s = re.sub(r'(<meta property="og:title" content=")[^"]*', r"\1SpotFolk — the community map", s, count=1)
s = re.sub(r'(<meta property="og:description" content=")[^"]*', r"\1Every place here was signed by someone who's been. Find your folk — free.", s, count=1)
s = re.sub(r'(<meta property="og:url" content=")[^"]*', r"\1https://spotfolk.eu/", s, count=1)
s = re.sub(r'(<link rel="canonical" href=")[^"]*', r"\1https://spotfolk.eu/", s, count=1)
IMG = "https://spotfolk.eu/og-spotfolk.jpg?v=1"
s = re.sub(r'(<meta property="og:site_name" content=")[^"]*', r"\1SpotFolk", s, count=1)
s = re.sub(r'(<meta property="og:image" content=")[^"]*', r"\g<1>" + IMG, s, count=1)
s = re.sub(r'(<meta property="og:image:alt" content=")[^"]*', r"\1SpotFolk — the map, signed by the folk", s, count=1)
s = re.sub(r'(<meta name="twitter:title" content=")[^"]*', r"\1SpotFolk — the community map", s, count=1)
s = re.sub(r'(<meta name="twitter:description" content=")[^"]*', r"\1Every place here was signed by someone who's been. Find your folk — free.", s, count=1)
s = re.sub(r'(<meta name="twitter:image" content=")[^"]*', r"\g<1>" + IMG, s, count=1)
open(p, "w", encoding="utf-8").write(s)
PY
