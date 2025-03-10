---
table_display_block: true
---

# Application settings API

These API calls allow you to read and modify GitLab instance
[application settings](#list-of-settings-that-can-be-accessed-via-api-calls)
as appear in `/admin/application_settings`. You have to be an
administrator in order to perform this action.

## Get current application settings

List the current [application settings](#list-of-settings-that-can-be-accessed-via-api-calls)
of the GitLab instance.

```
GET /application/settings
```

```bash
curl --header "PRIVATE-TOKEN: <your_access_token>" https://gitlab.example.com/api/v4/application/settings
```

Example response:

```json
{
   "default_projects_limit" : 100000,
   "signup_enabled" : true,
   "id" : 1,
   "default_branch_protection" : 2,
   "restricted_visibility_levels" : [],
   "password_authentication_enabled_for_web" : true,
   "after_sign_out_path" : null,
   "max_attachment_size" : 10,
   "user_oauth_applications" : true,
   "updated_at" : "2016-01-04T15:44:55.176Z",
   "session_expire_delay" : 10080,
   "home_page_url" : null,
   "default_snippet_visibility" : "private",
   "domain_whitelist" : [],
   "domain_blacklist_enabled" : false,
   "domain_blacklist" : [],
   "created_at" : "2016-01-04T15:44:55.176Z",
   "default_project_visibility" : "private",
   "default_group_visibility" : "private",
   "gravatar_enabled" : true,
   "sign_in_text" : null,
   "container_registry_token_expire_delay": 5,
   "repository_storages": ["default"],
   "plantuml_enabled": false,
   "plantuml_url": null,
   "terminal_max_session_time": 0,
   "polling_interval_multiplier": 1.0,
   "rsa_key_restriction": 0,
   "dsa_key_restriction": 0,
   "ecdsa_key_restriction": 0,
   "ed25519_key_restriction": 0,
   "first_day_of_week": 0,
   "enforce_terms": true,
   "terms": "Hello world!",
   "performance_bar_allowed_group_id": 42,
   "instance_statistics_visibility_private": false,
   "user_show_add_ssh_key_message": true,
   "local_markdown_version": 0
}
```

Users on GitLab [Premium or Ultimate](https://about.gitlab.com/pricing/) may also see
the `file_template_project_id` or the `geo_node_allowed_ips` parameters:

```json
{
   "id" : 1,
   "signup_enabled" : true,
   "file_template_project_id": 1,
   "geo_node_allowed_ips": "0.0.0.0/0, ::/0"
   ...
}
```

## Change application settings

Use an API call to modify GitLab instance
[application settings](#list-of-settings-that-can-be-accessed-via-api-calls).

```
PUT /application/settings
```

```bash
curl --request PUT --header "PRIVATE-TOKEN: <your_access_token>" https://gitlab.example.com/api/v4/application/settings?signup_enabled=false&default_project_visibility=internal
```

Example response:

```json
{
  "id": 1,
  "default_projects_limit": 100000,
  "signup_enabled": false,
  "password_authentication_enabled_for_web": true,
  "gravatar_enabled": true,
  "sign_in_text": "",
  "created_at": "2015-06-12T15:51:55.432Z",
  "updated_at": "2015-06-30T13:22:42.210Z",
  "home_page_url": "",
  "default_branch_protection": 2,
  "restricted_visibility_levels": [],
  "max_attachment_size": 10,
  "session_expire_delay": 10080,
  "default_project_visibility": "internal",
  "default_snippet_visibility": "private",
  "default_group_visibility": "private",
  "domain_whitelist": [],
  "domain_blacklist_enabled" : false,
  "domain_blacklist" : [],
  "user_oauth_applications": true,
  "after_sign_out_path": "",
  "container_registry_token_expire_delay": 5,
  "repository_storages": ["default"],
  "plantuml_enabled": false,
  "plantuml_url": null,
  "terminal_max_session_time": 0,
  "polling_interval_multiplier": 1.0,
  "rsa_key_restriction": 0,
  "dsa_key_restriction": 0,
  "ecdsa_key_restriction": 0,
  "ed25519_key_restriction": 0,
  "first_day_of_week": 0,
  "enforce_terms": true,
  "terms": "Hello world!",
  "performance_bar_allowed_group_id": 42,
  "instance_statistics_visibility_private": false,
  "user_show_add_ssh_key_message": true,
  "file_template_project_id": 1,
  "local_markdown_version": 0,
  "geo_node_allowed_ips": "0.0.0.0/0, ::/0"
}
```

Users on GitLab [Premium or Ultimate](https://about.gitlab.com/pricing/) may also see
these parameters:

- `external_authorization_service_enabled`
- `external_authorization_service_url`
- `external_authorization_service_default_label`
- `external_authorization_service_timeout`
- `file_template_project_id`
- `geo_node_allowed_ips`

Example responses: **[PREMIUM ONLY]**

```json
  "external_authorization_service_enabled": true,
  "external_authorization_service_url": "https://authorize.me",
  "external_authorization_service_default_label": "default",
  "external_authorization_service_timeout": 0.5,
  "file_template_project_id": 1,
  "geo_node_allowed_ips": "0.0.0.0/0, ::/0"
```

## List of settings that can be accessed via API calls

In general, all settings are optional. Certain settings though, if enabled, will
require other settings to be set in order to function properly. These requirements
are listed in the descriptions of the relevant settings.

| Attribute | Type | Required | Description |
| --------- | ---- | :------: | ----------- |
| `admin_notification_email`               | string           | no                                   | Abuse reports will be sent to this address if it is set. Abuse reports are always available in the admin area. |
| `after_sign_out_path`                    | string           | no                                   | Where to redirect users after logout. |
| `after_sign_up_text`                     | string           | no                                   | Text shown to the user after signing up |
| `akismet_api_key`                        | string           | required by: `akismet_enabled`       | API key for akismet spam protection. |
| `akismet_enabled`                        | boolean          | no                                   | (**If enabled, requires:** `akismet_api_key`) Enable or disable akismet spam protection. |
| `allow_group_owners_to_manage_ldap`      | boolean          | no                                   | **[PREMIUM]** Set to `true` to allow group owners to manage LDAP |
| `allow_local_requests_from_hooks_and_services` | boolean    | no                                   | Allow requests to the local network from hooks and services. |
| `authorized_keys_enabled`                | boolean          | no                                   | By default, we write to the `authorized_keys` file to support Git over SSH without additional configuration. GitLab can be optimized to authenticate SSH keys via the database file. Only disable this if you have configured your OpenSSH server to use the AuthorizedKeysCommand. |
| `auto_devops_domain`                     | string           | no                                   | Specify a domain to use by default for every project's Auto Review Apps and Auto Deploy stages. |
| `auto_devops_enabled`                    | boolean          | no                                   | Enable Auto DevOps for projects by default. It will automatically build, test, and deploy applications based on a predefined CI/CD configuration. |
| `check_namespace_plan`                   | boolean          | no                                   | **[PREMIUM]** Enabling this will make only licensed EE features available to projects if the project namespace's plan includes the feature or if the project is public. |
| `clientside_sentry_dsn`                  | string           | required by: `clientside_sentry_enabled` | Clientside Sentry Data Source Name. |
| `clientside_sentry_enabled`              | boolean          | no                                   | (**If enabled, requires:** `clientside_sentry_dsn`) Enable Sentry error reporting for the client side. |
| `container_registry_token_expire_delay`  | integer          | no                                   | Container Registry token duration in minutes. |
| `default_artifacts_expire_in`            | string           | no                                   | Set the default expiration time for each job's artifacts. |
| `default_branch_protection`              | integer          | no                                   | Determine if developers can push to master. Can take: `0` _(not protected, both developers and maintainers can push new commits, force push, or delete the branch)_, `1` _(partially protected, developers and maintainers can push new commits, but cannot force push or delete the branch)_ or `2` _(fully protected, developers cannot push new commits, but maintainers can; no-one can force push or delete the branch)_ as a parameter. Default is `2`. |
| `default_group_visibility`               | string           | no                                   | What visibility level new groups receive. Can take `private`, `internal` and `public` as a parameter. Default is `private`. |
| `default_project_visibility`             | string           | no                                   | What visibility level new projects receive. Can take `private`, `internal` and `public` as a parameter. Default is `private`. |
| `default_projects_limit`                 | integer          | no                                   | Project limit per user. Default is `100000`. |
| `default_snippet_visibility`             | string           | no                                   | What visibility level new snippets receive. Can take `private`, `internal` and `public` as a parameter. Default is `private`. |
| `disabled_oauth_sign_in_sources`         | array of strings | no                                   | Disabled OAuth sign-in sources. |
| `domain_blacklist`                       | array of strings | required by: `domain_blacklist_enabled` | Users with e-mail addresses that match these domain(s) will NOT be able to sign-up. Wildcards allowed. Use separate lines for multiple entries. Ex: `domain.com`, `*.domain.com`. |
| `domain_blacklist_enabled`               | boolean          | no                                   | (**If enabled, requires:** `domain_blacklist`) Allows blocking sign-ups from emails from specific domains. |
| `domain_whitelist`                       | array of strings | no                                   | Force people to use only corporate emails for sign-up. Default is `null`, meaning there is no restriction. |
| `dsa_key_restriction`                    | integer          | no                                   | The minimum allowed bit length of an uploaded DSA key. Default is `0` (no restriction). `-1` disables DSA keys. |
| `ecdsa_key_restriction`                  | integer          | no                                   | The minimum allowed curve size (in bits) of an uploaded ECDSA key. Default is `0` (no restriction). `-1` disables ECDSA keys. |
| `ed25519_key_restriction`                | integer          | no                                   | The minimum allowed curve size (in bits) of an uploaded ED25519 key. Default is `0` (no restriction). `-1` disables ED25519 keys. |
| `elasticsearch_aws`                      | boolean          | no                                   | **[PREMIUM]** Enable the use of AWS hosted Elasticsearch |
| `elasticsearch_aws_access_key`           | string           | no                                   | **[PREMIUM]** AWS IAM access key |
| `elasticsearch_aws_region`               | string           | no                                   | **[PREMIUM]** The AWS region the elasticsearch domain is configured |
| `elasticsearch_aws_secret_access_key`    | string           | no                                   | **[PREMIUM]** AWS IAM secret access key |
| `elasticsearch_experimental_indexer`     | boolean          | no                                   | **[PREMIUM]** Use the experimental elasticsearch indexer. More info: <https://gitlab.com/gitlab-org/gitlab-elasticsearch-indexer> |
| `elasticsearch_indexing`                 | boolean          | no                                   | **[PREMIUM]** Enable Elasticsearch indexing |
| `elasticsearch_search`                   | boolean          | no                                   | **[PREMIUM]** Enable Elasticsearch search |
| `elasticsearch_url`                      | string           | no                                   | **[PREMIUM]** The url to use for connecting to Elasticsearch. Use a comma-separated list to support cluster (e.g., `http://localhost:9200, http://localhost:9201"`). If your Elasticsearch instance is password protected, pass the `username:password` in the URL (e.g., `http://<username>:<password>@<elastic_host>:9200/`). |
| `elasticsearch_limit_indexing`           | boolean          | no                                   | **[PREMIUM]** Limit Elasticsearch to index certain namespaces and projects |
| `elasticsearch_project_ids`              | array of integers | no                                  | **[PREMIUM]** The projects to index via Elasticsearch if `elasticsearch_limit_indexing` is enabled. |
| `elasticsearch_namespace_ids`            | array of integers | no                                  | **[PREMIUM]** The namespaces to index via Elasticsearch if `elasticsearch_limit_indexing` is enabled. |
| `email_additional_text`                  | string           | no                                   | **[PREMIUM]** Additional text added to the bottom of every email for legal/auditing/compliance reasons |
| `email_author_in_body`                   | boolean          | no                                   | Some email servers do not support overriding the email sender name. Enable this option to include the name of the author of the issue, merge request or comment in the email body instead. |
| `enabled_git_access_protocol`            | string           | no                                   | Enabled protocols for Git access. Allowed values are: `ssh`, `http`, and `nil` to allow both protocols. |
| `enforce_terms`                          | boolean          | no                                   | (**If enabled, requires:** `terms`) Enforce application ToS to all users. |
| `external_auth_client_cert`              | string           | no                                   | **[PREMIUM]** (**If enabled, requires:** `external_auth_client_key`) The certificate to use to authenticate with the external authorization service |
| `external_auth_client_key`               | string           | required by: `external_auth_client_cert` | **[PREMIUM]** Private key for the certificate when authentication is required for the external authorization service, this is encrypted when stored |
| `external_auth_client_key_pass`          | string           | no                                   | **[PREMIUM]** Passphrase to use for the private key when authenticating with the external service this is encrypted when stored |
| `external_authorization_service_enabled` | boolean          | no                                   | **[PREMIUM]** (**If enabled, requires:** `external_authorization_service_default_label`, `external_authorization_service_timeout` and `external_authorization_service_url` )  Enable using an external authorization service for accessing projects |
| `external_authorization_service_default_label` | string     | required by: `external_authorization_service_enabled` | **[PREMIUM]** The default classification label to use when requesting authorization and no classification label has been specified on the project |
| `external_authorization_service_timeout` | float            | required by: `external_authorization_service_enabled` | **[PREMIUM]** The timeout after which an authorization request is aborted, in seconds. When a request times out, access is denied to the user. (min: 0.001, max: 10, step: 0.001) |
| `external_authorization_service_url`     | string           | required by: `external_authorization_service_enabled` | **[PREMIUM]** URL to which authorization requests will be directed |
| `file_template_project_id`               | integer          | no                                   | **[PREMIUM]** The ID of a project to load custom file templates from |
| `first_day_of_week`                      | integer          | no                                   | Start day of the week for calendar views and date pickers. Valid values are `0` (default) for Sunday, `1` for Monday, and `6` for Saturday. |
| `geo_status_timeout`                     | integer          | no                                   | **[PREMIUM]** The amount of seconds after which a request to get a secondary node status will time out. |
| `gitaly_timeout_default`                 | integer          | no                                   | Default Gitaly timeout, in seconds. This timeout is not enforced for git fetch/push operations or Sidekiq jobs. Set to `0` to disable timeouts. |
| `gitaly_timeout_fast`                    | integer          | no                                   | Gitaly fast operation timeout, in seconds. Some Gitaly operations are expected to be fast. If they exceed this threshold, there may be a problem with a storage shard and 'failing fast' can help maintain the stability of the GitLab instance. Set to `0` to disable timeouts. |
| `gitaly_timeout_medium`                  | integer          | no                                   | Medium Gitaly timeout, in seconds. This should be a value between the Fast and the Default timeout. Set to `0` to disable timeouts. |
| `gravatar_enabled`                       | boolean          | no                                   | Enable Gravatar. |
| `hashed_storage_enabled`                 | boolean          | no                                   | Create new projects using hashed storage paths: Enable immutable, hash-based paths and repository names to store repositories on disk. This prevents repositories from having to be moved or renamed when the Project URL changes and may improve disk I/O performance. (EXPERIMENTAL) |
| `help_page_hide_commercial_content`      | boolean          | no                                   | Hide marketing-related entries from help. |
| `help_page_support_url`                  | string           | no                                   | Alternate support URL for help page. |
| `help_page_text`                         | string           | no                                   | Custom text displayed on the help page. |
| `help_text`                              | string           | no                                   | **[PREMIUM]** GitLab server administrator information |
| `hide_third_party_offers`                | boolean          | no                                   | Do not display offers from third parties within GitLab. |
| `home_page_url`                          | string           | no                                   | Redirect to this URL when not logged in. |
| `housekeeping_bitmaps_enabled`           | boolean          | required by: `housekeeping_enabled`  | Enable Git pack file bitmap creation. |
| `housekeeping_enabled`                   | boolean          | no                                   | (**If enabled, requires:** `housekeeping_bitmaps_enabled`, `housekeeping_full_repack_period`, `housekeeping_gc_period`, and `housekeeping_incremental_repack_period`) Enable or disable git housekeeping. |
| `housekeeping_full_repack_period`        | integer          | required by: `housekeeping_enabled`  | Number of Git pushes after which an incremental `git repack` is run. |
| `housekeeping_gc_period`                 | integer          | required by: `housekeeping_enabled`  | Number of Git pushes after which `git gc` is run. |
| `housekeeping_incremental_repack_period` | integer          | required by: `housekeeping_enabled`  | Number of Git pushes after which an incremental `git repack` is run. |
| `html_emails_enabled`                    | boolean          | no                                   | Enable HTML emails. |
| `instance_statistics_visibility_private` | boolean          | no                                   | When set to `true` Instance statistics will only be available to admins. |
| `import_sources`                         | array of strings | no                                   | Sources to allow project import from, possible values: `github`, `bitbucket`, `gitlab`, `google_code`, `fogbugz`, `git`, and `gitlab_project`. |
| `max_artifacts_size`                     | integer          | no                                   | Maximum artifacts size in MB |
| `max_attachment_size`                    | integer          | no                                   | Limit attachment size in MB |
| `max_pages_size`                         | integer          | no                                   | Maximum size of pages repositories in MB |
| `metrics_enabled`                        | boolean          | no                                   | (**If enabled, requires:** `metrics_host`, `metrics_method_call_threshold`, `metrics_packet_size`, `metrics_pool_size`, `metrics_port`, `metrics_sample_interval` and `metrics_timeout`) Enable influxDB metrics. |
| `metrics_host`                           | string           | required by: `metrics_enabled`       | InfluxDB host. |
| `metrics_method_call_threshold`          | integer          | required by: `metrics_enabled`       | A method call is only tracked when it takes longer than the given amount of milliseconds. |
| `metrics_packet_size`                    | integer          | required by: `metrics_enabled`       | The amount of datapoints to send in a single UDP packet. |
| `metrics_pool_size`                      | integer          | required by: `metrics_enabled`       | The amount of InfluxDB connections to keep open. |
| `metrics_port`                           | integer          | required by: `metrics_enabled`       | The UDP port to use for connecting to InfluxDB. |
| `metrics_sample_interval`                | integer          | required by: `metrics_enabled`       | The sampling interval in seconds. |
| `metrics_timeout`                        | integer          | required by: `metrics_enabled`       | The amount of seconds after which InfluxDB will time out. |
| `mirror_available`                       | boolean          | no                                   | Allow mirrors to be set up for projects. If disabled, only admins will be able to set up mirrors in projects. |
| `mirror_capacity_threshold`              | integer          | no                                   | **[PREMIUM]** Minimum capacity to be available before scheduling more mirrors preemptively |
| `mirror_max_capacity`                    | integer          | no                                   | **[PREMIUM]** Maximum number of mirrors that can be synchronizing at the same time. |
| `mirror_max_delay`                       | integer          | no                                   | **[PREMIUM]** Maximum time (in minutes) between updates that a mirror can have when scheduled to synchronize. |
| `pages_domain_verification_enabled`      | boolean          | no                                   | Require users to prove ownership of custom domains. Domain verification is an essential security measure for public GitLab sites. Users are required to demonstrate they control a domain before it is enabled. |
| `password_authentication_enabled_for_git` | boolean         | no                                   | Enable authentication for Git over HTTP(S) via a GitLab account password. Default is `true`. |
| `password_authentication_enabled_for_web` | boolean         | no                                   | Enable authentication for the web interface via a GitLab account password. Default is `true`. |
| `performance_bar_allowed_group_id`       | string           | no                                   | (Deprecated: Use `performance_bar_allowed_group_path` instead) Path of the group that is allowed to toggle the performance bar. |
| `performance_bar_allowed_group_path`     | string           | no                                   | Path of the group that is allowed to toggle the performance bar. |
| `performance_bar_enabled`                | boolean          | no                                   | (Deprecated: Pass `performance_bar_allowed_group_path: nil` instead) Allow enabling the performance bar. |
| `plantuml_enabled`                       | boolean          | no                                   | (**If enabled, requires:** `plantuml_url`) Enable PlantUML integration. Default is `false`. |
| `plantuml_url`                           | string           | required by: `plantuml_enabled`      | The PlantUML instance URL for integration. |
| `polling_interval_multiplier`            | decimal          | no                                   | Interval multiplier used by endpoints that perform polling. Set to `0` to disable polling. |
| `project_export_enabled`                 | boolean          | no                                   | Enable project export. |
| `prometheus_metrics_enabled`             | boolean          | no                                   | Enable prometheus metrics. |
| `pseudonymizer_enabled`                  | boolean          | no                                   | **[PREMIUM]** When enabled, GitLab will run a background job that will produce pseudonymized CSVs of the GitLab database that will be uploaded to your configured object storage directory.
| `recaptcha_enabled`                      | boolean          | no                                   | (**If enabled, requires:** `recaptcha_private_key` and `recaptcha_site_key`) Enable recaptcha. |
| `recaptcha_private_key`                  | string           | required by: `recaptcha_enabled`     | Private key for recaptcha. |
| `recaptcha_site_key`                     | string           | required by: `recaptcha_enabled`     | Site key for recaptcha. |
| `repository_checks_enabled`              | boolean          | no                                   | GitLab will periodically run `git fsck` in all project and wiki repositories to look for silent disk corruption issues. |
| `repository_size_limit`                  | integer          | no                                   | **[PREMIUM]** Size limit per repository (MB) |
| `repository_storages`                    | array of strings | no                                   | A list of names of enabled storage paths, taken from `gitlab.yml`. New projects will be created in one of these stores, chosen at random. |
| `require_two_factor_authentication`      | boolean          | no                                   | (**If enabled, requires:** `two_factor_grace_period`) Require all users to set up Two-factor authentication. |
| `restricted_visibility_levels`           | array of strings | no                                   | Selected levels cannot be used by non-admin users for groups, projects or snippets. Can take `private`, `internal` and `public` as a parameter. Default is `null` which means there is no restriction. |
| `rsa_key_restriction`                    | integer          | no                                   | The minimum allowed bit length of an uploaded RSA key. Default is `0` (no restriction). `-1` disables RSA keys. |
| `send_user_confirmation_email`           | boolean          | no                                   | Send confirmation email on sign-up. |
| `session_expire_delay`                   | integer          | no                                   | Session duration in minutes. GitLab restart is required to apply changes |
| `shared_runners_enabled`                 | boolean          | no                                   | (**If enabled, requires:** `shared_runners_text` and `shared_runners_minutes`) Enable shared runners for new projects. |
| `shared_runners_minutes`                 | integer          | required by: `shared_runners_enabled` | **[PREMIUM]** Set the maximum number of pipeline minutes that a group can use on shared Runners per month. |
| `shared_runners_text`                    | string           | required by: `shared_runners_enabled` | Shared runners text. |
| `sign_in_text`                           | string           | no                                   | Text on the login page. |
| `signin_enabled`                         | string           | no                                   | (Deprecated: Use `password_authentication_enabled_for_web` instead) Flag indicating if password authentication is enabled for the web interface. |
| `signup_enabled`                         | boolean          | no                                   | Enable registration. Default is `true`. |
| `slack_app_enabled`                      | boolean          | no                                   | **[PREMIUM]** (**If enabled, requires:** `slack_app_id`, `slack_app_secret` and `slack_app_secret`) Enable Slack app. |
| `slack_app_id`                           | string           | required by: `slack_app_enabled`      | **[PREMIUM]** The app id of the Slack-app. |
| `slack_app_secret`                       | string           | required by: `slack_app_enabled`      | **[PREMIUM]** The app secret of the Slack-app. |
| `slack_app_verification_token`           | string           | required by: `slack_app_enabled`      | **[PREMIUM]** The verification token of the Slack-app. |
| `terminal_max_session_time`              | integer          | no                                   | Maximum time for web terminal websocket connection (in seconds). Set to `0` for unlimited time. |
| `terms`                                  | text             | required by: `enforce_terms`         | (**Required by:** `enforce_terms`) Markdown content for the ToS. |
| `throttle_authenticated_api_enabled`     | boolean          | no                                   | (**If enabled, requires:** `throttle_authenticated_api_period_in_seconds` and `throttle_authenticated_api_requests_per_period`) Enable authenticated API request rate limit. Helps reduce request volume (e.g. from crawlers or abusive bots). |
| `throttle_authenticated_api_period_in_seconds` | integer    | required by: `throttle_authenticated_api_enabled` | Rate limit period in seconds.  |
| `throttle_authenticated_api_requests_per_period` | integer  | required by: `throttle_authenticated_api_enabled` | Max requests per period per user. |
| `throttle_authenticated_web_enabled`     | boolean          | no                                   | (**If enabled, requires:** `throttle_authenticated_web_period_in_seconds` and `throttle_authenticated_web_requests_per_period`) Enable authenticated web request rate limit. Helps reduce request volume (e.g. from crawlers or abusive bots). |
| `throttle_authenticated_web_period_in_seconds` | integer    | required by: `throttle_authenticated_web_enabled` | Rate limit period in seconds. |
| `throttle_authenticated_web_requests_per_period` | integer  | required by: `throttle_authenticated_web_enabled` | Max requests per period per user. |
| `throttle_unauthenticated_enabled`       | boolean          | no                                   | (**If enabled, requires:** `throttle_unauthenticated_period_in_seconds` and `throttle_unauthenticated_requests_per_period`) Enable unauthenticated request rate limit. Helps reduce request volume (e.g. from crawlers or abusive bots). |
| `throttle_unauthenticated_period_in_seconds` | integer      | required by: `throttle_unauthenticated_enabled` | Rate limit period in seconds.  |
| `throttle_unauthenticated_requests_per_period` | integer    | required by: `throttle_unauthenticated_enabled` | Max requests per period per IP. |
| `time_tracking_limit_to_hours`           | boolean          | no                                   | Limit display of time tracking units to hours. Default is `false`. |
| `two_factor_grace_period`                | integer          | required by: `require_two_factor_authentication` | Amount of time (in hours) that users are allowed to skip forced configuration of two-factor authentication. |
| `unique_ips_limit_enabled`               | boolean          | no                                   | (**If enabled, requires:** `unique_ips_limit_per_user` and `unique_ips_limit_time_window`) Limit sign in from multiple ips. |
| `unique_ips_limit_per_user`              | integer          | required by: `unique_ips_limit_enabled` | Maximum number of ips per user. |
| `unique_ips_limit_time_window`           | integer          | required by: `unique_ips_limit_enabled` | How many seconds an IP will be counted towards the limit. |
| `usage_ping_enabled`                     | boolean          | no                                   | Every week GitLab will report license usage back to GitLab, Inc. |
| `user_default_external`                  | boolean          | no                                   | Newly registered users will be external by default. |
| `user_oauth_applications`                | boolean          | no                                   | Allow users to register any application to use GitLab as an OAuth provider. |
| `user_show_add_ssh_key_message`          | boolean          | no                                   | When set to `false` disable the "You won't be able to pull or push project code via SSH" warning shown to users with no uploaded SSH key. |
| `version_check_enabled`                  | boolean          | no                                   | Let GitLab inform you when an update is available. |
| `local_markdown_version`                 | integer          | no                                   | Increase this value when any cached markdown should be invalidated. |
| `geo_node_allowed_ips`                   | string           | yes                                  | **[PREMIUM]** Comma-separated list of IPs and CIDRs of allowed secondary nodes. For example, `1.1.1.1, 2.2.2.0/24`. |
