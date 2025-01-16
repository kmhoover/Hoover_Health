Lets scan some shit and make a badass dashboard

Formatting Tasks:
- Make pages look nice
- Don't populate pages before first scan
- Have home page health scores updated based on side pages

Available Scans:
- Bluetooth
- Wifi
- OS information
- System information
- Processes
- Ports
- Running Processes
      - *Look into incorporating netstat or lsof to see network communication
          - I think I can pass pid into netstat to get connections which I can then call OTX api to see if its malicious

Health Scores
- Available:
    - Wifi
- Still need:
    - System
          - Is device fully updated?
          - Long uptime
    - Application
          - Contains verified bundle identifier
          - If new, make user confirm they installed/okay with it
      - Bluetooth
          - List of safe/expected devices

Scans I want
- Process run on startup
- User sessions
- Ports

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
- _Threat Intelligence_
    - Cross reference https://otx.alienvault.com/api
