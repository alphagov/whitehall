unless Rails.env.production?
  require "cucumber/rake/task"

  namespace :cucumber do
    Cucumber::Rake::Task.new({ ok: "test:prepare" }, "Run features that should pass") do |t|
      t.fork = true # You may get faster startup if you set this to false
      t.profile = "default"
    end
  end

  desc "Alias for cucumber:ok"
  task cucumber: "cucumber:ok"

  task default: :cucumber
end
