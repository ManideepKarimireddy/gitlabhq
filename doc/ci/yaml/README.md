---
type: reference
---

# GitLab CI/CD Pipeline Configuration Reference

GitLab CI/CD [pipelines](../pipelines.md) are configured using a YAML file called `.gitlab-ci.yml` within each project.

The `.gitlab-ci.yml` file defines the structure and order of the pipelines and determines:

- What to execute using [GitLab Runner](https://docs.gitlab.com/runner/).
- What decisions to make when specific conditions are encountered. For example, when a process succeeds or fails.

This topic covers CI/CD pipeline configuration. For other CI/CD configuration information, see:

- [GitLab CI/CD Variables](../variables/README.md), for configuring the environment the pipelines run in.
- [GitLab Runner advanced configuration](https://docs.gitlab.com/runner/configuration/advanced-configuration.html), for configuring GitLab Runner.

We have complete examples of configuring pipelines:

- For a quick introduction to GitLab CI, follow our [quick start guide](../quick_start/README.md).
- For a collection of examples, see [GitLab CI/CD Examples](../examples/README.md).
- To see a large `.gitlab-ci.yml` file used in an enterprise, see the [`.gitlab-ci.yml` file for `gitlab-ce`](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/.gitlab-ci.yml).

NOTE: **Note:**
If you have a [mirrored repository where GitLab pulls from](../../workflow/repository_mirroring.md#pulling-from-a-remote-repository-starter),
you may need to enable pipeline triggering in your project's
**Settings > Repository > Pull from a remote repository > Trigger pipelines for mirror updates**.

## Introduction

Pipeline configuration begins with jobs. Jobs are the most fundamental element of a `.gitlab-ci.yml` file.

Jobs are:

- Defined with constraints stating under what conditions they should be executed.
- Top-level elements with an arbitrary name and must contain at least the [`script`](#script) clause.
- Not limited in how many can be defined.

For example:

```yaml
job1:
  script: "execute-script-for-job1"

job2:
  script: "execute-script-for-job2"
```

The above example is the simplest possible CI/CD configuration with two separate
jobs, where each of the jobs executes a different command.
Of course a command can execute code directly (`./configure;make;make install`)
or run a script (`test.sh`) in the repository.

Jobs are picked up by [Runners](../runners/README.md) and executed within the
environment of the Runner. What is important, is that each job is run
independently from each other.

### Validate the .gitlab-ci.yml

Each instance of GitLab CI has an embedded debug tool called Lint, which validates the
content of your `.gitlab-ci.yml` files. You can find the Lint under the page `ci/lint` of your
project namespace. For example, `https://gitlab.example.com/gitlab-org/project-123/-/ci/lint`.

### Unavailable names for jobs

Each job must have a unique name, but there are a few **reserved `keywords` that
cannot be used as job names**:

- `image`
- `services`
- `stages`
- `types`
- `before_script`
- `after_script`
- `variables`
- `cache`

### Using reserved keywords

If you get validation error when using specific values (for example, `true` or `false`), try to:

- Quote them.
- Change them to a different form. For example, `/bin/true`.

## Configuration parameters

A job is defined as a list of parameters that define the job's behavior.

The following table lists available parameters for jobs:

| Keyword                                            | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
|:---------------------------------------------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [`script`](#script)                                | Shell script which is executed by Runner.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| [`image`](#image)                                  | Use docker images. Also available: `image:name` and `image:entrypoint`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| [`services`](#services)                            | Use docker services images. Also available: `services:name`, `services:alias`, `services:entrypoint`, and `services:command`.                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| [`before_script`](#before_script-and-after_script) | Override a set of commands that are executed before job.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| [`after_script`](#before_script-and-after_script)  | Override a set of commands that are executed after job.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| [`stages`](#stages)                                | Define stages in a pipeline.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| [`stage`](#stage)                                  | Defines a job stage (default: `test`).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| [`only`](#onlyexcept-basic)                        | Limit when jobs are created. Also available: [`only:refs`, `only:kubernetes`, `only:variables`, and `only:changes`](#onlyexcept-advanced).                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| [`except`](#onlyexcept-basic)                      | Limit when jobs are not created. Also available: [`except:refs`, `except:kubernetes`, `except:variables`, and `except:changes`](#onlyexcept-advanced).                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| [`tags`](#tags)                                    | List of tags which are used to select Runner.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| [`allow_failure`](#allow_failure)                  | Allow job to fail. Failed job doesn't contribute to commit status.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| [`when`](#when)                                    | When to run job. Also available: `when:manual` and `when:delayed`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| [`environment`](#environment)                      | Name of an environment to which the job deploys. Also available: `environment:name`, `environment:url`, `environment:on_stop`, and `environment:action`.                                                                                                                                                                                                                                                                                                                                                                                                                                |
| [`cache`](#cache)                                  | List of files that should be cached between subsequent runs. Also available: `cache:paths`, `cache:key`, `cache:untracked`, and `cache:policy`.                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| [`artifacts`](#artifacts)                          | List of files and directories to attach to a job on success. Also available: `artifacts:paths`, `artifacts:name`, `artifacts:untracked`, `artifacts:when`, `artifacts:expire_in`, `artifacts:reports`, and `artifacts:reports:junit`.<br><br>In GitLab [Enterprise Edition](https://about.gitlab.com/pricing/), these are available: `artifacts:reports:codequality`, `artifacts:reports:sast`, `artifacts:reports:dependency_scanning`, `artifacts:reports:container_scanning`, `artifacts:reports:dast`, `artifacts:reports:license_management`, `artifacts:reports:performance` and `artifacts:reports:metrics`. |
| [`dependencies`](#dependencies)                    | Other jobs that a job depends on so that you can pass artifacts between them.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| [`coverage`](#coverage)                            | Code coverage settings for a given job.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| [`retry`](#retry)                                  | When and how many times a job can be auto-retried in case of a failure.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| [`parallel`](#parallel)                            | How many instances of a job should be run in parallel.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| [`trigger`](#trigger-premium)                      | Defines a downstream pipeline trigger.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| [`include`](#include)                              | Allows this job to include external YAML files. Also available: `include:local`, `include:file`, `include:template`, and `include:remote`.                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| [`extends`](#extends)                              | Configuration entries that this job is going to inherit from.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| [`pages`](#pages)                                  | Upload the result of a job to use with GitLab Pages.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| [`variables`](#variables)                          | Define job variables on a job level.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |

NOTE: **Note:**
Parameters `types` and `type` are [deprecated](#deprecated-parameters).

## Parameter details

The following are detailed explanations for parameters used to configure CI/CD pipelines.

### `script`

`script` is the only required keyword that a job needs. It's a shell script
which is executed by the Runner. For example:

```yaml
job:
  script: "bundle exec rspec"
```

This parameter can also contain several commands using an array:

```yaml
job:
  script:
    - uname -a
    - bundle exec rspec
```

NOTE: **Note:**
Sometimes, `script` commands will need to be wrapped in single or double quotes.
For example, commands that contain a colon (`:`) need to be wrapped in quotes so
that the YAML parser knows to interpret the whole thing as a string rather than
a "key: value" pair. Be careful when using special characters:
`:`, `{`, `}`, `[`, `]`, `,`, `&`, `*`, `#`, `?`, `|`, `-`, `<`, `>`, `=`, `!`, `%`, `@`, `` ` ``.

### `image`

Used to specify [a Docker image](../docker/using_docker_images.md#what-is-an-image) to use for the job.

For:

- Simple definition examples, see [Define `image` and `services` from .gitlab-ci.yml](../docker/using_docker_images.md#define-image-and-services-from-gitlab-ciyml).
- Detailed usage information, refer to [Docker integration](../docker/README.md) documentation.

#### `image:name`

An [extended docker configuration option](../docker/using_docker_images.md#extended-docker-configuration-options).

For more information, see [Available settings for `image`](../docker/using_docker_images.md#available-settings-for-image).

#### `image:entrypoint`

An [extended docker configuration option](../docker/using_docker_images.md#extended-docker-configuration-options).

For more information, see [Available settings for `image`](../docker/using_docker_images.md#available-settings-for-image).

### `services`

Used to specify a [service Docker image](../docker/using_docker_images.md#what-is-a-service), linked to a base image specified in [`image`](#image).

For:

- Simple definition examples, see [Define `image` and `services` from .gitlab-ci.yml](../docker/using_docker_images.md#define-image-and-services-from-gitlab-ciyml).
- Detailed usage information, refer to [Docker integration](../docker/README.md) documentation.
- For example services, see [GitLab CI Services](../services/README.md).

#### `services:name`

An [extended docker configuration option](../docker/using_docker_images.md#extended-docker-configuration-options).

For more information, see see [Available settings for `services`](../docker/using_docker_images.md#available-settings-for-services).

#### `services:alias`

An [extended docker configuration option](../docker/using_docker_images.md#extended-docker-configuration-options).

For more information, see see [Available settings for `services`](../docker/using_docker_images.md#available-settings-for-services).

#### `services:entrypoint`

An [extended docker configuration option](../docker/using_docker_images.md#extended-docker-configuration-options).

For more information, see see [Available settings for `services`](../docker/using_docker_images.md#available-settings-for-services).

#### `services:command`

An [extended docker configuration option](../docker/using_docker_images.md#extended-docker-configuration-options).

For more information, see see [Available settings for `services`](../docker/using_docker_images.md#available-settings-for-services).

### `before_script` and `after_script`

> Introduced in GitLab 8.7 and requires GitLab Runner v1.2.

`before_script` is used to define the command that should be run before all
jobs, including deploy jobs, but after the restoration of [artifacts](#artifacts).
This can be an array or a multi-line string.

`after_script` is used to define the command that will be run after all
jobs, including failed ones. This has to be an array or a multi-line string.

Scripts specified in `before_script` are:

- Concatenated with scripts specified in the main `script`. Job-level
  `before_script` definition override global-level `before_script` definition
  when concatenated with `script` definition.
- Executed together with main `script` script as one script in a single shell
  context.

Scripts specified in `after_script`:

- Have a current working directory set back to the default.
- Are executed in a shell context separated from `before_script` and `script`
  scripts.
- Because of separated context, cannot see changes done by scripts defined
  in `before_script` or `script` scripts, either:
  - In shell. For example, command aliases and variables exported in `script`
    scripts.
  - Outside of the working tree (depending on the Runner executor). For example,
    software installed by a `before_script` or `script` scripts.

It's possible to overwrite the globally defined `before_script` and `after_script`
if you set it per-job:

```yaml
before_script:
  - global before script

job:
  before_script:
    - execute this instead of global before script
  script:
    - my command
  after_script:
    - execute this after my script
```

### `stages`

`stages` is used to define stages that can be used by jobs and is defined
globally.

The specification of `stages` allows for having flexible multi stage pipelines.
The ordering of elements in `stages` defines the ordering of jobs' execution:

1. Jobs of the same stage are run in parallel.
1. Jobs of the next stage are run after the jobs from the previous stage
   complete successfully.

Let's consider the following example, which defines 3 stages:

```yaml
stages:
  - build
  - test
  - deploy
```

1. First, all jobs of `build` are executed in parallel.
1. If all jobs of `build` succeed, the `test` jobs are executed in parallel.
1. If all jobs of `test` succeed, the `deploy` jobs are executed in parallel.
1. If all jobs of `deploy` succeed, the commit is marked as `passed`.
1. If any of the previous jobs fails, the commit is marked as `failed` and no
   jobs of further stage are executed.

There are also two edge cases worth mentioning:

1. If no `stages` are defined in `.gitlab-ci.yml`, then the `build`,
   `test` and `deploy` are allowed to be used as job's stage by default.
1. If a job doesn't specify a `stage`, the job is assigned the `test` stage.

### `stage`

`stage` is defined per-job and relies on [`stages`](#stages) which is defined
globally. It allows to group jobs into different stages, and jobs of the same
`stage` are executed in parallel (subject to [certain conditions](#using-your-own-runners)). For example:

```yaml
stages:
  - build
  - test
  - deploy

job 1:
  stage: build
  script: make build dependencies

job 2:
  stage: build
  script: make build artifacts

job 3:
  stage: test
  script: make test

job 4:
  stage: deploy
  script: make deploy
```

#### Using your own Runners

When using your own Runners, GitLab Runner runs only one job at a time by default (see the
`concurrent` flag in [Runner global settings](https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-global-section)
for more information).

Jobs will run on your own Runners in parallel only if:

- Run on different Runners.
- The Runner's `concurrent` setting has been changed.

### `only`/`except` (basic)

`only` and `except` are two parameters that set a job policy to limit when
jobs are created:

1. `only` defines the names of branches and tags for which the job will run.
1. `except` defines the names of branches and tags for which the job will
    **not** run.

There are a few rules that apply to the usage of job policy:

- `only` and `except` are inclusive. If both `only` and `except` are defined
   in a job specification, the ref is filtered by `only` and `except`.
- `only` and `except` allow the use of regular expressions ([supported regexp syntax](#supported-onlyexcept-regexp-syntax)).
- `only` and `except` allow to specify a repository path to filter jobs for
   forks.

In addition, `only` and `except` allow the use of special keywords:

| **Value** |  **Description**  |
| --------- |  ---------------- |
| `branches`       | When a git reference of a pipeline is a branch.  |
| `tags`           | When a git reference of a pipeline is a tag.  |
| `api`            | When pipeline has been triggered by a second pipelines API (not triggers API).  |
| `external`       | When using CI services other than GitLab. |
| `pipelines`      | For multi-project triggers, created using the API with `CI_JOB_TOKEN`. |
| `pushes`         | Pipeline is triggered by a `git push` by the user. |
| `schedules`      | For [scheduled pipelines][schedules]. |
| `triggers`       | For pipelines created using a trigger token. |
| `web`            | For pipelines created using **Run pipeline** button in GitLab UI (under your project's **Pipelines**). |
| `merge_requests` | When a merge request is created or updated (See [pipelines for merge requests](../merge_request_pipelines/index.md)). |
| `chats`          | For jobs created using a [GitLab ChatOps](../chatops/README.md) command. |

In the example below, `job` will run only for refs that start with `issue-`,
whereas all branches will be skipped:

```yaml
job:
  # use regexp
  only:
    - /^issue-.*$/
  # use special keyword
  except:
    - branches
```

Pattern matching is case-sensitive by default. Use `i` flag modifier, like
`/pattern/i` to make a pattern case-insensitive:

```yaml
job:
  # use regexp
  only:
    - /^issue-.*$/i
  # use special keyword
  except:
    - branches
```

In this example, `job` will run only for refs that are tagged, or if a build is
explicitly requested via an API trigger or a [Pipeline Schedule][schedules]:

```yaml
job:
  # use special keywords
  only:
    - tags
    - triggers
    - schedules
```

The repository path can be used to have jobs executed only for the parent
repository and not forks:

```yaml
job:
  only:
    - branches@gitlab-org/gitlab-ce
  except:
    - master@gitlab-org/gitlab-ce
    - /^release/.*$/@gitlab-org/gitlab-ce
```

The above example will run `job` for all branches on `gitlab-org/gitlab-ce`,
except `master` and those with names prefixed with `release/`.

If a job does not have an `only` rule, `only: ['branches', 'tags']` is set by
default. If it doesn't have an `except` rule, it is empty.

For example,

```yaml
job:
  script: echo 'test'
```

is translated to:

```yaml
job:
  script: echo 'test'
  only: ['branches', 'tags']
```

#### Regular expressions

Because `@` is used to denote the beginning of a ref's repository path,
matching a ref name containing the `@` character in a regular expression
requires the use of the hex character code match `\x40`.

Only the tag or branch name can be matched by a regular expression.
The repository path, if given, is always matched literally.

If a regular expression shall be used to match the tag or branch name,
the entire ref name part of the pattern has to be a regular expression,
and must be surrounded by `/`.
(With regular expression flags appended after the closing `/`.)
So `issue-/.*/` won't work to match all tag names or branch names
that begin with `issue-`.

TIP: **Tip**
Use anchors `^` and `$` to avoid the regular expression
matching only a substring of the tag name or branch name.
For example, `/^issue-.*$/` is equivalent to `/^issue-/`,
while just `/issue/` would also match a branch called `severe-issues`.

### Supported `only`/`except` regexp syntax

CAUTION: **Warning:**
This is a breaking change that was introduced with GitLab 11.9.4.

In GitLab 11.9.4, GitLab begun internally converting regexp used
in `only` and `except` parameters to [RE2](https://github.com/google/re2/wiki/Syntax).

This means that only subset of features provided by [Ruby Regexp](https://ruby-doc.org/core/Regexp.html)
is supported. [RE2](https://github.com/google/re2/wiki/Syntax) limits the set of features
provided due to computational complexity, which means some features became unavailable in GitLab 11.9.4.
For example, negative lookaheads.

For GitLab versions from 11.9.7 and up to GitLab 12.0, GitLab provides a feature flag that can be
enabled by administrators that allows users to use unsafe regexp syntax. This brings compatibility
with previously allowed syntax version and allows users to gracefully migrate to the new syntax.

```ruby
Feature.enable(:allow_unsafe_ruby_regexp)
```

### `only`/`except` (advanced)

CAUTION: **Warning:**
This an _alpha_ feature, and it is subject to change at any time without
prior notice!

GitLab supports both simple and complex strategies, so it's possible to use an
array and a hash configuration scheme.

Four keys are available:

- `refs`
- `variables`
- `changes`
- `kubernetes`

If you use multiple keys under `only` or `except`, they act as an AND. The logic is:

> (any of refs) AND (any of variables) AND (any of changes) AND (if kubernetes is active)

#### `only:refs`/`except:refs`

> `refs` policy introduced in GitLab 10.0.

The `refs` strategy can take the same values as the
[simplified only/except configuration](#onlyexcept-basic).

In the example below, the `deploy` job is going to be created only when the
pipeline has been [scheduled][schedules] or runs for the `master` branch:

```yaml
deploy:
  only:
    refs:
      - master
      - schedules
```

#### `only:kubernetes`/`except:kubernetes`

> `kubernetes` policy introduced in GitLab 10.0.

The `kubernetes` strategy accepts only the `active` keyword.

In the example below, the `deploy` job is going to be created only when the
Kubernetes service is active in the project:

```yaml
deploy:
  only:
    kubernetes: active
```

#### `only:variables`/`except:variables`

> `variables` policy introduced in GitLab 10.7.

The `variables` keyword is used to define variables expressions. In other words,
you can use predefined variables / project / group or
environment-scoped variables to define an expression GitLab is going to
evaluate in order to decide whether a job should be created or not.

Examples of using variables expressions:

```yaml
deploy:
  script: cap staging deploy
  only:
    refs:
      - branches
    variables:
      - $RELEASE == "staging"
      - $STAGING
```

Another use case is excluding jobs depending on a commit message:

```yaml
end-to-end:
  script: rake test:end-to-end
  except:
    variables:
      - $CI_COMMIT_MESSAGE =~ /skip-end-to-end-tests/
```

Learn more about [variables expressions](../variables/README.md#environment-variables-expressions).

#### `only:changes`/`except:changes`

> `changes` policy [introduced][ce-19232] in GitLab 11.4.

Using the `changes` keyword with `only` or `except` makes it possible to define if
a job should be created based on files modified by a git push event.

For example:

```yaml
docker build:
  script: docker build -t my-image:$CI_COMMIT_REF_SLUG .
  only:
    changes:
      - Dockerfile
      - docker/scripts/*
      - dockerfiles/**/*
      - more_scripts/*.{rb,py,sh}
```

In the scenario above, when pushing multiple commits to GitLab to an existing
branch, GitLab creates and triggers the `docker build` job, provided that one of the
commits contains changes to any of the following:

- The `Dockerfile` file.
- Any of the files inside `docker/scripts/` directory.
- Any of the files and subdirectories inside the `dockerfiles` directory.
- Any of the files with `rb`, `py`, `sh` extensions inside the `more_scripts` directory.

You can also use glob patterns to match multiple files in either the root directory of the repo, or in _any_ directory within the repo. For example:

```yaml
test:
  script: npm run test
  only:
    changes:
      - "*.json"
      - "**/*.sql"
```

NOTE: **Note:**
In the example above, the expressions are wrapped double quotes because they are glob patterns. GitLab will fail to parse `.gitlab-ci.yml` files with unwrapped glob patterns.

The following example will skip the CI job if a change is detected in any file in the root directory of the repo with a `.md` extension:

```yaml
build:
  script: npm run build
  except:
    changes:
      - "*.md"
```

CAUTION: **Warning:**
There are some caveats when using this feature with new branches and tags. See
the section below.

##### Using `changes` with new branches and tags

When pushing a **new** branch or a **new** tag to GitLab, the policy always
evaluates to true and GitLab will create a job. This feature is not connected
with merge requests yet and, because GitLab is creating pipelines before a user
can create a merge request, it is unknown what the target branch is at this point.

##### Using `changes` with `merge_requests`

With [pipelines for merge requests](../merge_request_pipelines/index.md),
it is possible to define a job to be created based on files modified
in a merge request.

For example:

```yaml
docker build service one:
  script: docker build -t my-service-one-image:$CI_COMMIT_REF_SLUG .
  only:
    refs:
      - merge_requests
    changes:
      - Dockerfile
      - service-one/**/*
```

In the scenario above, if a merge request is created or updated that changes
either files in `service-one` directory or the `Dockerfile`, GitLab creates
and triggers the `docker build service one` job.

### `tags`

`tags` is used to select specific Runners from the list of all Runners that are
allowed to run this project.

During the registration of a Runner, you can specify the Runner's tags, for
example `ruby`, `postgres`, `development`.

`tags` allow you to run jobs with Runners that have the specified tags
assigned to them:

```yaml
job:
  tags:
    - ruby
    - postgres
```

The specification above, will make sure that `job` is built by a Runner that
has both `ruby` AND `postgres` tags defined.

Tags are also a great way to run different jobs on different platforms, for
example, given an OS X Runner with tag `osx` and Windows Runner with tag
`windows`, the following jobs run on respective platforms:

```yaml
windows job:
  stage:
    - build
  tags:
    - windows
  script:
    - echo Hello, %USERNAME%!

osx job:
  stage:
    - build
  tags:
    - osx
  script:
    - echo "Hello, $USER!"
```

### `allow_failure`

`allow_failure` allows a job to fail without impacting the rest of the CI
suite.
The default value is `false`, except for [manual](#whenmanual) jobs.

When enabled and the job fails, the job will show an orange warning in the UI.
However, the logical flow of the pipeline will consider the job a
success/passed, and is not blocked.

Assuming all other jobs are successful, the job's stage and its pipeline will
show the same orange warning. However, the associated commit will be marked
"passed", without warnings.

In the example below, `job1` and `job2` will run in parallel, but if `job1`
fails, it will not stop the next stage from running, since it's marked with
`allow_failure: true`:

```yaml
job1:
  stage: test
  script:
    - execute_script_that_will_fail
  allow_failure: true

job2:
  stage: test
  script:
    - execute_script_that_will_succeed

job3:
  stage: deploy
  script:
    - deploy_to_staging
```

### `when`

`when` is used to implement jobs that are run in case of failure or despite the
failure.

`when` can be set to one of the following values:

1. `on_success` - execute job only when all jobs from prior stages
    succeed (or are considered succeeding because they are marked
    `allow_failure`). This is the default.
1. `on_failure` - execute job only when at least one job from prior stages
    fails.
1. `always` - execute job regardless of the status of jobs from prior stages.
1. `manual` - execute job manually (added in GitLab 8.10). Read about
    [manual actions](#whenmanual) below.

For example:

```yaml
stages:
  - build
  - cleanup_build
  - test
  - deploy
  - cleanup

build_job:
  stage: build
  script:
    - make build

cleanup_build_job:
  stage: cleanup_build
  script:
    - cleanup build when failed
  when: on_failure

test_job:
  stage: test
  script:
    - make test

deploy_job:
  stage: deploy
  script:
    - make deploy
  when: manual

cleanup_job:
  stage: cleanup
  script:
    - cleanup after jobs
  when: always
```

The above script will:

1. Execute `cleanup_build_job` only when `build_job` fails.
1. Always execute `cleanup_job` as the last step in pipeline regardless of
   success or failure.
1. Allow you to manually execute `deploy_job` from GitLab's UI.

#### `when:manual`

> - Introduced in GitLab 8.10.
> - Blocking manual actions were introduced in GitLab 9.0.
> - Protected actions were introduced in GitLab 9.2.

Manual actions are a special type of job that are not executed automatically,
they need to be explicitly started by a user. An example usage of manual actions
would be a deployment to a production environment. Manual actions can be started
from the pipeline, job, environment, and deployment views. Read more at the
[environments documentation](../environments.md#configuring-manual-deployments).

Manual actions can be either optional or blocking. Blocking manual actions will
block the execution of the pipeline at the stage this action is defined in. It's
possible to resume execution of the pipeline when someone executes a blocking
manual action by clicking a _play_ button.

When a pipeline is blocked, it will not be merged if Merge When Pipeline Succeeds
is set. Blocked pipelines also do have a special status, called _manual_.
Manual actions are non-blocking by default. If you want to make manual action
blocking, it is necessary to add `allow_failure: false` to the job's definition
in `.gitlab-ci.yml`.

Optional manual actions have `allow_failure: true` set by default and their
Statuses do not contribute to the overall pipeline status. So, if a manual
action fails, the pipeline will eventually succeed.

Manual actions are considered to be write actions, so permissions for
[protected branches](../../user/project/protected_branches.md) are used when
a user wants to trigger an action. In other words, in order to trigger a manual
action assigned to a branch that the pipeline is running for, the user needs to
have the ability to merge to this branch.

#### `when:delayed`

> [Introduced](https://gitlab.com/gitlab-org/gitlab-ce/merge_requests/21767) in GitLab 11.4.

Delayed job are for executing scripts after a certain period.
This is useful if you want to avoid jobs entering `pending` state immediately.

You can set the period with `start_in` key. The value of `start_in` key is an elapsed time in seconds, unless a unit is
provided. `start_in` key must be less than or equal to one hour. Examples of valid values include:

- `10 seconds`
- `30 minutes`
- `1 hour`

When there is a delayed job in a stage, the pipeline will not progress until the delayed job has finished.
This means this keyword can also be used for inserting delays between different stages.

The timer of a delayed job starts immediately after the previous stage has completed.
Similar to other types of jobs, a delayed job's timer will not start unless the previous stage passed.

The following example creates a job named `timed rollout 10%` that is executed 30 minutes after the previous stage has completed:

```yaml
timed rollout 10%:
  stage: deploy
  script: echo 'Rolling out 10% ...'
  when: delayed
  start_in: 30 minutes
```

You can stop the active timer of a delayed job by clicking the **Unschedule** button.
This job will never be executed in the future unless you execute the job manually.

You can start a delayed job immediately by clicking the **Play** button.
GitLab runner will pick your job soon and start the job.

### `environment`

> - Introduced in GitLab 8.9.
> - You can read more about environments and find more examples in the
>   [documentation about environments][environment].

`environment` is used to define that a job deploys to a specific environment.
If `environment` is specified and no environment under that name exists, a new
one will be created automatically.

In its simplest form, the `environment` keyword can be defined like:

```yaml
deploy to production:
  stage: deploy
  script: git push production HEAD:master
  environment:
    name: production
```

In the above example, the `deploy to production` job will be marked as doing a
deployment to the `production` environment.

#### `environment:name`

> - Introduced in GitLab 8.11.
> - Before GitLab 8.11, the name of an environment could be defined as a string like
>   `environment: production`. The recommended way now is to define it under the
>   `name` keyword.
> - The `name` parameter can use any of the defined CI variables,
>   including predefined, secure variables and `.gitlab-ci.yml` [`variables`](#variables).
>   You however cannot use variables defined under `script`.

The `environment` name can contain:

- letters
- digits
- spaces
- `-`
- `_`
- `/`
- `$`
- `{`
- `}`

Common names are `qa`, `staging`, and `production`, but you can use whatever
name works with your workflow.

Instead of defining the name of the environment right after the `environment`
keyword, it is also possible to define it as a separate value. For that, use
the `name` keyword under `environment`:

```yaml
deploy to production:
  stage: deploy
  script: git push production HEAD:master
  environment:
    name: production
```

#### `environment:url`

> - Introduced in GitLab 8.11.
> - Before GitLab 8.11, the URL could be added only in GitLab's UI. The
>   recommended way now is to define it in `.gitlab-ci.yml`.
> - The `url` parameter can use any of the defined CI variables,
>   including predefined, secure variables and `.gitlab-ci.yml` [`variables`](#variables).
>   You however cannot use variables defined under `script`.

This is an optional value that when set, it exposes buttons in various places
in GitLab which when clicked take you to the defined URL.

In the example below, if the job finishes successfully, it will create buttons
in the merge requests and in the environments/deployments pages which will point
to `https://prod.example.com`.

```yaml
deploy to production:
  stage: deploy
  script: git push production HEAD:master
  environment:
    name: production
    url: https://prod.example.com
```

#### `environment:on_stop`

> - [Introduced][ce-6669] in GitLab 8.13.
> - Starting with GitLab 8.14, when you have an environment that has a stop action
>   defined, GitLab will automatically trigger a stop action when the associated
>   branch is deleted.

Closing (stopping) environments can be achieved with the `on_stop` keyword defined under
`environment`. It declares a different job that runs in order to close
the environment.

Read the `environment:action` section for an example.

#### `environment:action`

> [Introduced][ce-6669] in GitLab 8.13.

The `action` keyword is to be used in conjunction with `on_stop` and is defined
in the job that is called to close the environment.

Take for instance:

```yaml
review_app:
  stage: deploy
  script: make deploy-app
  environment:
    name: review
    on_stop: stop_review_app

stop_review_app:
  stage: deploy
  variables:
    GIT_STRATEGY: none  
  script: make delete-app
  when: manual
  environment:
    name: review
    action: stop
```

In the above example we set up the `review_app` job to deploy to the `review`
environment, and we also defined a new `stop_review_app` job under `on_stop`.
Once the `review_app` job is successfully finished, it will trigger the
`stop_review_app` job based on what is defined under `when`. In this case we
set it up to `manual` so it will need a [manual action](#whenmanual) via
GitLab's web interface in order to run.

Also in the example, `GIT_STRATEGY` is set to `none` so that GitLab Runner won’t
try to check out the code after the branch is deleted when the `stop_review_app`
job is [automatically triggered](../environments.md#automatically-stopping-an-environment).

The `stop_review_app` job is **required** to have the following keywords defined:

- `when` - [reference](#when)
- `environment:name`
- `environment:action`
- `stage` should be the same as the `review_app` in order for the environment
  to stop automatically when the branch is deleted

#### Dynamic environments

> - [Introduced][ce-6323] in GitLab 8.12 and GitLab Runner 1.6.
> - The `$CI_ENVIRONMENT_SLUG` was [introduced][ce-7983] in GitLab 8.15.
> - The `name` and `url` parameters can use any of the defined CI variables,
>   including predefined, secure variables and `.gitlab-ci.yml` [`variables`](#variables).
>   You however cannot use variables defined under `script`.

For example:

```yaml
deploy as review app:
  stage: deploy
  script: make deploy
  environment:
    name: review/$CI_COMMIT_REF_NAME
    url: https://$CI_ENVIRONMENT_SLUG.example.com/
```

The `deploy as review app` job will be marked as deployment to dynamically
create the `review/$CI_COMMIT_REF_NAME` environment, where `$CI_COMMIT_REF_NAME`
is an [environment variable][variables] set by the Runner. The
`$CI_ENVIRONMENT_SLUG` variable is based on the environment name, but suitable
for inclusion in URLs. In this case, if the `deploy as review app` job was run
in a branch named `pow`, this environment would be accessible with an URL like
`https://review-pow.example.com/`.

This of course implies that the underlying server which hosts the application
is properly configured.

The common use case is to create dynamic environments for branches and use them
as Review Apps. You can see a simple example using Review Apps at
<https://gitlab.com/gitlab-examples/review-apps-nginx/>.

### `cache`

> - Introduced in GitLab Runner v0.7.0.
> - `cache` can be set globally and per-job.
> - From GitLab 9.0, caching is enabled and shared between pipelines and jobs
>   by default.
> - From GitLab 9.2, caches are restored before [artifacts](#artifacts).

TIP: **Learn more:**
Read how caching works and find out some good practices in the
[caching dependencies documentation](../caching/index.md).

`cache` is used to specify a list of files and directories which should be
cached between jobs. You can only use paths that are within the project
workspace.

If `cache` is defined outside the scope of jobs, it means it is set
globally and all jobs will use that definition.

#### `cache:paths`

Use the `paths` directive to choose which files or directories will be cached.
Wildcards can be used as well.

Cache all files in `binaries` that end in `.apk` and the `.config` file:

```yaml
rspec:
  script: test
  cache:
    paths:
      - binaries/*.apk
      - .config
```

Locally defined cache overrides globally defined options. The following `rspec`
job will cache only `binaries/`:

```yaml
cache:
  paths:
    - my/files

rspec:
  script: test
  cache:
    key: rspec
    paths:
      - binaries/
```

Note that since cache is shared between jobs, if you're using different
paths for different jobs, you should also set a different **cache:key**
otherwise cache content can be overwritten.

#### `cache:key`

> Introduced in GitLab Runner v1.0.0.

Since the cache is shared between jobs, if you're using different
paths for different jobs, you should also set a different `cache:key`
otherwise cache content can be overwritten.

The `key` directive allows you to define the affinity of caching between jobs,
allowing to have a single cache for all jobs, cache per-job, cache per-branch
or any other way that fits your workflow. This way, you can fine tune caching,
allowing you to cache data between different jobs or even different branches.

The `cache:key` variable can use any of the
[predefined variables](../variables/README.md), and the default key, if not
set, is just literal `default` which means everything is shared between each
pipelines and jobs by default, starting from GitLab 9.0.

NOTE: **Note:**
The `cache:key` variable cannot contain the `/` character, or the equivalent
URI-encoded `%2F`; a value made only of dots (`.`, `%2E`) is also forbidden.

For example, to enable per-branch caching:

```yaml
cache:
  key: "$CI_COMMIT_REF_SLUG"
  paths:
    - binaries/
```

If you use **Windows Batch** to run your shell scripts you need to replace
`$` with `%`:

```yaml
cache:
  key: "%CI_COMMIT_REF_SLUG%"
  paths:
    - binaries/
```

#### `cache:untracked`

Set `untracked: true` to cache all files that are untracked in your Git
repository:

```yaml
rspec:
  script: test
  cache:
    untracked: true
```

Cache all Git untracked files and files in `binaries`:

```yaml
rspec:
  script: test
  cache:
    untracked: true
    paths:
      - binaries/
```

#### `cache:policy`

> Introduced in GitLab 9.4.

The default behaviour of a caching job is to download the files at the start of
execution, and to re-upload them at the end. This allows any changes made by the
job to be persisted for future runs, and is known as the `pull-push` cache
policy.

If you know the job doesn't alter the cached files, you can skip the upload step
by setting `policy: pull` in the job specification. Typically, this would be
twinned with an ordinary cache job at an earlier stage to ensure the cache
is updated from time to time:

```yaml
stages:
  - setup
  - test

prepare:
  stage: setup
  cache:
    key: gems
    paths:
      - vendor/bundle
  script:
    - bundle install --deployment

rspec:
  stage: test
  cache:
    key: gems
    paths:
      - vendor/bundle
    policy: pull
  script:
    - bundle exec rspec ...
```

This helps to speed up job execution and reduce load on the cache server,
especially when you have a large number of cache-using jobs executing in
parallel.

Additionally, if you have a job that unconditionally recreates the cache without
reference to its previous contents, you can use `policy: push` in that job to
skip the download step.

### `artifacts`

> - Introduced in GitLab Runner v0.7.0 for non-Windows platforms.
> - Windows support was added in GitLab Runner v.1.0.0.
> - From GitLab 9.2, caches are restored before artifacts.
> - Not all executors are [supported](https://docs.gitlab.com/runner/executors/#compatibility-chart).
> - Job artifacts are only collected for successful jobs by default.

`artifacts` is used to specify a list of files and directories which should be
attached to the job when it [succeeds, fails, or always](#artifactswhen).

The artifacts will be sent to GitLab after the job finishes and will
be available for download in the GitLab UI.

[Read more about artifacts](../../user/project/pipelines/job_artifacts.md).

#### `artifacts:paths`

You can only use paths that are within the project workspace. To pass artifacts
between different jobs, see [dependencies](#dependencies).

Send all files in `binaries` and `.config`:

```yaml
artifacts:
  paths:
    - binaries/
    - .config
```

To disable artifact passing, define the job with empty [dependencies](#dependencies):

```yaml
job:
  stage: build
  script: make build
  dependencies: []
```

You may want to create artifacts only for tagged releases to avoid filling the
build server storage with temporary build artifacts.

Create artifacts only for tags (`default-job` will not create artifacts):

```yaml
default-job:
  script:
    - mvn test -U
  except:
    - tags

release-job:
  script:
    - mvn package -U
  artifacts:
    paths:
      - target/*.war
  only:
    - tags
```

#### `artifacts:name`

> Introduced in GitLab 8.6 and GitLab Runner v1.1.0.

The `name` directive allows you to define the name of the created artifacts
archive. That way, you can have a unique name for every archive which could be
useful when you'd like to download the archive from GitLab. The `artifacts:name`
variable can make use of any of the [predefined variables](../variables/README.md).
The default name is `artifacts`, which becomes `artifacts.zip` when downloaded.

NOTE: **Note:**
If your branch-name contains forward slashes
(e.g. `feature/my-feature`) it is advised to use `$CI_COMMIT_REF_SLUG`
instead of `$CI_COMMIT_REF_NAME` for proper naming of the artifact.

To create an archive with a name of the current job:

```yaml
job:
  artifacts:
    name: "$CI_JOB_NAME"
    paths:
      - binaries/
```

To create an archive with a name of the current branch or tag including only
the binaries directory:

```yaml
job:
  artifacts:
    name: "$CI_COMMIT_REF_NAME"
    paths:
      - binaries/
```

To create an archive with a name of the current job and the current branch or
tag including only the binaries directory:

```yaml
job:
  artifacts:
    name: "$CI_JOB_NAME-$CI_COMMIT_REF_NAME"
    paths:
      - binaries/
```

To create an archive with a name of the current [stage](#stages) and branch name:

```yaml
job:
  artifacts:
    name: "$CI_JOB_STAGE-$CI_COMMIT_REF_NAME"
    paths:
      - binaries/
```

---

If you use **Windows Batch** to run your shell scripts you need to replace
`$` with `%`:

```yaml
job:
  artifacts:
    name: "%CI_JOB_STAGE%-%CI_COMMIT_REF_NAME%"
    paths:
      - binaries/
```

If you use **Windows PowerShell** to run your shell scripts you need to replace
`$` with `$env:`:

```yaml
job:
  artifacts:
    name: "$env:CI_JOB_STAGE-$env:CI_COMMIT_REF_NAME"
    paths:
      - binaries/
```

#### `artifacts:untracked`

`artifacts:untracked` is used to add all Git untracked files as artifacts (along
to the paths defined in `artifacts:paths`).

NOTE: **Note:**
`artifacts:untracked` ignores configuration in the repository's `.gitignore` file.

Send all Git untracked files:

```yaml
artifacts:
  untracked: true
```

Send all Git untracked files and files in `binaries`:

```yaml
artifacts:
  untracked: true
  paths:
    - binaries/
```

#### `artifacts:when`

> Introduced in GitLab 8.9 and GitLab Runner v1.3.0.

`artifacts:when` is used to upload artifacts on job failure or despite the
failure.

`artifacts:when` can be set to one of the following values:

1. `on_success` - upload artifacts only when the job succeeds. This is the default.
1. `on_failure` - upload artifacts only when the job fails.
1. `always` - upload artifacts regardless of the job status.

To upload artifacts only when job fails:

```yaml
job:
  artifacts:
    when: on_failure
```

#### `artifacts:expire_in`

> Introduced in GitLab 8.9 and GitLab Runner v1.3.0.

`expire_in` allows you to specify how long artifacts should live before they
expire and therefore deleted, counting from the time they are uploaded and
stored on GitLab. If the expiry time is not defined, it defaults to the
[instance wide setting](../../user/admin_area/settings/continuous_integration.md#default-artifacts-expiration-core-only)
(30 days by default, forever on GitLab.com).

You can use the **Keep** button on the job page to override expiration and
keep artifacts forever.

After their expiry, artifacts are deleted hourly by default (via a cron job),
and are not accessible anymore.

The value of `expire_in` is an elapsed time in seconds, unless a unit is
provided. Examples of parsable values:

- '42'
- '3 mins 4 sec'
- '2 hrs 20 min'
- '2h20min'
- '6 mos 1 day'
- '47 yrs 6 mos and 4d'
- '3 weeks and 2 days'

To expire artifacts 1 week after being uploaded:

```yaml
job:
  artifacts:
    expire_in: 1 week
```

#### `artifacts:reports`

> [Introduced](https://gitlab.com/gitlab-org/gitlab-ce/merge_requests/20390) in
GitLab 11.2. Requires GitLab Runner 11.2 and above.

The `reports` keyword is used for collecting test reports from jobs and
exposing them in GitLab's UI (merge requests, pipeline views). Read how to use
this with [JUnit reports](#artifactsreportsjunit).

NOTE: **Note:**
The test reports are collected regardless of the job results (success or failure).
You can use [`artifacts:expire_in`](#artifactsexpire_in) to set up an expiration
date for their artifacts.

NOTE: **Note:**
If you also want the ability to browse the report output files, include the
[`artifacts:paths`](#artifactspaths) keyword.

##### `artifacts:reports:junit`

> [Introduced](https://gitlab.com/gitlab-org/gitlab-ce/merge_requests/20390) in
GitLab 11.2. Requires GitLab Runner 11.2 and above.

The `junit` report collects [JUnit XML files](https://www.ibm.com/support/knowledgecenter/en/SSQ2R2_14.1.0/com.ibm.rsar.analysis.codereview.cobol.doc/topics/cac_useresults_junit.html)
as artifacts. Although JUnit was originally developed in Java, there are many
[third party ports](https://en.wikipedia.org/wiki/JUnit#Ports) for other
languages like JavaScript, Python, Ruby, etc.

See [JUnit test reports](../junit_test_reports.md) for more details and examples.
Below is an example of collecting a JUnit XML file from Ruby's RSpec test tool:

```yaml
rspec:
  stage: test
  script:
  - bundle install
  - rspec --format RspecJunitFormatter --out rspec.xml
  artifacts:
    reports:
      junit: rspec.xml
```

The collected JUnit reports will be uploaded to GitLab as an artifact and will
be automatically shown in merge requests.

NOTE: **Note:**
In case the JUnit tool you use exports to multiple XML files, you can specify
multiple test report paths within a single job and they will be automatically
concatenated into a single file. Use a filename pattern (`junit: rspec-*.xml`),
an array of filenames (`junit: [rspec-1.xml, rspec-2.xml, rspec-3.xml]`), or a
combination thereof (`junit: [rspec.xml, test-results/TEST-*.xml]`).

##### `artifacts:reports:codequality` **[STARTER]**

> Introduced in GitLab 11.5. Requires GitLab Runner 11.5 and above.

The `codequality` report collects [CodeQuality issues](../../user/project/merge_requests/code_quality.md)
as artifacts.

The collected Code Quality report will be uploaded to GitLab as an artifact and will
be automatically shown in merge requests.

##### `artifacts:reports:sast` **[ULTIMATE]**

> Introduced in GitLab 11.5. Requires GitLab Runner 11.5 and above.

The `sast` report collects [SAST vulnerabilities](../../user/application_security/sast/index.md)
as artifacts.

The collected SAST report will be uploaded to GitLab as an artifact and will
be automatically shown in merge requests, pipeline view and provide data for security
dashboards.

##### `artifacts:reports:dependency_scanning` **[ULTIMATE]**

> Introduced in GitLab 11.5. Requires GitLab Runner 11.5 and above.

The `dependency_scanning` report collects [Dependency Scanning vulnerabilities](../../user/application_security/dependency_scanning/index.md)
as artifacts.

The collected Dependency Scanning report will be uploaded to GitLab as an artifact and will
be automatically shown in merge requests, pipeline view and provide data for security
dashboards.

##### `artifacts:reports:container_scanning` **[ULTIMATE]**

> Introduced in GitLab 11.5. Requires GitLab Runner 11.5 and above.

The `container_scanning` report collects [Container Scanning vulnerabilities](../../user/application_security/container_scanning/index.md)
as artifacts.

The collected Container Scanning report will be uploaded to GitLab as an artifact and will
be automatically shown in merge requests, pipeline view and provide data for security
dashboards.

##### `artifacts:reports:dast` **[ULTIMATE]**

> Introduced in GitLab 11.5. Requires GitLab Runner 11.5 and above.

The `dast` report collects [DAST vulnerabilities](../../user/application_security/dast/index.md)
as artifacts.

The collected DAST report will be uploaded to GitLab as an artifact and will
be automatically shown in merge requests, pipeline view and provide data for security
dashboards.

##### `artifacts:reports:license_management` **[ULTIMATE]**

> Introduced in GitLab 11.5. Requires GitLab Runner 11.5 and above.

The `license_management` report collects [Licenses](../../user/project/merge_requests/license_management.md)
as artifacts.

The collected License Management report will be uploaded to GitLab as an artifact and will
be automatically shown in merge requests, pipeline view and provide data for security
dashboards.

##### `artifacts:reports:performance` **[PREMIUM]**

> Introduced in GitLab 11.5. Requires GitLab Runner 11.5 and above.

The `performance` report collects [Performance metrics](../../user/project/merge_requests/browser_performance_testing.md)
as artifacts.

The collected Performance report will be uploaded to GitLab as an artifact and will
be automatically shown in merge requests.

##### `artifacts:reports:metrics` **[PREMIUM]**

> Introduced in GitLab 11.10.

The `metrics` report collects [Metrics](../../ci/metrics_reports.md)
as artifacts.

The collected Metrics report will be uploaded to GitLab as an artifact and will
be automatically shown in merge requests.

### `dependencies`

> Introduced in GitLab 8.6 and GitLab Runner v1.1.1.

This feature should be used in conjunction with [`artifacts`](#artifacts) and
allows you to define the artifacts to pass between different jobs.

Note that `artifacts` from all previous [stages](#stages) are passed by default.

To use this feature, define `dependencies` in context of the job and pass
a list of all previous jobs from which the artifacts should be downloaded.
You can only define jobs from stages that are executed before the current one.
An error will be shown if you define jobs from the current stage or next ones.
Defining an empty array will skip downloading any artifacts for that job.
The status of the previous job is not considered when using `dependencies`, so
if it failed or it is a manual job that was not run, no error occurs.

---

In the following example, we define two jobs with artifacts, `build:osx` and
`build:linux`. When the `test:osx` is executed, the artifacts from `build:osx`
will be downloaded and extracted in the context of the build. The same happens
for `test:linux` and artifacts from `build:linux`.

The job `deploy` will download artifacts from all previous jobs because of
the [stage](#stages) precedence:

```yaml
build:osx:
  stage: build
  script: make build:osx
  artifacts:
    paths:
      - binaries/

build:linux:
  stage: build
  script: make build:linux
  artifacts:
    paths:
      - binaries/

test:osx:
  stage: test
  script: make test:osx
  dependencies:
    - build:osx

test:linux:
  stage: test
  script: make test:linux
  dependencies:
    - build:linux

deploy:
  stage: deploy
  script: make deploy
```

#### When a dependent job will fail

> Introduced in GitLab 10.3.

If the artifacts of the job that is set as a dependency have been
[expired](#artifactsexpire_in) or
[erased](../../user/project/pipelines/job_artifacts.md#erasing-artifacts), then
the dependent job will fail.

NOTE: **Note:**
You can ask your administrator to
[flip this switch](../../administration/job_artifacts.md#validation-for-dependencies)
and bring back the old behavior.

### `coverage`

> [Introduced][ce-7447] in GitLab 8.17.

`coverage` allows you to configure how code coverage will be extracted from the
job output.

Regular expressions are the only valid kind of value expected here. So, using
surrounding `/` is mandatory in order to consistently and explicitly represent
a regular expression string. You must escape special characters if you want to
match them literally.

A simple example:

```yaml
job1:
  script: rspec
  coverage: '/Code coverage: \d+\.\d+/'
```

### `retry`

> [Introduced][ce-12909] in GitLab 9.5.
> [Behaviour expanded](https://gitlab.com/gitlab-org/gitlab-ce/merge_requests/21758)
> in GitLab 11.5 to control on which failures to retry.

`retry` allows you to configure how many times a job is going to be retried in
case of a failure.

When a job fails and has `retry` configured, it is going to be processed again
up to the amount of times specified by the `retry` keyword.

If `retry` is set to 2, and a job succeeds in a second run (first retry), it won't be retried
again. `retry` value has to be a positive integer, equal or larger than 0, but
lower or equal to 2 (two retries maximum, three runs in total).

A simple example to retry in all failure cases:

```yaml
test:
  script: rspec
  retry: 2
```

By default, a job will be retried on all failure cases. To have a better control
on which failures to retry, `retry` can be a hash with the following keys:

- `max`: The maximum number of retries.
- `when`: The failure cases to retry.

To retry only runner system failures at maximum two times:

```yaml
test:
  script: rspec
  retry:
    max: 2
    when: runner_system_failure
```

If there is another failure, other than a runner system failure, the job will
not be retried.

To retry on multiple failure cases, `when` can also be an array of failures:

```yaml
test:
  script: rspec
  retry:
    max: 2
    when:
      - runner_system_failure
      - stuck_or_timeout_failure
```

Possible values for `when` are:

<!--
  Please make sure to update `RETRY_WHEN_IN_DOCUMENTATION` array in
  `spec/lib/gitlab/ci/config/entry/retry_spec.rb` if you change any of
  the documented values below. The test there makes sure that all documented
  values are really valid as a config option and therefore should always
  stay in sync with this documentation.
 -->

- `always`: Retry on any failure (default).
- `unknown_failure`: Retry when the failure reason is unknown.
- `script_failure`: Retry when the script failed.
- `api_failure`: Retry on API failure.
- `stuck_or_timeout_failure`: Retry when the job got stuck or timed out.
- `runner_system_failure`: Retry if there was a runner system failure (e.g. setting up the job failed).
- `missing_dependency_failure`: Retry if a dependency was missing.
- `runner_unsupported`: Retry if the runner was unsupported.

### `parallel`

> [Introduced](https://gitlab.com/gitlab-org/gitlab-ce/merge_requests/22631) in GitLab 11.5.

`parallel` allows you to configure how many instances of a job to run in
parallel. This value has to be greater than or equal to two (2) and less than or equal to 50.

This creates N instances of the same job that run in parallel. They're named
sequentially from `job_name 1/N` to `job_name N/N`.

For every job, `CI_NODE_INDEX` and `CI_NODE_TOTAL` [environment variables](../variables/README.md#predefined-environment-variables) are set.

A simple example:

```yaml
test:
  script: rspec
  parallel: 5
```

### `trigger` **[PREMIUM]**

> [Introduced](https://gitlab.com/gitlab-org/gitlab-ee/issues/8997) in [GitLab Premium](https://about.gitlab.com/pricing/) 11.8.

`trigger` allows you to define downstream pipeline trigger. When a job created
from `trigger` definition is started by GitLab, a downstream pipeline gets
created.

Learn more about [multi-project pipelines](../multi_project_pipelines.md#creating-multi-project-pipelines-from-gitlab-ciyml).

#### Simple `trigger` syntax

The most simple way to configure a downstream trigger to use `trigger` keyword
with a full path to a downstream project:

```yaml
rspec:
  stage: test
  script: bundle exec rspec

staging:
  stage: deploy
  trigger: my/deployment
```

#### Complex `trigger` syntax

It is possible to configure a branch name that GitLab will use to create
a downstream pipeline with:

```yaml
rspec:
  stage: test
  script: bundle exec rspec

staging:
  stage: deploy
  trigger:
    project: my/deployment
    branch: stable
```

### `include`

> - Introduced in [GitLab Premium](https://about.gitlab.com/pricing/) 10.5.
> - Available for Starter, Premium and Ultimate since 10.6.
> - [Moved](https://gitlab.com/gitlab-org/gitlab-ce/merge_requests/21603) to GitLab Core in 11.4.

Using the `include` keyword, you can allow the inclusion of external YAML files.
`include` requires the external YAML file to have the extensions `.yml` or `.yaml`,
otherwise the external file will not be included.

The files defined in `include` are:

- Deep merged with those in `.gitlab-ci.yml`.
- Always evaluated first and merged with the content of `.gitlab-ci.yml`,
  regardless of the position of the `include` keyword.

TIP: **Tip:**
Use merging to customize and override included CI/CD configurations with local
definitions.

NOTE: **Note:**
Using YAML aliases across different YAML files sourced by `include` is not
supported. You must only refer to aliases in the same file. Instead
of using YAML anchors, you can use the [`extends` keyword](#extends).

`include` supports four include methods:

- [`local`](#includelocal)
- [`file`](#includefile)
- [`template`](#includetemplate)
- [`remote`](#includeremote)

See [usage examples](#include-examples).

NOTE: **Note:**
`.gitlab-ci.yml` configuration included by all methods is evaluated at pipeline creation.
The configuration is a snapshot in time and persisted in the database. Any changes to
referenced `.gitlab-ci.yml` configuration will not be reflected in GitLab until the next pipeline is created.

#### `include:local`

`include:local` includes a file from the same repository as `.gitlab-ci.yml`.
It's referenced using full paths relative to the root directory (`/`).

You can only use files that are currently tracked by Git on the same branch
your configuration file is on. In other words, when using a `include:local`, make
sure that both `.gitlab-ci.yml` and the local file are on the same branch.

All [nested includes](#nested-includes) will be executed in the scope of the same project,
so it is possible to use local, project, remote or template includes.

NOTE: **Note:**
Including local files through Git submodules paths is not supported.

Example:

```yaml
include:
  - local: '/templates/.gitlab-ci-template.yml'
```

#### `include:file`

> [Introduced](https://gitlab.com/gitlab-org/gitlab-ce/issues/53903) in GitLab 11.7.

To include files from another private project under the same GitLab instance,
use `include:file`. This file is referenced using full  paths relative to the
root directory (`/`). For example:

```yaml
include:
  - project: 'my-group/my-project'
    file: '/templates/.gitlab-ci-template.yml'
```

You can also specify `ref`, with the default being the `HEAD` of the project:

```yaml
include:
  - project: 'my-group/my-project'
    ref: master
    file: '/templates/.gitlab-ci-template.yml'

  - project: 'my-group/my-project'
    ref: v1.0.0
    file: '/templates/.gitlab-ci-template.yml'

  - project: 'my-group/my-project'
    ref: 787123b47f14b552955ca2786bc9542ae66fee5b # Git SHA
    file: '/templates/.gitlab-ci-template.yml'
```

All [nested includes](#nested-includes) will be executed in the scope of the target project,
so it is possible to use local (relative to target project), project, remote
or template includes.

#### `include:template`

> [Introduced](https://gitlab.com/gitlab-org/gitlab-ce/issues/53445) in GitLab 11.7.

`include:template` can be used to include `.gitlab-ci.yml` templates that are
[shipped with GitLab](https://gitlab.com/gitlab-org/gitlab-ce/tree/master/lib/gitlab/ci/templates).

For example:

```yaml
# File sourced from GitLab's template collection
include:
  - template: Auto-DevOps.gitlab-ci.yml
```

All [nested includes](#nested-includes) will be executed only with the permission of the user,
so it is possible to use project, remote or template includes.

#### `include:remote`

`include:remote` can be used to include a file from a different location,
using HTTP/HTTPS, referenced by using the full URL. The remote file must be
publicly accessible through a simple GET request as authentication schemas
in the remote URL is not supported. For example:

```yaml
include:
  - remote: 'https://gitlab.com/awesome-project/raw/master/.gitlab-ci-template.yml'
```

All nested includes will be executed without context as public user, so only another remote,
or public project, or template is allowed.

#### Nested includes

> [Introduced](https://gitlab.com/gitlab-org/gitlab-ce/issues/56836) in GitLab 11.9.

Nested includes allow you to compose a set of includes.
A total of 50 includes is allowed.
Duplicate includes are considered a configuration error.

#### `include` examples

Here are a few more `include` examples.

##### Single string or array of multiple values

You can include your extra YAML file(s) either as a single string or
an array of multiple values. The following examples are all valid.

Single string with the `include:local` method implied:

```yaml
include: '/templates/.after-script-template.yml'
```

Array with `include` method implied:

```yaml
include:
  - 'https://gitlab.com/awesome-project/raw/master/.before-script-template.yml'
  - '/templates/.after-script-template.yml'
```

Single string with `include` method specified explicitly:

```yaml
include:
  remote: 'https://gitlab.com/awesome-project/raw/master/.before-script-template.yml'
```

Array with `include:remote` being the single item:

```yaml
include:
  - remote: 'https://gitlab.com/awesome-project/raw/master/.before-script-template.yml'
```

Array with multiple `include` methods specified explicitly:

```yaml
include:
  - remote: 'https://gitlab.com/awesome-project/raw/master/.before-script-template.yml'
  - local: '/templates/.after-script-template.yml'
  - template: Auto-DevOps.gitlab-ci.yml
```

Array mixed syntax:

```yaml
include:
  - 'https://gitlab.com/awesome-project/raw/master/.before-script-template.yml'
  - '/templates/.after-script-template.yml'
  - template: Auto-DevOps.gitlab-ci.yml
  - project: 'my-group/my-project'
    ref: master
    file: '/templates/.gitlab-ci-template.yml'
```

##### Re-using a `before_script` template

In the following example, the content of `.before-script-template.yml` will be
automatically fetched and evaluated along with the content of `.gitlab-ci.yml`.

Content of `https://gitlab.com/awesome-project/raw/master/.before-script-template.yml`:

```yaml
before_script:
  - apt-get update -qq && apt-get install -y -qq sqlite3 libsqlite3-dev nodejs
  - gem install bundler --no-document
  - bundle install --jobs $(nproc)  "${FLAGS[@]}"
```

Content of `.gitlab-ci.yml`:

```yaml
include: 'https://gitlab.com/awesome-project/raw/master/.before-script-template.yml'

rspec:
  script:
    - bundle exec rspec
```

##### Overriding external template values

The following example shows specific YAML-defined variables and details of the
`production` job from an include file being customized in `.gitlab-ci.yml`.

Content of `https://company.com/autodevops-template.yml`:

```yaml
variables:
  POSTGRES_USER: user
  POSTGRES_PASSWORD: testing_password
  POSTGRES_DB: $CI_ENVIRONMENT_SLUG

production:
  stage: production
  script:
    - install_dependencies
    - deploy
  environment:
    name: production
    url: https://$CI_PROJECT_PATH_SLUG.$KUBE_INGRESS_BASE_DOMAIN
  only:
    - master
```

Content of `.gitlab-ci.yml`:

```yaml
include: 'https://company.com/autodevops-template.yml'

image: alpine:latest

variables:
  POSTGRES_USER: root
  POSTGRES_PASSWORD: secure_password

stages:
  - build
  - test
  - production

production:
  environment:
    url: https://domain.com
```

In this case, the variables `POSTGRES_USER` and `POSTGRES_PASSWORD` along
with the environment url of the `production` job defined in
`autodevops-template.yml` have been overridden by new values defined in
`.gitlab-ci.yml`.

The merging lets you extend and override dictionary mappings, but
you cannot add or modify items to an included array. For example, to add
an additional item to the production job script, you must repeat the
existing script items:

Content of `https://company.com/autodevops-template.yml`:

```yaml
production:
  stage: production
  script:
    - install_dependencies
    - deploy
```

Content of `.gitlab-ci.yml`:

```yaml
include: 'https://company.com/autodevops-template.yml'

stages:
  - production

production:
  script:
    - install_dependencies
    - deploy
    - notify_owner
```

In this case, if `install_dependencies` and `deploy` were not repeated in
`.gitlab-ci.yml`, they would not be part of the script for the `production`
job in the combined CI configuration.

##### Using nested includes

The examples below show how includes can be nested from different sources
using a combination of different methods.

In this example, `.gitlab-ci.yml` includes local the file `/.gitlab-ci/another-config.yml`:

```yaml
include:
  - local: /.gitlab-ci/another-config.yml
```

The `/.gitlab-ci/another-config.yml` includes a template and the `/templates/docker-workflow.yml` file
from another project:

```yaml
include:
  - template: Bash.gitlab-ci.yml
  - project: group/my-project
    file: /templates/docker-workflow.yml
```

The `/templates/docker-workflow.yml` present in `group/my-project` includes two local files
of the `group/my-project`:

```yaml
include:
  - local: /templates/docker-build.yml
  - local: /templates/docker-testing.yml
```

Our `/templates/docker-build.yml` present in `group/my-project` adds a `docker-build` job:

```yaml
docker-build:
  script: docker build -t my-image .
```

Our second `/templates/docker-test.yml` present in `group/my-project` adds a `docker-test` job:

```yaml
docker-test:
  script: docker run my-image /run/tests.sh
```

### `extends`

> Introduced in GitLab 11.3.

`extends` defines entry names that a job that uses `extends` is going to
inherit from.

It is an alternative to using [YAML anchors](#anchors) and is a little
more flexible and readable:

```yaml
.tests:
  script: rake test
  stage: test
  only:
    refs:
      - branches

rspec:
  extends: .tests
  script: rake rspec
  only:
    variables:
      - $RSPEC
```

In the example above, the `rspec` job inherits from the `.tests` template job.
GitLab will perform a reverse deep merge based on the keys. GitLab will:

- Merge the `rspec` contents into `.tests` recursively.
- Not merge the values of the keys.

This results in the following `rspec` job:

```yaml
rspec:
  script: rake rspec
  stage: test
  only:
    refs:
      - branches
    variables:
      - $RSPEC
```

NOTE: **Note:**
Note that `script: rake test` has been overwritten by `script: rake rspec`.

If you do want to include the `rake test`, see [`before_script` and `after_script`](#before_script-and-after_script).

`.tests` in this example is a [hidden key](#hidden-keys-jobs), but it's
possible to inherit from regular jobs as well.

`extends` supports multi-level inheritance, however it is not recommended to
use more than three levels. The maximum nesting level that is supported is 10.
The following example has two levels of inheritance:

```yaml
.tests:
  only:
    - pushes

.rspec:
  extends: .tests
  script: rake rspec

rspec 1:
  variables:
    RSPEC_SUITE: '1'
  extends: .rspec

rspec 2:
  variables:
    RSPEC_SUITE: '2'
  extends: .rspec

spinach:
  extends: .tests
  script: rake spinach
```

It's also possible to use multiple parents for `extends`.
The algorithm used for merge is "closest scope wins", so keys
from the last member will always shadow anything defined on other levels.
For example:

```yaml
.only-important:
  only:
    - master
    - stable
  tags:
    - production

.in-docker:
  tags:
    - docker
  image: alpine

rspec:
  extends:
    - .only-important
    - .in-docker
  script:
    - rake rspec
```

This results in the following `rspec` job:

```yaml
rspec:
  only:
    - master
    - stable
  tags:
    - docker
  image: alpine
  script:
    - rake rspec
```

### Using `extends` and `include` together

`extends` works across configuration files combined with `include`.

For example, if you have a local `included.yml` file:

```yaml
.template:
  script:
    - echo Hello!
```

Then, in `.gitlab-ci.yml` you can use it like this:

```yaml
include: included.yml

useTemplate:
  image: alpine
  extends: .template
```

This will run a job called `useTemplate` that runs `echo Hello!` as defined in
the `.template` job, and uses the `alpine` Docker image as defined in the local job.

### `pages`

`pages` is a special job that is used to upload static content to GitLab that
can be used to serve your website. It has a special syntax, so the two
requirements below must be met:

- Any static content must be placed under a `public/` directory.
- `artifacts` with a path to the `public/` directory must be defined.

The example below simply moves all files from the root of the project to the
`public/` directory. The `.public` workaround is so `cp` doesn't also copy
`public/` to itself in an infinite loop:

```yaml
pages:
  stage: deploy
  script:
    - mkdir .public
    - cp -r * .public
    - mv .public public
  artifacts:
    paths:
      - public
  only:
    - master
```

Read more on [GitLab Pages user documentation](../../user/project/pages/index.md).

### `variables`

> Introduced in GitLab Runner v0.5.0.

NOTE: **Note:**
Integers (as well as strings) are legal both for variable's name and value.
Floats are not legal and cannot be used.

GitLab CI/CD allows you to define variables inside `.gitlab-ci.yml` that are
then passed in the job environment. They can be set globally and per-job.
When the `variables` keyword is used on a job level, it overrides the global
YAML variables and predefined ones.

They are stored in the Git repository and are meant to store non-sensitive
project configuration, for example:

```yaml
variables:
  DATABASE_URL: "postgres://postgres@postgres/my_database"
```

These variables can be later used in all executed commands and scripts.
The YAML-defined variables are also set to all created service containers,
thus allowing to fine tune them.

Except for the user defined variables, there are also the ones [set up by the
Runner itself](../variables/README.md#predefined-environment-variables).
One example would be `CI_COMMIT_REF_NAME` which has the value of
the branch or tag name for which project is built. Apart from the variables
you can set in `.gitlab-ci.yml`, there are also the so called
[Variables](../variables/README.md#gitlab-cicd-environment-variables)
which can be set in GitLab's UI.

Learn more about [variables and their priority][variables].

#### Git strategy

> Introduced in GitLab 8.9 as an experimental feature. May change or be removed
> completely in future releases. `GIT_STRATEGY=none` requires GitLab Runner
> v1.7+.

You can set the `GIT_STRATEGY` used for getting recent application code, either
globally or per-job in the [`variables`](#variables) section. If left
unspecified, the default from project settings will be used.

There are three possible values: `clone`, `fetch`, and `none`.

`clone` is the slowest option. It clones the repository from scratch for every
job, ensuring that the project workspace is always pristine.

```yaml
variables:
  GIT_STRATEGY: clone
```

`fetch` is faster as it re-uses the project workspace (falling back to `clone`
if it doesn't exist). `git clean` is used to undo any changes made by the last
job, and `git fetch` is used to retrieve commits made since the last job ran.

```yaml
variables:
  GIT_STRATEGY: fetch
```

`none` also re-uses the project workspace, but skips all Git operations
(including GitLab Runner's pre-clone script, if present). It is mostly useful
for jobs that operate exclusively on artifacts (e.g., `deploy`). Git repository
data may be present, but it is certain to be out of date, so you should only
rely on files brought into the project workspace from cache or artifacts.

```yaml
variables:
  GIT_STRATEGY: none
```

NOTE: **Note:** `GIT_STRATEGY` is not supported for
[Kubernetes executor](https://docs.gitlab.com/runner/executors/kubernetes.html),
but may be in the future. See the [support Git strategy with Kubernetes executor feature proposal](https://gitlab.com/gitlab-org/gitlab-runner/issues/3847)
for updates.

#### Git submodule strategy

> Requires GitLab Runner v1.10+.

The `GIT_SUBMODULE_STRATEGY` variable is used to control if / how Git
submodules are included when fetching the code before a build. You can set them
globally or per-job in the [`variables`](#variables) section.

There are three possible values: `none`, `normal`, and `recursive`:

- `none` means that submodules will not be included when fetching the project
  code. This is the default, which matches the pre-v1.10 behavior.

- `normal` means that only the top-level submodules will be included. It is
  equivalent to:

    ```
    git submodule sync
    git submodule update --init
    ```

- `recursive` means that all submodules (including submodules of submodules)
  will be included. This feature needs Git v1.8.1 and later. When using a
  GitLab Runner with an executor not based on Docker, make sure the Git version
  meets that requirement. It is equivalent to:

    ```
    git submodule sync --recursive
    git submodule update --init --recursive
    ```

Note that for this feature to work correctly, the submodules must be configured
(in `.gitmodules`) with either:

- the HTTP(S) URL of a publicly-accessible repository, or
- a relative path to another repository on the same GitLab server. See the
  [Git submodules](../git_submodules.md) documentation.

#### Git checkout

> Introduced in GitLab Runner 9.3.

The `GIT_CHECKOUT` variable can be used when the `GIT_STRATEGY` is set to either
`clone` or `fetch` to specify whether a `git checkout` should be run. If not
specified, it defaults to true. You can set them globally or per-job in the
[`variables`](#variables) section.

If set to `false`, the Runner will:

- when doing `fetch` - update the repository and leave working copy on
  the current revision,
- when doing `clone` - clone the repository and leave working copy on the
  default branch.

Having this setting set to `true` will mean that for both `clone` and `fetch`
strategies the Runner will checkout the working copy to a revision related
to the CI pipeline:

```yaml
variables:
  GIT_STRATEGY: clone
  GIT_CHECKOUT: "false"
script:
  - git checkout -B master origin/master
  - git merge $CI_COMMIT_SHA
```

#### Git clean flags

> Introduced in GitLab Runner 11.10

The `GIT_CLEAN_FLAGS` variable is used to control the default behavior of
`git clean` after checking out the sources. You can set it globally or per-job in the
[`variables`](#variables) section.

`GIT_CLEAN_FLAGS` accepts all possible options of the [git clean](https://git-scm.com/docs/git-clean)
command.

`git clean` is disabled if `GIT_CHECKOUT: "false"` is specified.

If `GIT_CLEAN_FLAGS` is:

- Not specified, `git clean` flags default to `-ffdx`.
- Given the value `none`, `git clean` is not executed.

For example:

```yaml
variables:
  GIT_CLEAN_FLAGS: -ffdx -e cache/
script:
  - ls -al cache/
```

#### Job stages attempts

> Introduced in GitLab, it requires GitLab Runner v1.9+.

You can set the number for attempts the running job will try to execute each
of the following stages:

| Variable                        | Description |
|-------------------------------- |-------------|
| **GET_SOURCES_ATTEMPTS**        | Number of attempts to fetch sources running a job |
| **ARTIFACT_DOWNLOAD_ATTEMPTS**  | Number of attempts to download artifacts running a job |
| **RESTORE_CACHE_ATTEMPTS**      | Number of attempts to restore the cache running a job |

The default is one single attempt.

Example:

```yaml
variables:
  GET_SOURCES_ATTEMPTS: 3
```

You can set them globally or per-job in the [`variables`](#variables) section.

#### Shallow cloning

> Introduced in GitLab 8.9 as an experimental feature. May change in future
releases or be removed completely.

You can specify the depth of fetching and cloning using `GIT_DEPTH`. This allows
shallow cloning of the repository which can significantly speed up cloning for
repositories with a large number of commits or old, large binaries. The value is
passed to `git fetch` and `git clone`.

NOTE: **Note:**
If you use a depth of 1 and have a queue of jobs or retry
jobs, jobs may fail.

Since Git fetching and cloning is based on a ref, such as a branch name, Runners
can't clone a specific commit SHA. If there are multiple jobs in the queue, or
you are retrying an old job, the commit to be tested needs to be within the
Git history that is cloned. Setting too small a value for `GIT_DEPTH` can make
it impossible to run these old commits. You will see `unresolved reference` in
job logs. You should then reconsider changing `GIT_DEPTH` to a higher value.

Jobs that rely on `git describe` may not work correctly when `GIT_DEPTH` is
set since only part of the Git history is present.

To fetch or clone only the last 3 commits:

```yaml
variables:
  GIT_DEPTH: "3"
```

You can set it globally or per-job in the [`variables`](#variables) section.

## Deprecated parameters

The following parameters are deprecated.

### `types`

CAUTION: **Deprecated:**
`types` is deprecated, and could be removed in a future release.
Use [`stages`](#stages) instead.

### `type`

CAUTION: **Deprecated:**
`type` is deprecated, and could be removed in one of the future releases.
Use [`stage`](#stage) instead.

## Custom build directories

> [Introduced](https://gitlab.com/gitlab-org/gitlab-runner/merge_requests/1267) in Gitlab Runner 11.10

NOTE: **Note:**
This can only be used when `custom_build_dir` is enabled in the [Runner's
configuration](https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runnerscustom_build_dir-section).
This is the default configuration for `docker` and `kubernetes` executor.

By default, GitLab Runner clones the repository in a unique subpath of the
`$CI_BUILDS_DIR` directory. However, your project might require the code in a
specific directory (Go projects, for example). In that case, you can specify
the `GIT_CLONE_PATH` variable to tell the Runner in which directory to clone the
repository:

```yml
variables:
  GIT_CLONE_PATH: $CI_BUILDS_DIR/project-name

test:
  script:
    - pwd
```

The `GIT_CLONE_PATH` has to always be within `$CI_BUILDS_DIR`. The directory set in `$CI_BUILDS_DIR`
is dependent on executor and configuration of [runners.builds_dir](https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runners-section)
setting.

### Handling concurrency

An executor using a concurrency greater than `1` might lead
to failures because multiple jobs might be working on the same directory if the `builds_dir`
is shared between jobs.
GitLab Runner does not try to prevent this situation. It is up to the administrator
and developers to comply with the requirements of Runner configuration.

To avoid this scenario, you can use a unique path within `$CI_BUILDS_DIR`, because Runner
exposes two additional variables that provide a unique `ID` of concurrency:

- `$CI_CONCURRENT_ID`: Unique ID for all jobs running within the given executor.
- `$CI_CONCURRENT_PROJECT_ID`: Unique ID for all jobs running within the given executor and project.

The most stable configuration that should work well in any scenario and on any executor
is to use `$CI_CONCURRENT_ID` in the `GIT_CLONE_PATH`. For example:

```yml
variables:
  GIT_CLONE_PATH: $CI_BUILDS_DIR/$CI_CONCURRENT_ID/project-name

test:
  script:
    - pwd
```

The `$CI_CONCURRENT_PROJECT_ID` should be used in conjunction with `$CI_PROJECT_PATH`
as the `$CI_PROJECT_PATH` provides a path of a repository. That is, `group/subgroup/project`. For example:

```yml
variables:
  GIT_CLONE_PATH: $CI_BUILDS_DIR/$CI_CONCURRENT_ID/$CI_PROJECT_PATH

test:
  script:
    - pwd
```

### Nested paths

The value of `GIT_CLONE_PATH` is expanded once and nesting variables
within it is not supported.

For example, you define both the variables below in your
`.gitlab-ci.yml` file:

```yml
variables:
  GOPATH: $CI_BUILDS_DIR/go
  GIT_CLONE_PATH: $GOPATH/src/namespace/project
```

The value of `GIT_CLONE_PATH` is expanded once into
`$CI_BUILDS_DIR/go/src/namespace/project`, and results in failure
because `$CI_BUILDS_DIR` is not expanded.   

## Special YAML features

It's possible to use special YAML features like anchors (`&`), aliases (`*`)
and map merging (`<<`), which will allow you to greatly reduce the complexity
of `.gitlab-ci.yml`.

Read more about the various [YAML features](https://learnxinyminutes.com/docs/yaml/).

### Hidden keys (jobs)

> Introduced in GitLab 8.6 and GitLab Runner v1.1.1.

If you want to temporarily 'disable' a job, rather than commenting out all the
lines where the job is defined:

```
#hidden_job:
#  script:
#    - run test
```

you can instead start its name with a dot (`.`) and it will not be processed by
GitLab CI. In the following example, `.hidden_job` will be ignored:

```yaml
.hidden_job:
  script:
    - run test
```

Use this feature to ignore jobs, or use the
[special YAML features](#special-yaml-features) and transform the hidden keys
into templates.

### Anchors

> Introduced in GitLab 8.6 and GitLab Runner v1.1.1.

YAML has a handy feature called 'anchors', which lets you easily duplicate
content across your document. Anchors can be used to duplicate/inherit
properties, and is a perfect example to be used with [hidden keys](#hidden-keys-jobs)
to provide templates for your jobs.

The following example uses anchors and map merging. It will create two jobs,
`test1` and `test2`, that will inherit the parameters of `.job_template`, each
having their own custom `script` defined:

```yaml
.job_template: &job_definition  # Hidden key that defines an anchor named 'job_definition'
  image: ruby:2.1
  services:
    - postgres
    - redis

test1:
  <<: *job_definition           # Merge the contents of the 'job_definition' alias
  script:
    - test1 project

test2:
  <<: *job_definition           # Merge the contents of the 'job_definition' alias
  script:
    - test2 project
```

`&` sets up the name of the anchor (`job_definition`), `<<` means "merge the
given hash into the current one", and `*` includes the named anchor
(`job_definition` again). The expanded version looks like this:

```yaml
.job_template:
  image: ruby:2.1
  services:
    - postgres
    - redis

test1:
  image: ruby:2.1
  services:
    - postgres
    - redis
  script:
    - test1 project

test2:
  image: ruby:2.1
  services:
    - postgres
    - redis
  script:
    - test2 project
```

Let's see another one example. This time we will use anchors to define two sets
of services. This will create two jobs, `test:postgres` and `test:mysql`, that
will share the `script` directive defined in `.job_template`, and the `services`
directive defined in `.postgres_services` and `.mysql_services` respectively:

```yaml
.job_template: &job_definition
  script:
    - test project

.postgres_services:
  services: &postgres_definition
    - postgres
    - ruby

.mysql_services:
  services: &mysql_definition
    - mysql
    - ruby

test:postgres:
  <<: *job_definition
  services: *postgres_definition

test:mysql:
  <<: *job_definition
  services: *mysql_definition
```

The expanded version looks like this:

```yaml
.job_template:
  script:
    - test project

.postgres_services:
  services:
    - postgres
    - ruby

.mysql_services:
  services:
    - mysql
    - ruby

test:postgres:
  script:
    - test project
  services:
    - postgres
    - ruby

test:mysql:
  script:
    - test project
  services:
    - mysql
    - ruby
```

You can see that the hidden keys are conveniently used as templates.

## Triggers

Triggers can be used to force a rebuild of a specific branch, tag or commit,
with an API call when a pipeline gets created using a trigger token.

Not to be confused with [`trigger`](#trigger-premium).

[Read more in the triggers documentation.](../triggers/README.md)

## Processing Git pushes

GitLab will create at most 4 branch and tags pipelines when
doing pushing multiple changes in single `git push` invocation.

This limitation does not affect any of the updated Merge Request pipelines,
all updated Merge Requests will have a pipeline created when using
[pipelines for merge requests](../merge_request_pipelines/index.md).

## Skipping jobs

If your commit message contains `[ci skip]` or `[skip ci]`, using any
capitalization, the commit will be created but the pipeline will be skipped.

Alternatively, one can pass the `ci.skip` [Git push option][push-option] if
using Git 2.10 or newer:

```sh
git push -o ci.skip
```

<!-- ## Troubleshooting

Include any troubleshooting steps that you can foresee. If you know beforehand what issues
one might have when setting this up, or when something is changed, or on upgrading, it's
important to describe those, too. Think of things that may go wrong and include them here.
This is important to minimize requests for support, and to avoid doc comments with
questions that you know someone might ask.

Each scenario can be a third-level heading, e.g. `### Getting error message X`.
If you have none to add when creating a doc, leave this section in place
but commented out to help encourage others to add to it in the future. -->

[ce-6323]: https://gitlab.com/gitlab-org/gitlab-ce/merge_requests/6323
[ce-6669]: https://gitlab.com/gitlab-org/gitlab-ce/merge_requests/6669
[ce-7983]: https://gitlab.com/gitlab-org/gitlab-ce/merge_requests/7983
[ce-7447]: https://gitlab.com/gitlab-org/gitlab-ce/merge_requests/7447
[ce-12909]: https://gitlab.com/gitlab-org/gitlab-ce/merge_requests/12909
[ce-19232]: https://gitlab.com/gitlab-org/gitlab-ce/issues/19232
[environment]: ../environments.md "CI/CD environments"
[schedules]: ../../user/project/pipelines/schedules.md "Pipelines schedules"
[variables]: ../variables/README.md "CI/CD variables"
[push-option]: https://git-scm.com/docs/git-push#Documentation/git-push.txt--oltoptiongt
