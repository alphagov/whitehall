unless Rails.env.production?
  require "cucumber/rake/task"

  namespace :cucumber do
    Cucumber::Rake::Task.new({ ok: "test:prepare" }, "Run features that should pass") do |t|
      t.fork = true # You may get faster startup if you set this to false
      t.profile = "default"
    end

    Cucumber::Rake::Task.new({ preview_design_system: "test:prepare" }, "Run features with the 'Preview design system' feature flag enabled") do |t|
      t.fork = true # You may get faster startup if you set this to false
      t.profile = "preview_design_system"
    end
  end

  desc "Run all feature tests"
  # preview_design_system comes first because it's more likely to break tests, so we'll get a faster feedback loop
  task cucumber: ["cucumber:preview_design_system", "cucumber:ok"]

  task default: :cucumber
end
