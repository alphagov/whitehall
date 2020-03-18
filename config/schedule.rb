# default cron env is "/usr/bin:/bin" which is not sufficient as govuk_env is in /usr/local/bin
env :PATH, "/usr/local/bin:/usr/bin:/bin"

# We need Rake to use our own environment
job_type :rake, "cd :path && govuk_setenv whitehall bundle exec rake :task --silent :output"

def integration_or_staging?
  ENV.fetch("GOVUK_WEBSITE_ROOT") =~ /integration|staging/
end

every :day, at: ["3am", "12:45pm"], roles: [:backend] do
  rake "export:mappings"
end

def search_index_consultations_cron_rule
  if integration_or_staging?
    # Don't run near midnight, as this is when the data sync will
    # likely happen, and the task will error
    "0 2-22 * * *"
  else
    :hour
  end
end

every search_index_consultations_cron_rule, roles: [:backend] do
  rake "search:index:consultations"
end

def taxonomy_cron_rules
  if integration_or_staging?
    # at every 10th minute past the hour between 7am and 8pm
    "*/10 7-20 * * *"
  else
    10.minutes
  end
end

every taxonomy_cron_rules, roles: [:backend] do
  rake "taxonomy:rebuild_cache"
end

every :day, at: "4am", roles: [:backend] do
  rake "link_checker:delete_old_report_links"
end
