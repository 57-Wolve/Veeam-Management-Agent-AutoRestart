# Veeam-Management-Agent-AutoRestart

I created a PowerShell script to restart the Veeam Management Agent Nightly.
We have been logging into servers to fix our Backup Radar "No Result" tickets. Most often after doing Cloud Connect upgrades causing the MA to die.

The Veeam Management Agent is what allows the Veeam B&R server to talk with the Veeam Service Provider Consolle. Without it we have no reporting for license usage and backup job monitoring. It also allows us to push/update licenses to Customer's Veeam B&R servers.

Run this command in PowerShell as Admin to create the script and restart task.

`irm https://raw.githubusercontent.com/57-Wolve/Veeam-Management-Agent-AutoRestart/refs/heads/main/RestartVeeamMAServiceNightly.ps1 | iex`


__This is Veaam's own recommendation__ to fix the Management Agent not showing online for Service Providers after a year of dealing with this bug.
