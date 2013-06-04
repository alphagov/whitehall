require 'logger'

module Whitehall
  class DataMigrator
    def initialize(options = {})
      @path = options[:path] || Rails.root.join("db/data_migration")
      @logger = options[:logger] || Logger.new($stderr)
    end

    def migrations
      files = if ENV["VERSION"]
        Dir["#{@path}/#{ENV["VERSION"]}_*.rb"]
      else
        Dir["#{@path}/*_*.rb"]
      end
      files.sort.map do |f|
        DataMigration.new(f, logger: @logger)
      end
    end

    def due
      migrations.select(&:due?)
    end

    def run
      if due.any?
        @logger.info "Running #{due.size} data migrations..."
        due.sort_by(&:version).each do |migration|
          migration.run
        end
      else
        @logger.info "No data migrations pending."
      end
    end
  end
end
