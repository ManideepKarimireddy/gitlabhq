# Protected branches API

>**Note:** This feature was introduced in GitLab 9.5

**Valid access levels**

The access levels are defined in the `ProtectedRefAccess.allowed_access_levels` method. Currently, these levels are recognized:

```
0  => No access
30 => Developer access
40 => Maintainer access
60 => Admin access
```

## List protected branches

Gets a list of protected branches from a project.

```
GET /projects/:id/protected_branches
```

| Attribute | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `id` | integer/string | yes | The ID or [URL-encoded path of the project](README.md#namespaced-path-encoding) owned by the authenticated user |

```bash
curl --header "PRIVATE-TOKEN: <your_access_token>" 'https://gitlab.example.com/api/v4/projects/5/protected_branches'
```

Example response:

```json
[
  {
    "name": "master",
    "push_access_levels": [
      {
        "access_level": 40,
        "access_level_description": "Maintainers"
      }
    ],
    "merge_access_levels": [
      {
        "access_level": 40,
        "access_level_description": "Maintainers"
      }
    ]
  },
  ...
]
```

Users on GitLab [Starter, Bronze, or higher](https://about.gitlab.com/pricing/) will also see
the `user_id` and `group_id` parameters:

Example response:

```json
[
  {
    "name": "master",
    "push_access_levels": [
      {
        "access_level": 40,
        "user_id": null,
        "group_id": null,
        "access_level_description": "Maintainers"
      }
    ],
    "merge_access_levels": [
      {
        "access_level": null,
        "user_id": null,
        "group_id": 1234,
        "access_level_description": "Example Merge Group"
      }
    ]
  },
  ...
]
```

## Get a single protected branch or wildcard protected branch

Gets a single protected branch or wildcard protected branch.

```
GET /projects/:id/protected_branches/:name
```

| Attribute | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `id` | integer/string | yes | The ID or [URL-encoded path of the project](README.md#namespaced-path-encoding) owned by the authenticated user |
| `name` | string | yes | The name of the branch or wildcard |

```bash
curl --header "PRIVATE-TOKEN: <your_access_token>" 'https://gitlab.example.com/api/v4/projects/5/protected_branches/master'
```

Example response:

```json
{
  "name": "master",
  "push_access_levels": [
    {
      "access_level": 40,
      "access_level_description": "Maintainers"
    }
  ],
  "merge_access_levels": [
    {
      "access_level": 40,
      "access_level_description": "Maintainers"
    }
  ]
}
```

Users on GitLab [Starter, Bronze, or higher](https://about.gitlab.com/pricing/) will also see
the `user_id` and `group_id` parameters:

Example response:

```json
{
  "name": "master",
  "push_access_levels": [
    {
      "access_level": 40,
      "user_id": null,
      "group_id": null,
      "access_level_description": "Maintainers"
    }
  ],
  "merge_access_levels": [
    {
      "access_level": null,
      "user_id": null,
      "group_id": 1234,
      "access_level_description": "Example Merge Group"
    }
  ]
}
```

## Protect repository branches

Protects a single repository branch or several project repository
branches using a wildcard protected branch.

```
POST /projects/:id/protected_branches
```

```bash
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" 'https://gitlab.example.com/api/v4/projects/5/protected_branches?name=*-stable&push_access_level=30&merge_access_level=30&unprotect_access_level=40'
```

| Attribute | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `id`                     | integer/string | yes | The ID or [URL-encoded path of the project](README.md#namespaced-path-encoding) owned by the authenticated user |
| `name`                   | string         | yes | The name of the branch or wildcard |
| `push_access_level`      | string         | no  | Access levels allowed to push (defaults: `40`, maintainer access level) |
| `merge_access_level`     | string         | no  | Access levels allowed to merge (defaults: `40`, maintainer access level) |
| `unprotect_access_level` | string         | no  | Access levels allowed to unprotect (defaults: `40`, maintainer access level) |
| `allowed_to_push`        | array          | no  | **[STARTER]** Array of access levels allowed to push, with each described by a hash |
| `allowed_to_merge`       | array          | no  | **[STARTER]** Array of access levels allowed to merge, with each described by a hash |
| `allowed_to_unprotect`   | array          | no  | **[STARTER]**Array of access levels allowed to unprotect, with each described by a hash |

Example response:

```json
{
  "name": "*-stable",
  "push_access_levels": [
    {
      "access_level": 30,
      "access_level_description": "Developers + Maintainers"
    }
  ],
  "merge_access_levels": [
    {
      "access_level": 30,
      "access_level_description": "Developers + Maintainers"
  ],
  "unprotect_access_levels": [
    {
      "access_level": 40,
      "access_level_description": "Maintainers"
    }
  ]
}
```

Users on GitLab [Starter, Bronze, or higher](https://about.gitlab.com/pricing/) will also see
the `user_id` and `group_id` parameters:

Example response:

```json
{
  "name": "*-stable",
  "push_access_levels": [
    {
      "access_level": 30,
      "user_id": null,
      "group_id": null,
      "access_level_description": "Developers + Maintainers"
    }
  ],
  "merge_access_levels": [
    {
      "access_level": 30,
      "user_id": null,
      "group_id": null,
      "access_level_description": "Developers + Maintainers"
  ],
  "unprotect_access_levels": [
    {
      "access_level": 40,
      "user_id": null,
      "group_id": null,
      "access_level_description": "Maintainers"
    }
  ]
}
```

### Example with user / group level access **[STARTER]**

Elements in the `allowed_to_push` / `allowed_to_merge` / `allowed_to_unprotect` array should take the
form `{user_id: integer}`, `{group_id: integer}` or `{access_level: integer}`. Each user must have access to the project and each group must [have this project shared](../user/project/members/share_project_with_groups.md). These access levels allow [more granular control over protected branch access](../user/project/protected_branches.md#restricting-push-and-merge-access-to-certain-users-starter) and were [added to the API in ][ee-3516] in GitLab 10.3 EE.

```bash
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" 'https://gitlab.example.com/api/v4/projects/5/protected_branches?name=*-stable&allowed_to_push%5B%5D%5Buser_id%5D=1'
```

Example response:

```json
{
  "name":"*-stable",
  "push_access_levels": [
    {
      "access_level":null,
      "user_id":1,
      "group_id":null,
      "access_level_description":"Administrator"
    }
  ],
  "merge_access_levels": [
    {
      "access_level":40,
      "user_id":null,
      "group_id":null,
      "access_level_description":"Maintainers"
    }
  ],
  "unprotect_access_levels": [
    {
      "access_level":40,
      "user_id":null,
      "group_id":null,
      "access_level_description":"Maintainers"
    }
  ]
}
```

## Unprotect repository branches

Unprotects the given protected branch or wildcard protected branch.

```
DELETE /projects/:id/protected_branches/:name
```

```bash
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" 'https://gitlab.example.com/api/v4/projects/5/protected_branches/*-stable'
```

| Attribute | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `id` | integer/string | yes | The ID or [URL-encoded path of the project](README.md#namespaced-path-encoding) owned by the authenticated user |
| `name` | string | yes | The name of the branch |

[ee-3516]: https://gitlab.com/gitlab-org/gitlab-ee/merge_requests/3516 "ProtectedBranches API handles per user/group granularity"
