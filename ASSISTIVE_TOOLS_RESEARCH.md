# AEON Writer OS — Assistive Technology & Tools Research
> Compiled: 2026-04-20 | For: Custom EndeavourOS build for neurodivergent writer/podcaster

---

## 1. MIT Assistive Technology Tools

### MIT Media Lab — Affective Computing Group
| Name | URL | Open Source | Linux | AEON Relevance |
|------|-----|-------------|-------|----------------|
| **Affective Computing Group** | https://www.media.mit.edu/groups/affective-computing/overview/ | Research (mixed) | N/A | Emotion AI research for wellbeing; conceptual basis for AEON's adaptive UI |
| **BeWell Biomarkers** | https://www.media.mit.edu/projects/bewell-biomarkers/ | Research | N/A | Objective biomarkers for depression/wellbeing; future integration concept |
| **Mind Mapper** | https://www.media.mit.edu/projects/mind-mapper/ | Research | N/A | Adaptive AI that understands how you think — directly relevant to ADHD/autism cognitive support |
| **NeuroChat** | https://www.media.mit.edu/projects/neurochat/ | Research (paper open access) | N/A | Neuroadaptive AI tutor combining LLM + EEG; model for AEON's adaptive assistant |
| **Fluid Interfaces Group** | https://www.media.mit.edu/groups/fluid-interfaces/overview/ | Research | N/A | HCI research on cognition augmentation; foundational for AEON design philosophy |

### MIT-Connected Open Source Projects
| Name | URL | Open Source | Linux | AEON Relevance |
|------|-----|-------------|-------|----------------|
| **Morphic** (Raising the Floor, MIT-connected) | https://morphic.org | Yes (open source) | Windows/Mac only currently | Accessibility toolbar; discover/use built-in a11y features. Model for AEON's accessibility launcher |
| **Raising the Floor — Learn and Try** | https://preview.learnandtry.org | Yes | Web-based | Directory of built-in accessibility features & AT tools; reference for AEON feature curation |
| **Scratch (MIT Lifelong Kindergarten)** | https://scratch.mit.edu | Yes (BSD) | Yes (web) | Relevant for cognitive accessibility design patterns — block-based, visual programming |

> **Note:** Affectiva (emotion recognition) spun out of MIT in 2009, now owned by Smart Eye. Not open source. Not directly usable for AEON.

---

## 2. Stanford Assistive/Design Tools

### Stanford d.school Resources
| Name | URL | Open Source | Linux | AEON Relevance |
|------|-----|-------------|-------|----------------|
| **d.school Design Tools Library** | https://dschool.stanford.edu/resources | Free (not software) | N/A | Design thinking frameworks — "Liberatory Design", "Getting Unstuck", "Emotional Journey Map" applicable to designing for neurodivergent UX |
| **Liberatory Design** | https://dschool.stanford.edu/tools/liberatory-design | Free resource | N/A | Mindsets/modes for designing for equity — applicable to accessibility-first design |
| **Library of Ambiguity** | https://dschool.stanford.edu/tools/library-of-ambiguity | Free resource | N/A | Navigating ambiguity — relevant to ADHD executive function support design |

### Stanford HCI Group
| Name | URL | Open Source | Linux | AEON Relevance |
|------|-----|-------------|-------|----------------|
| **Stanford HCI Group** | https://hci.stanford.edu | Research | N/A | Research on human-computer interaction; papers on accessibility, but no downloadable tools for direct inclusion |

> **Note:** Stanford's primary contributions are design frameworks and research papers, not installable Linux tools. Their design principles should inform AEON's UX philosophy.

---

## 3. Yale Assistive Tools

### Yale Center for Dyslexia & Creativity
| Name | URL | Open Source | Linux | AEON Relevance |
|------|-----|-------------|-------|----------------|
| **Yale Dyslexia Tools & Technology** | https://dyslexia.yale.edu/resources/tools-technology/ | Free guides | N/A | Recommends: Dragon NaturallySpeaking, Read&Write Gold, Livescribe — mostly proprietary/Windows. Useful as a reference for feature requirements |
| **Read & Write Gold** (recommended by Yale) | https://dyslexia.yale.edu/resources/tools-technology/tech-tips/ | Proprietary | No | Text-to-speech, predictive spelling, word choice — AEON should replicate these features with open alternatives |

