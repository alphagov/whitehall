# Try and improve SASS compiling issues.
# Lifted verbatim from:
# https://raw.github.com/kennyj/rails/205674408b1d45d188af2fd59a6f6734f461976b/actionpack/lib/sprockets/assets.rake
# which I found on:
# https://github.com/rails/rails/issues/3694
# This may be able to be removed when we update to Rails 3.2
require "fileutils"

namespace :patched_assets do
  def ruby_rake_task(task, fork = true)
    puts fork
    env    = ENV['RAILS_ENV'] || 'production'
    groups = ENV['RAILS_GROUPS'] || 'assets'
    args   = [$0, task,"RAILS_ENV=#{env}","RAILS_GROUPS=#{groups}"]
    args << "--trace" if Rake.application.options.trace
    fork ? ruby(*args) : Kernel.exec(FileUtils::RUBY, *args)
  end

  # We are currently running with no explicit bundler group
  # and/or no explicit environment - we have to reinvoke rake to
  # execute this task.
  def invoke_or_reboot_rake_task(task)
    if ENV['RAILS_GROUPS'].to_s.empty? || ENV['RAILS_ENV'].to_s.empty?
      ruby_rake_task(task, false)
    else
      Rake::Task[task].invoke
    end
  end

  desc "Compile all the assets named in config.assets.precompile"
  task :precompile do
    invoke_or_reboot_rake_task "patched_assets:precompile:all"
  end

  namespace :precompile do
    def internal_precompile(digest=nil)
      unless Rails.application.config.assets.enabled
        warn "Cannot precompile assets if sprockets is disabled. Please set config.assets.enabled to true"
        exit
      end

      # Ensure that action view is loaded and the appropriate
      # sprockets hooks get executed
      _ = ActionView::Base

      config = Rails.application.config
      config.assets.compile = true
      config.assets.digest  = digest unless digest.nil?
      config.assets.digests = {}

      env      = Rails.application.assets
      target   = File.join(Rails.public_path, config.assets.prefix)
      compiler = Sprockets::StaticCompiler.new(env,
                                               target,
                                               config.assets.precompile,
                                               :manifest_path => config.assets.manifest,
                                               :digest => config.assets.digest,
                                               :manifest => digest.nil?)
      compiler.compile
    end

    task :all do
      Rake::Task["patched_assets:precompile:primary"].invoke
      # We need to reinvoke in order to run the secondary digestless
      # asset compilation run - a fresh Sprockets environment is
      # required in order to compile digestless assets as the
      # environment has already cached the assets on the primary
      # run.
      ruby_rake_task("patched_assets:precompile:nondigest", false) if Rails.application.config.assets.digest
    end

    task :primary => ["patched_assets:environment", "tmp:cache:clear"] do
      internal_precompile
    end

    task :nondigest => ["patched_assets:environment", "tmp:cache:clear"] do
      internal_precompile(false)
    end
  end

  desc "Remove compiled assets"
  task :clean do
    invoke_or_reboot_rake_task "patched_assets:clean:all"
  end

  namespace :clean do
    task :all => ["patched_assets:environment", "tmp:cache:clear"] do
      config = Rails.application.config
      public_asset_path = File.join(Rails.public_path, config.assets.prefix)
      rm_rf public_asset_path, :secure => true
    end
  end

  task :environment do
    if Rails.application.config.assets.initialize_on_precompile
      Rake::Task["environment"].invoke
    else
      Rails.application.initialize!(:assets)
      Sprockets::Bootstrap.new(Rails.application).run
    end
  end
end

# This has been taken wholesale from https://gist.github.com/sj26/4728657

# Stick this in lib/tasks/assets.rake or similar
#
# A bug was introduced in rails in 7f1a666d causing the whole application cache
# to be cleared everytime a precompile is run, but it is not neccesary and just
# slows down precompiling.
#
# Secondary consequences are the clearing of the whole cache, which if using
# the default file cache could cause an application level performance hit.
#
# This is already fixed in sprockets-rails for rails 4, but we patch here for
# interim gains.
#
# If you're using rails pre-3.2 change "primary" to "digest" below.

Rake::Task["patched_assets:precompile:primary"].prerequisites.delete "tmp:cache:clear"
Rake::Task["patched_assets:precompile:nondigest"].prerequisites.delete "tmp:cache:clear"
