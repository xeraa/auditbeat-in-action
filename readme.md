# Auditd in Action


## Demo

1. See the output of `sudo aureport` and the underlying log */var/log/audit/audit.log*. Also point to the rules in */etc/audit/audit.rules*.
1. Show the dashboard *[Filebeat Auditd] Audit Events* from the Filebeat module.
1. Show the Auditbeat configuration and the raw data in the Discover tab (also point out the `host` and `meta.cloud` data).
1. Show the *[Auditbeat Auditd] Overview* dashboard.
1. `ssh elastic-user@xeraa.wtf` with a bad password and show the failed login on the *SSH logins* dashboard.
1. SSH with the same user and make it work this time. Run `service nginx restart` and then try to log in as a different user. Show the failed execution on the *[Auditbeat Auditd] Executions* dashboard.
1. Log read access on */etc/passwd* from a selected user (check the group with `id elastic-user`). Run it with `cat /etc/passwd` and find the entry in the Discover tab and filter for `tags is developers-passwd-read`.
1. Detect when an admin may be abusing power by looking in a user's home directory. Let the `ssh elastic-admin@xeraa.wtf` check the directory */home/elastic-user* and read the file */home/elastic-user/secret.txt* (will require sudo). Search for the tag `power-abuse` to see the violation.
1. Change the content of the website. See the change in the *[Auditbeat File Integrity] Overview* dashboard.
1. Show additional dashboards
  * *New users and groups*
  * *Sudo commands*
