# PivoFlow

[![](http://img.shields.io/codeclimate/github/lubieniebieski/pivo_flow.svg?style=flat-square)](https://codeclimate.com/github/lubieniebieski/pivo_flow)
[![](https://img.shields.io/circleci/project/github/lubieniebieski/pivo_flow.svg?style=flat-square)](https://circleci.com/gh/lubieniebieski/pivo_flow)

PivoFlow lets you choose the story you are currently working on from Pivotal Tracker. Intended for all the people, who doesn't like feature-branch approach or are "merdżuj - nie pier*ol"-theory enthusiasts.

## Installation

Install it yourself as:

    $ gem install pivo_flow

## Usage

All the required information is gathered on demand, but it's a good idea to prepare:

* project's Pivotal Tracker ID
* your Pivotal Tracker API token (see here https://www.pivotaltracker.com/profile#api)
  * when project's ID is strictly connected with one project, API-token is for all the projects, so the best solution would be to add it globally to git config:

  `git config --global pivo-flow.pivotal-token YOUR_PIVOTAL_API_TOKEN`

Show help

    pf help

or

    pf --help

Get list of current stories with an interactive choice menu

    pf stories

Start story with given ID

    pf start STORY_ID

Finish current story [or given story ID]

    pf finish [STORY_ID]

Clear current story without notifying Pivotal

    pf clear

Show finished stories and select the one you would like to deliver

    pf deliver

Display current gem version

    pf version

Show current STORY_ID from temp file

    pf current

## Git-hooks

This gem installs a `pepare-commit-msg` hook by adding a reference to `pf-prepare-commit-msg` file. In short: you shouldn't be worried about your own `prepare-commit-msg` hook, the one added by `pivo_flow` will be added in the last line of original hook file.

## Roadmap
### 0.6 Current release

* create local branch of the current ticket using its id and name with 'pf branch'

### 0.5

* set ticket id without connecting to pivotal with 'pf set NUMBER'

### 0.4

* colorized output
* **TODO** story statistics
* **TODO** git statistics (number of commits in some peroid, average, etc.)

### 0.3

* single-story view with comments and tasks
* flow:
  * select story
  * read the story description
  * accept or back to story selection
* `pf info` displaying info about current task
* `pf deliver` ability to deliver finished stories [#6]
* options via `OptionParser`

### 0.2

* git hook
* formatted output
* bugfixes

### before 0.2

* gem basic structure
* git config read/write

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Thanks

This gem is inspired by https://github.com/blindsey/git_pivotal_tracker. Thanks to it's author for the inspiration and idea. If you would like to use Pivotal with feature-branch-based flow, `git_pivotal_tracker` is the way you should proably go.
