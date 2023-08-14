## Whitehall troubleshooting

You may run into errors while working locally and trying to render pages.

Problem:

```
Mysql2::Error: Access denied for user 'whitehall'@'localhost' (using password: YES)
```

Solution:
Enter `govuk-docker`, Login, create user, give access & quit

```
cd ~/govuk/govuk-docker
mysql -u root -p
CREATE USER whitehall@localhost IDENTIFIED BY 'whitehall';
grant all privileges on *.* to whitehall@localhost with grant option;
\q
```

Problem:

```
ActiveRecord::SubclassNotFound
/versions/2.6.6/lib/ruby/gems/2.6.0/gems/sassc-2.4.0/lib/sassc/engine.rb:43: [BUG] Segmentation fault at 0x0000000000000000
```

Solution:
Restart

Problem:

```
/.rvm/rubies/ruby-2.7.2/lib/ruby/site_ruby/2.7.0/rubygems/core_ext/kernel_gem.rb:67:in `gem'
/.rvm/rubies/ruby-2.7.2/lib/ruby/site_ruby/2.7.0/rubygems/core_ext/kernel_gem.rb:67:in `synchronize': dead
```

Solution:
`gem update --system`

Problem:

```
API Error
```

Solution:

[`search-api`](https://github.com/alphagov/search-api), [`static`](https://github.com/alphagov/static) are helpful to have to running in parallel (depending on what page you are on) via [govuk-docker](https://github.com/alphagov/govuk-docker). Make sure the referenced apps are up to date as well

Example:

```
cd ~/govuk/govuk-docker; git pull; make search-api
govuk-docker up search-api-app
```


Problem:

```
Error: Failed to load config "standard" to extend from
```

Solution:
Run: `yarn`

[Byebug](https://github.com/deivid-rodriguez/byebug) is helpful for testing troubleshooting

Problem:

```
ActiveRecord::PendingMigrationError Migrations are pending. To resolve this issue, run: bin/rails db:migrate RAILS_ENV=development You have 2 pending migrations
```

Solution:
`govuk-docker-run bundle exec rake db:migrate` / `govuk-docker-run rake db:migrate`
