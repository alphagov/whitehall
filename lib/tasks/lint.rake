desc "Run all linters"
task lint: :environment do
  sh "bundle exec rubocop"
  if Rails.env.development?
    sh "bundle exec erblint --lint-all --autocorrect"
  else
    sh "bundle exec erblint --lint-all"
  end
  sh "yarn run lint"
end
