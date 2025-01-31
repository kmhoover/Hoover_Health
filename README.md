Welcome to my system monitoring tool!
- I have taken inspiration from osquery to develop scans in C to pull system, wifi, and application information
- I then display the information using Flutter and encorporate Dart to allow the user to interact with the application
- The user can see a score related to each scan based on various factors:
  Wifi
      - Wifi stength
      - Wifi encruption
  System
      - Is the device fully up to date?
  Application
      - Are the applications signed by a trusted source
      - User can mark unknown applications as suspicious for further investigation


Health Scores
- Available:
    - Wifi
    - System
    - Application



Scans I want
- Process run on startup
- User sessions
- Ports

Crazy Scans
- IP lookups
- Email lookups
- Darkweb?????
- nmap??

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
    - Look into incorporating netstat or lsof to see network communication
          - I think I can pass pid into netstat to get connections which I can then call OTX api to see if its malicious
