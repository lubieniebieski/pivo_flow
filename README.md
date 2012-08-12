# PivoFlow

[![Build Status](https://secure.travis-ci.org/hybridgroup/taskmapper.png?branch=master)](http://travis-ci.org/hybridgroup/taskmapper)

PivoFlow let's you choose the story from Pivotal Tracker you are currently working on. Intended for all the people, who doesn't like feature-branch approach or are "merdżuj - nie pier*ol"-theory enthusiasts.

## Installation

Install it yourself as:

    $ gem install pivo_flow

## Usage

All the required information is gathered on demand, but it's a good idea to prepare:

* project's Pivotal Tracker ID
* your Pivotal Tracker API token

Get list of current stories

    pf stories

Start story with given ID

    pf start STORY_ID

Finish current story [or given story ID]

    pf finish [STORY_ID]

Clear current story without notifying Pivotal

    pf clear

Display current gem version

    pf version

## Git-hooks

This gem installs a `pepare-commit-msg` hook by adding a reference to `pf-prepare-commit-msg` file. In short: you shouldn't be worried about your own `prepare-commit-msg` hook, the one added by `pivo_flow` will be added in the last line of original hook file.

## Roadmap

### Incoming releases

* story statistics
* colorized output

### 0.3 Current release

* single-story view
* flow:
  * select story
  * read the story description
  * accept or back to story selection
* `pf info` displaying info about current task, it's comments and all the available data
*  `pf --help` and other options via OptionParser

### 0.2

* git hoook
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
