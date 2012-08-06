# PivoFlow

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'pivo_flow'

And then execute:

    $ bundle

Or install it yourself as:

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

## Git-hooks

This gem installs a `pepare-commit-msg` hook by adding a reference to `pf-prepare-commit-msg` file. In short: you shouldn't be worried about your own `prepare-commit-msg` hook, the one added by `pivo_flow` will be added in the last line of original hook file.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
