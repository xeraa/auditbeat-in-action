# Auditd in Action



## Features

1. See the output of `sudo aureport` and the underlying log */var/log/audit/audit.log*. Also point to the rules in */etc/audit/audit.rules*.
1. Show the dashboard *[Filebeat Auditd] Audit Events* and show additional Filebeat modules:
  * *[Filebeat System] New users and groups*
  * *[Filebeat System] Sudo commands*
  * *[Osquery Result] Compliance pack* (pick a long enough time range to get all the data)
1. Show the Auditbeat configuration and the raw data in the Discover tab (also point out the `host` and `meta.cloud` data).
1. Show the *[Auditbeat Auditd] Overview* dashboard.
1. `ssh elastic-user@xeraa.wtf` with a bad password and show the failed login on the *[Filebeat System] SSH login attempts* dashboard.
1. SSH with the same user and make it work this time. Run `service nginx restart` and pick the `elastic-admin` user to run the command. Show the execution on the *[Auditbeat Auditd] Executions* dashboard by filtering down to the `elastic-user` user.
1. Run it with `cat /etc/passwd` and find the event in the Discover tab and filter for `tags is developers-passwd-read` (check the group with `id elastic-user`).
1. Detect when an admin may be abusing power by looking in a user's home directory. Let the `ssh elastic-admin@xeraa.wtf` check the directory */home/elastic-user* and read the file */home/elastic-user/secret.txt* (will require sudo). Search for the tag `power-abuse` to see the violation.
1. Change the content of the website in `/var/www/html/index.html`. See the change in the *[Auditbeat File Integrity] Overview* dashboard.



## Setup

Make sure you have run this before the demo.

1. Have your AWS account set up, access key created, and added as environment variables in `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`. Protip: Use [https://github.com/sorah/envchain](https://github.com/sorah/envchain) to keep your environment variables safe.
1. Create the Elastic Cloud instance with the same version as specified in *variables.yml*'s `elastic_version`, enable Kibana as well as the GeoIP & user agent plugins, and set the environment variables with the values for `ELASTICSEARCH_HOST`, `ELASTICSEARCH_USER`, `ELASTICSEARCH_PASSWORD`, as well as `KIBANA_HOST`, `KIBANA_ID`.
1. Change the settings to a domain you have registered under Route53 in *inventory*, *variables.tf*, and *variables.yml*. Set the Hosted Zone for that domain and export the Zone ID under the environment variable `TF_VAR_zone_id`. If you haven't created the Hosted Zone yet, you should set it up in the AWS Console first and then set the environment variable.
1. If you haven't installed the AWS plugin for Terraform, get it with `terraform init` first. Then create the keypair, DNS settings, and instances with `terraform apply`.
1. Open HTTPS on the network configuration (waiting for this [Terraform issue](https://github.com/terraform-providers/terraform-provider-aws/issues/700)).
1. Apply the configuration to the instance with `ansible-playbook configure.yml`.

When you are done, remove the instances, DNS settings, and key with `terraform destroy`.



## Todo

* Socket example; maybe chat with `netcat -l 1024` and `telnet localhost 1024`?