# FULLY AUTOMATED BUILD (ONE COMMAND)
**The entire AEON OS build (Phases A-K) runs automatically. Zero manual intervention.**

---

## TL;DR (Ultra-Quick Start)

```bash
# Boot SSD, apply nomodeset, then run this ONE command:

sudo cp ~/aeon-build/linux_scripts/aeon-master-build.service /etc/systemd/user/
systemctl --user daemon-reload
systemctl --user enable aeon-master-build.service
systemctl --user start aeon-master-build.service

# Monitor:
journalctl --user -f -u aeon-master-build.service

# Wait ~5-6 hours (go do something else!)
# System automatically reboots when done
```

---

## WHAT IS THIS?

The **Master Auto-Execute Service** runs ALL phases (A through K) sequentially:

- ✅ Phase A: Accessibility (20 min)
- ✅ Phase B: Dashboard (45 min)
- ✅ Phase C: Writing (20 min)
- ✅ Phase D: Podcast (30 min)
- ✅ Phase E: Publishing (30 min)
- ✅ Phase F: AI (45 min)
- ✅ Phase G: Notifications (30 min)
- ✅ Phase H: Safety (25 min)
- ✅ Phase I: Services (45 min)
- ✅ Phase J: Habits (30 min)
- ✅ Phase K: Packaging (45 min)

**Total: ~5 hours 15 minutes (fully automated)**

---

## SETUP (5 Minutes)

### Prerequisites: nomodeset Already Applied

Before starting, you MUST have:
1. ✅ Booted external SSD
2. ✅ Applied `nomodeset` to GRUB
3. ✅ Rebooted (nomodeset confirmed)
4. ✅ Verified: `cat /proc/cmdline | grep nomodeset`

If not done yet, see: **HANDS_OFF_PHASE_A_EXECUTION.md**

### Step 1: Install Master Service

```bash
# Open terminal (Ctrl+Alt+T)

# Copy service file:
sudo cp ~/aeon-build/linux_scripts/aeon-master-build.service /etc/systemd/user/

# Reload systemd:
systemctl --user daemon-reload

# Enable (runs on boot):
systemctl --user enable aeon-master-build.service

# Start now:
systemctl --user start aeon-master-build.service
```

### Step 2: Monitor Progress

```bash
# Watch the build in real-time:
journalctl --user -f -u aeon-master-build.service

# You'll see:
# [*] Starting: 01_phase_a_accessibility
# [✓] 01_phase_a_accessibility completed
# [*] Creating Timeshift snapshot: post-phase_a
# [*] Starting: 02_phase_b_dashboard
# ... (repeats for each phase)
# [✓] ALL PHASES COMPLETED SUCCESSFULLY!
```

### Step 3: Let It Work

- Grab coffee ☕
- Take a walk 🚶
- Read a book 📚
- **System will handle all 11 phases automatically**

---

## TIMELINE BREAKDOWN

| Phase | Task | Duration | Cumulative |
|-------|------|----------|-----------|
| A | Accessibility | 20 min | 20 min |
| B | Dashboard | 45 min | 65 min |
| C | Writing | 20 min | 85 min |
| D | Podcast | 30 min | 115 min |
| E | Publishing | 30 min | 145 min |
| F | AI | 45 min | 190 min |
| G | Notifications | 30 min | 220 min |
| H | Safety | 25 min | 245 min |
| I | Services | 45 min | 290 min |
| J | Habits | 30 min | 320 min |
| K | Packaging | 45 min | 365 min |
| **TOTAL** | | | **~5h 45min** |

---

## WHAT HAPPENS DURING BUILD

### Per-Phase Cycle:
1. **Load** phase script
2. **Execute** phase installation
3. **Log** output to file
4. **Create** Timeshift snapshot (for rollback)
5. **Wait** 3 seconds
6. **Move to next phase**

### Error Handling:
- ✅ If a phase fails, build continues to next phase
- ✅ All errors logged to `~/aeon-build/logs/`
- ✅ You can re-run failed phases manually later
- ✅ Snapshots let you rollback specific phases

### Logging:
```bash
# Master build log:
cat ~/aeon-build/logs/master_build_log.txt

# Individual phase logs:
cat ~/aeon-build/logs/01_phase_a_accessibility.log
cat ~/aeon-build/logs/02_phase_b_dashboard.log
# ... etc

# Completion markers (prove each phase ran):
ls ~/aeon-build/logs/*_complete.marker
```

---

## MONITORING WHILE BUILD RUNS

### Real-Time Progress

```bash
# Terminal 1: Watch system log
journalctl --user -f -u aeon-master-build.service

# Terminal 2 (optional): Check system resources
# Open Activities → System Monitor
# Watch CPU, RAM, disk usage
```

### Expected Behavior:

- **High CPU**: Phase installations (normal)
- **Network activity**: Package downloads (normal)
- **Disk activity**: Timeshift snapshots (normal)
- **GNOME may freeze briefly**: During heavy operations (normal)

### Signs of Progress:

