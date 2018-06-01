# default cron env is "/usr/bin:/bin" which is not sufficient as govuk_env is in /usr/local/bin
env :PATH, '/usr/local/bin:/usr/bin:/bin'

# We need Rake to use our own environment
job_type :rake, "cd :path && govuk_setenv whitehall bundle exec rake :task --silent :output"

every :day, at: ['3am', '12:45pm'], roles: [:admin] do
  rake "export:mappings"
end

every :hour, roles: [:backend] do
  rake "rummager:index:consultations"
end

every 10.minutes, roles: [:backend] do
  rake "taxonomy:rebuild_cache"
end

every 30.minutes, roles: [:backend] do
  rake "taxonomy:copy_brexit_policies_to_brexit_taxon"
end
