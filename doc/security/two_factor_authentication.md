---
type: howto
---
# Enforce Two-factor Authentication (2FA)

Two-factor Authentication (2FA) provides an additional level of security to your
users' GitLab account. Once enabled, in addition to supplying their username and
password to login, they'll be prompted for a code generated by an application on
their phone.

You can read more about it here:
[Two-factor Authentication (2FA)](../user/profile/account/two_factor_authentication.md)

## Enforcing 2FA for all users

Users on GitLab, can enable it without any admin's intervention. If you want to
enforce everyone to set up 2FA, you can choose from two different ways:

- Enforce on next login.
- Suggest on next login, but allow a grace period before enforcing.

After the configured grace period has elapsed, users will be able to log in but
won't be able to leave the 2FA configuration area at `/profile/two_factor_auth`.

To enable 2FA for all users:

1. Navigate to **Admin area > Settings > General** (`/admin/application_settings`).
1. Expand the **Sign-in restrictions** section, where you can configure both.

If you want 2FA enforcement to take effect on next login, change the grace
period to `0`.

## Enforcing 2FA for all users in a group

If you want to enforce 2FA only for certain groups, you can:

1. Enable it in the group's **Settings > General** page.
1. Optionally specify a grace period as above.

To change this setting, you need to be administrator or owner of the group.

> [From](https://gitlab.com/gitlab-org/gitlab-ce/merge_requests/24965) GitLab 12.0, 2FA settings for a group are also applied to subgroups.

If you want to enforce 2FA only for certain groups, you can enable it in the
group settings and specify a grace period as above. To change this setting you
need to be administrator or owner of the group.

The following are important notes about 2FA:

- Projects belonging to a 2FA-enabled group that
  [is shared](../user/project/members/share_project_with_groups.md) 
  with a 2FA-disabled group will *not* require members of the 2FA-disabled group to use
  2FA for the project. For example, if project *P* belongs to 2FA-enabled group *A* and 
  is shared with 2FA-disabled group *B*, members of group *B* can access project *P*
  without 2FA. To ensure this scenario doesn't occur, 
  [prevent sharing of projects](../user/group/index.md#share-with-group-lock)
  for the 2FA-enabled group.
- If you add additional members to a project within a group or subgroup that has
  2FA enabled, 2FA is **not** required for those individually added members.
- If there are multiple 2FA requirements (for example, group + all users, or multiple
  groups) the shortest grace period will be used.

## Disabling 2FA for everyone

There may be some special situations where you want to disable 2FA for everyone
even when forced 2FA is disabled. There is a rake task for that:

```sh
# Omnibus installations
sudo gitlab-rake gitlab:two_factor:disable_for_all_users

# Installations from source
sudo -u git -H bundle exec rake gitlab:two_factor:disable_for_all_users RAILS_ENV=production
```

CAUTION: **Caution:**
This is a permanent and irreversible action. Users will have to
reactivate 2FA from scratch if they want to use it again.

<!-- ## Troubleshooting

Include any troubleshooting steps that you can foresee. If you know beforehand what issues
one might have when setting this up, or when something is changed, or on upgrading, it's
important to describe those, too. Think of things that may go wrong and include them here.
This is important to minimize requests for support, and to avoid doc comments with
questions that you know someone might ask.

Each scenario can be a third-level heading, e.g. `### Getting error message X`.
If you have none to add when creating a doc, leave this section in place
but commented out to help encourage others to add to it in the future. -->
