# INSTALL AUTO-EXECUTION SERVICE (After applying nomodeset)
**This enables Phase A to run automatically after reboot with nomodeset applied**

---

## Quick Install (One-Time Setup)

After you apply nomodeset and reboot EndeavourOS:

```bash
# Copy systemd service file
sudo cp ~/aeon-build/linux_scripts/aeon-phase-a.service /etc/systemd/user/

# Reload systemd
systemctl --user daemon-reload

# Enable the service
systemctl --user enable aeon-phase-a.service

# Start immediately (optional - will also run on next boot)
systemctl --user start aeon-phase-a.service

# Monitor progress
journalctl --user -f -u aeon-phase-a.service
```

---

## What This Does

1. **Waits for graphical session** to be ready (GNOME desktop fully loaded)
2. **Verifies nomodeset** is in kernel parameters (safety check)
3. **Executes Phase A script** automatically
4. **Logs everything** to `~/aeon-build/logs/phase_a_auto_execute.log`
5. **Creates completion marker** when done (`phase_a_complete.marker`)

---

## Monitor Execution

### In Real-Time
```bash
# Watch Phase A run live:
journalctl --user -f -u aeon-phase-a.service
```

### After Completion
```bash
# View full log:
cat ~/aeon-build/logs/phase_a_auto_execute.log

# Check completion:
ls -la ~/aeon-build/logs/phase_a_complete.marker
```

---

## Timeline

| Step | Duration |
|------|----------|
| Apply nomodeset in GRUB | 5 min |
| Rebuild GRUB config | 2 min |
| Reboot | 2 min |
| GNOME startup | 3 min |
| **Phase A auto-execution starts** | **~20 min** |
| **Total** | **~32 min** |

---

## Disable/Uninstall

If you need to stop auto-execution:

```bash
# Disable (service won't run on next boot)
systemctl --user disable aeon-phase-a.service

# Stop currently running
systemctl --user stop aeon-phase-a.service

# Remove file
sudo rm /etc/systemd/user/aeon-phase-a.service
systemctl --user daemon-reload
```

---

## Manual Execution (Alternative)

If you prefer to run Phase A manually instead:

```bash
cd ~/aeon-build
./01_phase_a_accessibility.sh
```

---

## Troubleshooting

**Phase A doesn't start on boot:**
- Check: `systemctl --user status aeon-phase-a.service`
- Verify service installed: `systemctl --user list-unit-files | grep aeon`
- Check logs: `journalctl --user -xe`

**Phase A fails during execution:**
- View log: `cat ~/aeon-build/logs/phase_a_auto_execute.log`
- Run manually to debug: `./01_phase_a_accessibility.sh`

**nomodeset not detected:**
- Verify GRUB edit: `grep CMDLINE_LINUX_DEFAULT /etc/default/grub | grep nomodeset`
- Rebuild: `sudo grub-mkconfig -o /boot/grub/grub.cfg`
- Reboot and try again

---

## NEXT STEPS

1. Boot external SSD
2. Apply nomodeset to GRUB (see PHASE_A_WITH_NOMODESET.md)
3. Reboot
4. Install this service (commands above)
5. **Phase A runs automatically**
6. Phase B onwards: Manual execution or create similar services

---

**After Phase A completes, move to Phase B (Dashboard).**