- Timestamps in journal update every minute
- Log file grows: `ls -lh ~/aeon-build/logs/master_build_log.txt`
- Snapshots appear: `sudo timeshift --list`

---

## WHAT TO DO AFTER BUILD COMPLETES

### Verify Success (5 minutes)

```bash
# Check completion status:
systemctl --user status aeon-master-build.service
# Should show: Active: active (exited)

# Check completion marker:
ls -la ~/aeon-build/logs/build_complete.marker
# Should exist

# Review full build log:
tail -50 ~/aeon-build/logs/master_build_log.txt

# Check Timeshift snapshots:
sudo timeshift --list
# Should show 11 snapshots (one per phase)
```

### Reboot the System

```bash
# After verifying success, reboot:
sudo reboot

# After reboot, all phases should be active and configured
```

### First Boot After Build

After reboot, you'll have:
- ✅ Accessibility fonts, GNOME tweaks, extensions
- ✅ Dashboard with 10 action buttons on desktop
- ✅ Writing environment (Obsidian vault)
- ✅ Podcast tools (Audacity, Whisper)
- ✅ Publishing pipeline (Hugo)
- ✅ AI tools (Ollama, Open-WebUI)
- ✅ Notifications (Dunst system)
- ✅ Safety tools (Cockpit, Timeshift)
- ✅ Services (Docker containers)
- ✅ Habits tracker
- ✅ Custom ISO builder

---

## TROUBLESHOOTING

### Problem: "Master service won't start"

```bash
# Check for errors:
journalctl --user -xe | grep aeon-master

# Verify service file exists:
ls -la /etc/systemd/user/aeon-master-build.service

# Try manual execution:
~/aeon-build/linux_scripts/99_master_auto_execute.sh
```

### Problem: "Phase X failed, rest stopped"

If master build stops after a phase failure:

```bash
# Check which phases failed:
cat ~/aeon-build/logs/master_build_log.txt | grep "\[✗\]"

# Manual re-run of failed phase:
cd ~/aeon-build
./[PHASE_NUMBER]_phase_[NAME].sh

# Restart master build from next phase (edit script to skip completed phases)
```

### Problem: "Build taking longer than expected"

- **Normal**: Large package downloads = slower
- **Check**: `journalctl --user -f -u aeon-master-build.service`
- **Verify**: Internet connection is stable
- **Don't stop**: systemd timeout is set to 7 hours

### Problem: "System ran out of disk space"

```bash
# Check available space:
df -h /

# If full, run Timeshift cleanup:
sudo timeshift --delete-all-snapshots
# Then restart build

# Or: Use external SSD's full capacity (likely hundreds of GB available)
```

---

## MANUAL ALTERNATIVE (If Auto-Execution Fails)

If you prefer to run phases manually:

```bash
# Execute each phase in order:
cd ~/aeon-build

./01_phase_a_accessibility.sh
./02_phase_b_dashboard.sh
./03_phase_c_writing.sh
./04_phase_d_podcast.sh
./05_phase_e_publishing.sh
./06_phase_f_ai.sh
./07_phase_g_notifications.sh
./08_phase_h_safety.sh
./09_phase_i_services.sh
./10_phase_j_habits.sh
./11_phase_k_packaging.sh

# After each phase, take snapshot:
# sudo timeshift --create --comments "post-phase-[name]"
```

---

## DISABLE AUTO-EXECUTION (If Needed)

If you want to run phases manually or stop auto-execution:

```bash
# Disable service:
systemctl --user disable aeon-master-build.service

# Stop currently running:
systemctl --user stop aeon-master-build.service

# Remove:
sudo rm /etc/systemd/user/aeon-master-build.service
systemctl --user daemon-reload
```

---

## ADVANCED: CUSTOMIZE BUILD

To skip certain phases or modify execution:

```bash
# Edit master script:
nano ~/aeon-build/linux_scripts/99_master_auto_execute.sh

# Comment out phases you don't want:
# Example (skip Phase K - Packaging):
# "11_phase_k_packaging"  # <- Add # at start

# Save and restart:
systemctl --user restart aeon-master-build.service
```

---

## FINAL NOTES

✅ **Fully automated**: Zero manual steps during 5-hour build  
✅ **Safe**: Timeshift snapshots after each phase allow rollback  
✅ **Resilient**: Phases continue even if one fails  
✅ **Logged**: Every action recorded for debugging  
✅ **Recoverable**: Can re-run phases manually if needed  

**Total active time: ~5 minutes (setup)**  
**Total hands-off time: ~5 hours 45 minutes**

---

## NEXT STEPS AFTER FULL BUILD

1. Reboot system
2. Test dashboard (10 buttons on desktop)
3. Open Obsidian vault (~/aeon-build/vault/)
4. Launch Audacity and test audio recording
5. Check Ollama (Open-WebUI on localhost:3000)
6. Verify Docker services (Nextcloud, SearXNG, Ghost)
7. Explore all installed applications

**Enjoy your fully automated AEON OS! 🚀**

---

**Ready? Follow the TL;DR section above. Then wait ~5-6 hours.**

