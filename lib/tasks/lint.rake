desc 'Run govuk-lint-ruby'
task :lint do |_task, _args|
  system 'govuk-lint-ruby --parallel app lib test'
end