### Yale Haskins Laboratories
| Name | URL | Open Source | Linux | AEON Relevance |
|------|-----|-------------|-------|----------------|
| **Haskins Laboratories** | https://haskins.yale.edu | Research | N/A | Foundational research on reading/speech science; no downloadable tools but informs speech-to-text/TTS feature choices |

> **Note:** Yale's tools are primarily guides and proprietary software recommendations. AEON should use open-source equivalents (espeak-ng, Festival, Orca) to replicate the functionality Yale recommends.

---

## 4. MATE Desktop Accessibility Features

| Feature | Details | AEON Relevance |
|---------|---------|----------------|
| **AccessX (Sticky Keys)** | Built into mate-settings-daemon; keyboard accessibility (sticky keys, slow keys, bounce keys, toggle keys) | Essential for motor accessibility; enable by default in AEON |
| **High Contrast Themes** | Built-in high contrast themes (HighContrast, HighContrastInverse) | Include and make easily toggleable for visual needs |
| **Screen Reader Support** | Works with **Orca** (GNOME screen reader) via AT-SPI2 | Install Orca + at-spi2-core; enable AT-SPI bridge |
| **Magnification** | Supported via **Magnus** (screen magnifier) or Compiz zoom plugin | Install Magnus; add keyboard shortcut for zoom |
| **Keyboard Navigation** | Full keyboard navigation of panels, menus, desktop | Already built-in; document for users |
| **Large Text / Font Scaling** | Configurable in mate-appearance-properties + Display dialog (display scaling added in 1.26) | Expose prominently in AEON settings |
| **CapsLock Bell** | a11y-keyboard: bell when CapsLock active (added 1.26) | Useful for ADHD users who accidentally enable CapsLock |
| **Do Not Disturb** | Notification daemon supports DND mode (added 1.24+) | Critical for ADHD focus sessions |
| **Pluma Text Editor** | Mini map, grid background, bracket completion, plugins | Built-in writer-friendly text editor |

### Key MATE Accessibility Packages for AEON
```
orca, at-spi2-core, at-spi2-atk, magnus, mate-settings-daemon, 
mate-control-center, mate-applets (AccessX applet - X11 only)
```

---

## 5. ADHD-Specific Productivity Tools

| Name | URL | Open Source | Linux | AEON Relevance |
|------|-----|-------------|-------|----------------|
| **Focus Timer** (formerly GNOME Pomodoro) | https://gnomepomodoro.org / https://github.com/focustimerhq/FocusTimer | Yes (GPL-3.0) | Yes (Flatpak, Arch AUR) | Pomodoro timer with GNOME integration, break reminders, screen overlay, statistics. **Must-have for AEON** |
| **Super Productivity** | https://github.com/super-productivity/super-productivity | Yes (MIT) | Yes (Flatpak, Snap, AppImage) | Task manager with Pomodoro, time tracking, break reminders, anti-procrastination feature. **Top pick for AEON** |
| **Espanso** | https://espanso.org | Yes (GPL-3.0) | Yes (native) | Text expander — reduces repetitive typing; templates for common phrases. Excellent for writers with ADHD |
| **Blanket** | https://github.com/rafaelmardojai/blanket | Yes (GPL-3.0) | Yes (Flatpak) | Ambient sounds for focus (rain, coffee shop, etc.). Helpful for ADHD sensory regulation |
| **Solanum** | https://gitlab.gnome.org/World/Solanum | Yes (GPL-3.0) | Yes (Flatpak) | Simple, clean Pomodoro timer for GNOME. Minimal UI, less overwhelming than alternatives |
| **Todoist** (or **Tasks.org**) | https://github.com/niceboard/tasks | Varies | Yes | Task management; for AEON prefer open-source alternatives |
| **Timeshift** | https://github.com/linuxmint/timeshift | Yes (GPL) | Yes | Not ADHD-specific, but system snapshots prevent "I broke everything" anxiety |

---

## 6. Autism-Friendly UI/UX Design Patterns

