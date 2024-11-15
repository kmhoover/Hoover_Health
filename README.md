Lets scan some shit and make a badass dashboard

Current OSQuery Scans:
commands = {
    "listening_ports": "SELECT pid, port, protocol FROM listening_ports;",
    "running_processes": "SELECT name, pid, path FROM processes;"
}

Back home work:
- Create list of safe users
    - cross reference when scanning
- Ports and Processes
    - cross reference list of potential malicious ports and list the pid/process name that is using it
    - allow uuser to create list of expected pids
    - check out current implementation in /osquery

Available Scans:
- Bluetooth
- Wifi
- OS information
- System information
- Processes
- Ports

Current Health Scores:
- N/A

Scans I want
- Process run on startup
- User sessions

Crazy Scans
- IP lookups
- Email lookups
- Darkweb?????

**Future Ideas**
- _Security checklist_
  - occasionally send reminders to complete checklist
  -  HaveIBeenPwnd has api that allows you to send the hash of the first part of your password and then return passwords that start with the same characters
    - I could also probably just attach a link to the website as that will allow the user to put in their email
  - Suggest user to encorporate password manager + 2FA reminders
  - Software Update Reminders
  - Backup Reminder
  - Review of whitelisted accounts, processes, bluetooth/wifi connections, etc.
  - Give user score based on checklist completion
- _Behavior Anomaly Detection_  
  - Usage Patternes
      - Analyze usage trenst (CPU usage by processes, network usage)
      - Flag abnormal spike
  - New Process Alerts
- _User Privacy Protection_
    - Network Privacy Check
        - Scan Wi-Fi for vulnerabilities (open networks/weak encryption)
    - Bluetooth Device Monitoring
        - Alerts if new Bluetooth device aattempts to connect
    - File Privacy Check
        - Alert if unexpected file access patterns
- _Threat Intelligence_
    - Cross reference https://otx.alienvault.com/api
