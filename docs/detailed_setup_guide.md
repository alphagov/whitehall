# Detailed setup guide

## Getting set-up locally

### Pre-requisites

* Xcode (for the Command Line Tools `xcode-select --install`)
* Ruby 2.2.3
* Rubygems and Bundler
* Mysql
* Imagemagick and Ghostscript (for generating thumbnails of uploaded
  PDFs)
* xpdf (first download [XQuartz](http://www.xquartz.org/))
* PhantomJS (for running the Javascript tests)

If you use [Homebrew](http://brew.sh/) you can run the following:

```
brew install ruby-build rbenv mysql phantomjs imagemagick ghostscript xpdf
```

### Creating the mysql user

The database.yml for this project is checked into source control so
you'll need a local user with credentials that match those in
database.yml.

```sql
mysql> CREATE USER 'whitehall'@'localhost' IDENTIFIED BY 'whitehall';
mysql> GRANT ALL ON `whitehall\_%`.* TO 'whitehall'@'localhost';
```

### Preparing the app

```
$ cd /path/to/whitehall
$ rbenv install
$ gem install bundler
$ bundle install
```

If you running on OSX Yosemite or later you might come across an installation failure:

```
An error occurred while installing eventmachine (1.0.4), and Bundler cannot continue.
Make sure that `gem install eventmachine -v '1.0.4'` succeeds before bundling.
```

To solve the problem make sure you have openssl under `/usr/local/opt/openssl/include` and run the following:

```
$ gem install eventmachine -v '1.0.4' -- --with-cppflags=-I/usr/local/opt/openssl/include
```

### Set up the database

If you wish to use a sanitized export of the production data (recommended for
internal staff) then see the alphagov/development repo for the replication script.
Once that is imported upgrade your import to the latest schema version with

```
$ bundle exec rake db:setup
```