| Principle | Implementation in AEON |
|-----------|----------------------|
| **Reduced sensory overload** | Muted color palettes, no animations by default, `prefers-reduced-motion` respected, minimal notification sounds |
| **Predictable navigation** | Consistent menu placement, no surprise popups, same keyboard shortcuts everywhere, no UI rearrangement on updates |
| **Clear visual hierarchy** | High contrast between text and background, clear section delineation, generous whitespace |
| **Minimal cognitive load** | One task visible at a time (focus mode), clear labeling with no ambiguous icons, step-by-step wizards |
| **Customizable sensory environment** | Dark/light/high-contrast theme switching, adjustable font sizes, configurable notification behavior (visual vs audio vs both) |
| **Consistent feedback** | Every action has clear visual confirmation, undo is always available, no irreversible actions without confirmation |
| **Text alternatives** | All icons have text labels, no icon-only buttons in critical workflows |
| **Quiet mode** | System-wide DND toggle, suppress non-critical notifications during focus time |
| **Routine support** | Startup sequence always the same, session restoration, predictable workspace layout |

### Relevant Tools for Implementation
| Name | URL | Open Source | Linux | Purpose |
|------|-----|-------------|-------|---------|
| **GTK Theme: Materia / Arc** | https://github.com/nana-4/materia-theme | Yes | Yes | Clean, predictable GTK themes with good contrast |
| **Papirus Icon Theme** | https://github.com/PapirusDevelopmentTeam/papirus-icon-theme | Yes (GPL-3.0) | Yes | Clear, consistent, recognizable icons |
| **redshift / gammastep** | https://github.com/jonls/redshift / https://gitlab.com/chinstrap/gammastep | Yes (GPL) | Yes | Blue light filter; sensory regulation, especially for evening use |

---

## 7. Writer-Specific Tools (Open Source)

### Distraction-Free Writing
| Name | URL | Open Source | Linux | AEON Relevance |
|------|-----|-------------|-------|----------------|
| **FocusWriter** | https://gottcode.org/focuswriter/ | Yes (GPL-3.0) | Yes (native, Flatpak) | Distraction-free writing with customizable themes, daily goals, timers, sessions. **Primary writing tool for AEON** |
| **ghostwriter** (KDE) | https://ghostwriter.kde.org | Yes (GPL-3.0) | Yes (Flatpak, native) | Markdown editor with live preview, focus mode, hemingway mode, theming. **Strong alternative** |
| **Zettlr** | https://www.zettlr.com | Yes (GPL-3.0) | Yes (AppImage, deb, Flatpak) | Academic writing with Zettelkasten, citations, Zotero integration, dark mode |
| **novelWriter** | https://novelwriter.io | Yes (GPL-3.0) | Yes (Python, Flatpak) | Novel-focused writing tool with Markdown-like syntax, project management, character/plot tracking |
| **Pluma** (MATE built-in) | https://github.com/mate-desktop/pluma | Yes (GPL-2.0) | Yes (native) | Already in MATE; with plugins becomes a capable writing environment |
| **Manuskript** | https://www.theologeek.ch/manuskript/ | Yes (GPL-3.0) | Yes (Python) | Outlining, character sheets, world-building — for long-form fiction |

### Text-to-Speech / Speech-to-Text
| Name | URL | Open Source | Linux | AEON Relevance |
|------|-----|-------------|-------|----------------|
| **espeak-ng** | https://github.com/espeak-ng/espeak-ng | Yes (GPL-3.0) | Yes | TTS engine — lightweight, many languages. Can read documents aloud |
| **Festival** | http://www.cstr.ed.ac.uk/projects/festival/ | Yes (BSD-like) | Yes | Speech synthesis system — higher quality voices |
| **Piper** | https://github.com/rhasspy/piper | Yes (MIT) | Yes | Neural TTS — high-quality local voice synthesis. **Best quality TTS for AEON** |
| **Whisper.cpp** | https://github.com/ggml-org/whisper.cpp | Yes (MIT) | Yes | Local speech-to-text using OpenAI's Whisper model. **Best STT for AEON** |
| **Nerd Dictation** | https://github.com/ideasman42/nerd-dictation | Yes (GPL-3.0) | Yes | Offline voice dictation using Vosk. Lightweight, keyboard-driven |
| **Vosk** | https://alphacephei.com/vosk/ | Yes (Apache-2.0) | Yes | Offline speech recognition toolkit — small models, many languages |

