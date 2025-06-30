namespace :db do
  namespace :data do
    desc "Run all data migrations, or a specific version passed via VERSION=<n>"
    task migrate: :environment do
      # ── 1. Re-wire Rails.logger ──────────────────────────────
      stdout_logger           = ActiveSupport::Logger.new($stdout)
      stdout_logger.level     = Logger::DEBUG          # make sure DEBUG messages are kept
      stdout_logger.formatter = Rails.logger.formatter # keep the usual tags/time stamps

      Rails.logger            = ActiveSupport::TaggedLogging.new(stdout_logger)
      ActiveRecord::Base.logger = Rails.logger         # optional – show SQL, too

      # Suppress SQL logging
      ActiveRecord::Base.logger = nil

      # ── 2. Hand that logger to your migrator ────────────────
      Whitehall::DataMigrator.new(logger: Rails.logger).run
    end
  end
end
