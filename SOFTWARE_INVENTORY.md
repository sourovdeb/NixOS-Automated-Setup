# AEON Writer OS — Complete Software & Extension Inventory
> Cross-referenced from ai_agent_instruction.md + ASSISTIVE_TOOLS_RESEARCH.md

---

## VS Code Extensions to Install (Windows Phase 0)

### Essential for Build Work
| Extension ID | Purpose |
|-------------|---------|
| `ms-python.python` | Python scripting (dashboard, scripts) |
| `ms-python.vscode-pylance` | Python IntelliSense |
| `yzhang.markdown-all-in-one` | Markdown editing/preview |
| `redhat.vscode-yaml` | YAML configs (notifications.yml, docker-compose) |
| `ms-azuretools.vscode-docker` | Docker Compose management (Phase I services) |
| `foxundermoon.shell-format` | Bash script formatting |
| `timonwong.shellcheck` | Shell script linting |
| `streetsidesoftware.code-spell-checker` | Typo prevention |
| `bierner.markdown-preview-github-styles` | GitHub-style preview |
| `esbenp.prettier-vscode` | Format YAML/JSON/MD |

### Accessibility & Writing
| Extension ID | Purpose |
|-------------|---------|
| `shd101wyy.markdown-preview-enhanced` | Enhanced MD preview with export |

---

## Linux Package Inventory by Phase

### Phase 3 (Foundation) — pacman
```
base-devel git curl wget nodejs npm python python-pip
firefox code neovim htop btop tree ripgrep fzf flatpak
timeshift timeshift-autosnap cronie
xf86-input-wacom libwacom
linux-firmware-mediatek sof-firmware
```

### Phase A (Accessibility) — pacman + AUR + flatpak
```
# AUR
ttf-opendyslexic-git ttf-atkinson-hyperlegible ttf-lexend
gnome-browser-connector gammastep papirus-icon-theme

# Flatpak
com.mattjakeman.ExtensionManager

# GNOME Extensions (IDs)
Just Perfection (3843), Pano (5278), Caffeine (517), Vitals (518)

# Accessibility
orca at-spi2-core magnus
```

### Phase B (Dashboard) — pacman
```
python-gobject gtk4 libadwaita
# (should be pre-installed with GNOME)
```

### Phase C (Writing) — pacman + AUR + flatpak + pip
```
# pacman
pandoc typst hugo zathura zathura-pdf-mupdf xournalpp ghostwriter
libreoffice-fresh

# Flatpak
md.obsidian.Obsidian

# AUR (optional additions from research)
zettlr-bin novelwriter manuskript
languagetool vale

# pip
proselint
```

### Phase D (Podcast & Transcription) — pacman + AUR + pip
```
# pacman
audacity ffmpeg lame sox easyeffects

# AUR
whisper.cpp piper-tts noisetorch

# pip
openai-whisper nerd-dictation vosk

# Additional from research
espeak-ng
```

### Phase E (Publishing) — AUR + pip
```
# AUR
wp-cli

# pip
python-wordpress-xmlrpc requests playwright
```

### Phase F (AI Layer) — pacman + curl + docker
```
# pacman
docker docker-compose

# curl install
ollama

# Ollama models
llama3.2:3b nomic-embed-text qwen2.5-coder:3b

# Docker
open-webui
```

### Phase G (Notifications) — pacman + flatpak
```
# pacman
dunst libnotify

# Flatpak (from research)
org.gnome.Solanum
com.rafaelmardojai.Blanket
```

### Phase H (Safety) — pacman
```
cockpit
```

### Phase I (Self-Hosted Services) — Docker
```
nextcloud searxng ghost vikunja castopod
```

### Phase J (Habits) — AUR + pacman
```
# pacman / AUR
espanso autokey ulauncher

# From research
super-productivity-bin
```

### Phase K (Shareability)
```
archiso
```

---

## Additions from MIT/Stanford/Yale Research

| Source | Tool/Concept | Integration Point |
|--------|-------------|-------------------|
| MIT Morphic | Auto-accessibility profiles | Phase A — create profile switcher |
| Stanford d.school | Liberatory Design framework | Phase K — ISO packaging process |
| Yale Dyslexia Center | Reading settings (1.5x spacing, 16pt+, left-align) | Phase A/C — Obsidian & Ghostwriter config |
| Yale Haskins | TTS quality standards | Phase D — Piper voice quality selection |
| MIT Fluid Interfaces | Cognitive augmentation | Phase B — Dashboard information density |
| Stanford HCI | Ambient displays | Phase B/G — Notification placement |

---

## ADHD Design Principles → AEON Mapping

| Principle | AEON Feature | Phase |
|-----------|-------------|-------|
| External working memory | Dashboard always shows state | B |
| Time visibility | Clock with seconds + Pomodoro | A, G |
| Immediate feedback | Action → visible result | All |
| Reduced decision fatigue | Pre-configured workflows | B, J |
| Dopamine scaffolding | Streaks, celebrations, progress | G, J |
| Hyperfocus protection | 90min break reminder | G |
| Context switching support | One-click task switching | B |

---

## Total Package Count Summary

| Category | Count |
|----------|-------|
| pacman packages | ~45 |
| AUR packages | ~15 |
| Flatpak apps | ~5 |
| pip packages | ~8 |
| Docker services | ~5 |
| Ollama models | 3 |
| GNOME Extensions | 4 |
| VS Code Extensions | 11 |
| **Total** | **~96 components** |
