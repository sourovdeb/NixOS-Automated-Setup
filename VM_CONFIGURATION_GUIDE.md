# VM CONFIGURATION GUIDE
**EndeavourOS-Fresh VM is running - configure it now**

---

## CURRENT STATUS
✅ VM Created: EndeavourOS-Fresh  
✅ VM Started: Running in VirtualBox GUI  
✅ SSH Port: 2222 (host) → 22 (guest)  
✅ Monitoring: Active (3-minute reviews)  
⏳ Next Review: 09:38:13  

---

## OPTION 1: ATTACH ENDEAVOUROS ISO

### Download ISO manually:
1. **Open browser** → https://endeavouros.com/download/
2. **Download** EndeavourOS ISO (~2GB)
3. **Save to**: `C:\Users\souro\Desktop\Arch_Linus\`

### Attach ISO to VM:
1. **VirtualBox window is open** (EndeavourOS-Fresh)
2. **Devices** menu → **Optical Drives** → **Choose/Create a Virtual Optical Disk**
3. **Add** → Navigate to downloaded ISO
4. **Select ISO** → **Choose** → **Mount**
5. **Reset VM**: Machine menu → Reset

### Install EndeavourOS:
1. **Boot from ISO** (should happen automatically after reset)
2. **Install**: Online installer recommended
3. **User**: `sourou` (password of your choice)
4. **Enable**: "Log in automatically" OR remember password
5. **Partition**: Use entire disk (50GB)
6. **Wait**: 15-20 minutes for installation

---

## OPTION 2: USE EXISTING SSD IN VM

### Mount SSD to VM:
1. **VirtualBox** → **EndeavourOS-Fresh** → **Settings**
2. **Storage** → **SATA Controller**
3. **Add Disk** → **Use existing disk**
4. **Browse**: Find your external SSD (if detectable)
5. **Boot from SSD** instead of creating new installation

---

## OPTION 3: NETWORK/PXE BOOT (Advanced)

VM will attempt network boot - configure if you have PXE server

---

## AFTER OS IS RUNNING

### Enable SSH in VM:
```bash
# In VM terminal:
sudo systemctl enable --now ssh
sudo systemctl status ssh

# Check IP (usually 10.0.2.15):
ip addr show

# Allow SSH through firewall:
sudo ufw allow ssh
```

### Test SSH from Windows:
```powershell
# Test connection:
ssh -p 2222 sourou@127.0.0.1

# If successful, deploy Aeon build:
scp -P 2222 -r linux_scripts sourou@127.0.0.1:~/aeon-build/
```

---

## MONITORING WILL DETECT

The 3-minute monitoring is checking:
- **Port 2222**: VM SSH service
- **Port 22**: SSD SSH service (if booted separately)

When VM SSH responds:
```
✅ VM SSH: RESPONDING
🎉 VM SSH IS READY!
   Connect with: ssh -p 2222 sourou@127.0.0.1
```

---

## CURRENT RECOMMENDED ACTION

**Choose your preferred method:**
1. ✅ **Easiest**: Download ISO, attach to VM, install EndeavourOS
2. ⚡ **Fastest**: Boot external SSD from BIOS (F12 → UEFI: [JMicron USB SSD])

**Monitoring continues automatically every 3 minutes.**
**Next review: 09:38:13**

---

## TROUBLESHOOTING

**VM won't start**: Check VirtualBox logs in VM settings  
**No network in VM**: Should get IP automatically (NAT)  
**SSH not working**: Verify `sudo systemctl enable --now ssh` in VM  
**Can't connect**: Verify SSH port 2222 is mapped correctly  

**VM is ready - configure EndeavourOS installation now.**