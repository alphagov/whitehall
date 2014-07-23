# default cron env is "/usr/bin:/bin" which is not sufficient as govuk_env is in /usr/local/bin
env :PATH, '/usr/local/bin:/usr/bin:/bin'

# We need Rake to use our own environment
job_type :rake, "cd :path && govuk_setenv whitehall bundle exec rake :task --silent :output"

## 14:45 is during our regular release slot, this may have to change
## post-April. 2am is our regular time for this.
every :day, at: ['2am', '11:45am'], roles: [:admin] do
  rake "export:redirector_mappings"
end

every :day, at: ['3am', '12:45pm'], roles: [:admin] do
  rake "export:mappings"
end

every :day, at: ['1:30am'], roles: [:backend] do
  rake "rummager:index:closed_consultations"
end