### Grammar/Readability Checkers
| Name | URL | Open Source | Linux | AEON Relevance |
|------|-----|-------------|-------|----------------|
| **LanguageTool** | https://languagetool.org | Yes (LGPL-2.1) | Yes (Java, self-hosted) | Grammar/style checker, runs locally. **Primary grammar tool for AEON** |
| **Vale** | https://vale.sh | Yes (MIT) | Yes | Prose linter — configurable style rules, readability scores |
| **proselint** | https://github.com/amperser/proselint | Yes (BSD) | Yes (Python) | Writing style linter — flags jargon, clichés, redundancy |
| **write-good** | https://github.com/btford/write-good | Yes (MIT) | Yes (Node.js) | Naive linter for English prose |
| **Hemingway Editor** concept → **ghostwriter's Hemingway mode** | Built into ghostwriter | Yes | Yes | Highlights complex sentences, passive voice |

---

## 8. Podcasting Tools (Linux Compatible)

### Audio Recording & Editing
| Name | URL | Open Source | Linux | AEON Relevance |
|------|-----|-------------|-------|----------------|
| **Audacity** | https://www.audacityteam.org | Yes (GPL-3.0) | Yes (native, Flatpak) | Industry standard audio editor. Record, edit, mix. **Primary podcast editor for AEON** |
| **Ardour** | https://ardour.org | Yes (GPL-2.0) | Yes (native) | Professional DAW — multitrack recording, mixing, mastering. For advanced podcasting |
| **OBS Studio** | https://obsproject.com | Yes (GPL-2.0) | Yes | Screen/audio recording, streaming — useful for video podcasts |
| **Tenacity** | https://codeberg.org/tenacity/tenacity | Yes (GPL-3.0) | Yes | Audacity fork with privacy focus (no telemetry) |

### Noise Reduction & Voice Enhancement
| Name | URL | Open Source | Linux | AEON Relevance |
|------|-----|-------------|-------|----------------|
| **RNNoise** | https://github.com/xiph/rnnoise | Yes (BSD) | Yes | Neural network noise suppression — integrates with PulseAudio/PipeWire |
| **NoiseTorch** | https://github.com/noisetorch/NoiseTorch | Yes (GPL-3.0) | Yes | Easy real-time noise suppression for PulseAudio. One-click setup |
| **EasyEffects** (PipeWire) | https://github.com/wwmm/easyeffects | Yes (GPL-3.0) | Yes | Audio effects for PipeWire — noise gate, compressor, EQ, limiter. **Essential for AEON podcasting** |
| **Calf Studio Gear** | https://calf-studio-gear.org | Yes (GPL/LGPL) | Yes | LV2 plugins — compressor, EQ, reverb for Ardour/JACK |

### Podcast Hosting & RSS
| Name | URL | Open Source | Linux | AEON Relevance |
|------|-----|-------------|-------|----------------|
| **Castopod** | https://castopod.org | Yes (AGPL-3.0) | Yes (self-hosted, PHP) | Self-hosted podcast hosting with built-in RSS, analytics, social features |
| **Podlove Publisher** | https://podlove.org/podlove-publisher/ | Yes (MIT) | Yes (WordPress plugin) | Podcast publishing for WordPress — feeds, chapters, transcripts |
| **AntennaPod** | https://antennapod.org | Yes (GPL-3.0) | Android only | Podcast player (for listening/testing your own feed) |
| **gPodder** | https://gpodder.github.io | Yes (GPL-3.0) | Yes | Podcast manager/downloader — manage subscriptions, download episodes |
| **Custom RSS** | Use `python-feedgen` or hand-crafted XML | Yes | Yes | Generate podcast RSS feeds programmatically |

---

## 9. Auto-Assistant / AI Assistant Tools (Linux)

### Local LLM Runners
| Name | URL | Open Source | Linux | AEON Relevance |
|------|-----|-------------|-------|----------------|
| **Ollama** | https://ollama.com | Yes (MIT) | Yes | Easiest way to run local LLMs. CLI + API. Supports Llama, Mistral, Gemma, etc. **Primary AI backend for AEON** |
| **llama.cpp** | https://github.com/ggml-org/llama.cpp | Yes (MIT) | Yes | Low-level LLM inference — C/C++, very efficient. Powers many front-ends |
| **LocalAI** | https://github.com/mudler/LocalAI | Yes (MIT) | Yes | OpenAI-compatible local API — drop-in replacement for OpenAI APIs |
| **Jan** | https://jan.ai | Yes (AGPL-3.0) | Yes (AppImage) | Desktop app for running local LLMs with GUI. User-friendly |
| **GPT4All** | https://gpt4all.io | Yes (MIT) | Yes | Desktop LLM runner with GUI, model download manager |
| **Open WebUI** | https://github.com/open-webui/open-webui | Yes (MIT) | Yes (Docker/native) | ChatGPT-like web UI for local LLMs via Ollama. **Best UI for AEON AI assistant** |

