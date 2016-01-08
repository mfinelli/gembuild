# Gembuild

[![RubyGems](https://img.shields.io/gem/v/gembuild.svg)](https://rubygems.org/gems/gembuild)
[![Build Status](https://travis-ci.org/mfinelli/gembuild.svg?branch=master)](https://travis-ci.org/mfinelli/gembuild)
[![Coverage Status](https://coveralls.io/repos/mfinelli/gembuild/badge.svg?branch=master&service=github)](https://coveralls.io/github/mfinelli/gembuild?branch=master)
[![Code Climate](https://codeclimate.com/github/mfinelli/gembuild/badges/gpa.svg)](https://codeclimate.com/github/mfinelli/gembuild)
[![Inline Documentation](https://inch-ci.org/github/mfinelli/gembuild.svg)](https://inch-ci.org/github/mfinelli/gembuild)

Create PKGBUILDs for ruby gems.

## Configuration

Upon first run the gem will prompt for your name and email address to use in
the maintainer field in PKGBUILDs and to use as the git author. If you have
already configured git it will confirm the values that it finds. It will also
ask where to store package repositories. All information is then saved in
`~/.gembuild` which is just a simple YAML file and can be easily changed
using your favorite text editor.

## Usage

Simple usage to create/update a package for a gem:

```shell
$ bundle exec bin/gembuild mina
```

This will checkout the AUR package for `ruby-mina`, fetch the latest version
of the gem and update the PKGBUILD accordingly, and then regenerate the
metadata using `mksrcinfo` and commit all changes.

### Advanced Usage

There are four main parts: the AUR scraper, the rubygems scraper, the
PKGBUILD and the project.

#### AUR Scraper

The AUR scraper is used to get version information about a package currently
on the AUR.

```ruby
s = Gembuild::AurScraper.new('ruby-mina')
s.scrape!
```

#### RubyGems Scraper

The RubyGems scraper gets the rest of the information needed for the PKGBUILD
by making several queries to rubygems.org. **N.B. that it skips any version
marked as a "prerelease".**

```ruby
s = Gembuild::GemScraper.neW('mina')
s.scrape!
```

#### PKGBUILD

The `Pkgbuild` class is actually responsible for creating a PKGBUILD for a
gem.

```ruby
Gembuild::Pkgbuild.create('mina')
```

#### Project

The `Project` class is what checks out the repository from the AUR,
configures git for it, makes sure there is a `.gitignore` and commits all
changes after creating or updating the PKGBUILD.

```ruby
Gembuild::Project.new('mina').clone_and_commit!
```

## License

This project is licensed under the GPLv3 or any later version. For more
information please see the LICENSE file included with the project or
[https://www.gnu.org/licenses](https://www.gnu.org/licenses/gpl.html).
