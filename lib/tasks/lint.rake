desc "Run all linters"
task lint: :environment do
  sh "bundle exec rubocop"
  if Rails.env.development?
    sh "bundle exec erb_lint --lint-all --autocorrect"
  else
    sh "bundle exec erb_lint --lint-all"
  end
  sh "yarn run lint"
end