### Voice Assistant Frameworks
| Name | URL | Open Source | Linux | AEON Relevance |
|------|-----|-------------|-------|----------------|
| **Mycroft / OVOS (Open Voice OS)** | https://openvoiceos.org | Yes (Apache-2.0) | Yes | Open-source voice assistant — wake word, STT, TTS, skills. Successor to Mycroft |
| **Rhasspy** | https://rhasspy.readthedocs.io | Yes (MIT) | Yes | Offline voice assistant toolkit — works with Piper TTS + Vosk STT |
| **Whisper.cpp + Piper** (custom pipeline) | See above | Yes | Yes | Build custom voice assistant: Whisper for STT → Ollama for LLM → Piper for TTS |

### Automation Tools
| Name | URL | Open Source | Linux | AEON Relevance |
|------|-----|-------------|-------|----------------|
| **AutoKey** | https://github.com/autokey/autokey | Yes (GPL-3.0) | Yes (X11 only) | Desktop automation — text expansion, hotkeys, scripting. **Note: X11 only, won't work on Wayland** |
| **xdotool** | https://github.com/jordansissel/xdotool | Yes (BSD) | Yes (X11 only) | Simulate keyboard/mouse input — automation scripting |
| **ydotool** | https://github.com/ReimuNotMoe/ydotool | Yes (AGPL-3.0) | Yes (X11 + Wayland) | Wayland-compatible alternative to xdotool. **Prefer for AEON** |
| **Espanso** | https://espanso.org | Yes (GPL-3.0) | Yes (X11 + Wayland) | Cross-platform text expander — works everywhere. **Already listed in ADHD tools** |
| **Automate (cron + systemd timers)** | Built-in | Yes | Yes | Schedule tasks, backups, reminders via system tools |
| **Ulauncher** | https://ulauncher.io | Yes (GPL-3.0) | Yes | App launcher with extensions — quick access to anything, reduces executive function demand |

---

## Summary: Top Picks for AEON Writer OS

### Must-Install Packages (Tier 1)
| Category | Tool | Why |
|----------|------|-----|
| Writing | **FocusWriter** | Distraction-free, customizable, daily goals |
| Writing Alt | **ghostwriter** | Markdown + Hemingway mode + focus mode |
| Task Management | **Super Productivity** | ADHD-friendly: Pomodoro, time tracking, break reminders |
| Pomodoro | **Focus Timer** | GNOME Pomodoro with screen overlay during breaks |
| Grammar | **LanguageTool** | Local grammar/style checking |
| Text-to-Speech | **Piper** | High-quality neural TTS, fully offline |
| Speech-to-Text | **Whisper.cpp** or **Nerd Dictation** | Offline voice dictation |
| Text Expansion | **Espanso** | Reduce repetitive typing |
| Podcast Editing | **Audacity** | Standard audio editor |
| Audio Enhancement | **EasyEffects** | Noise reduction, compression, EQ for PipeWire |
| AI Assistant | **Ollama** + **Open WebUI** | Local LLM for writing assistance |
| Accessibility | **Orca** + **Magnus** | Screen reader + magnifier |
| Focus Sounds | **Blanket** | Ambient noise for concentration |
| Blue Light | **gammastep** | Reduce eye strain, regulate circadian rhythm |
| Launcher | **Ulauncher** | Quick access, reduces cognitive overhead |
| Theme | **Materia/Arc** + **Papirus** | Clean, predictable, high-contrast UI |

### Must-Enable MATE Settings
- Sticky Keys (for accessibility)
- Large cursor option
- Do Not Disturb toggle (panel applet)
- Display scaling (if HiDPI)
- Keyboard accessibility (bounce keys, slow keys available)
- CapsLock bell notification

---

*End of research document. All tools verified for Linux compatibility where noted.*
