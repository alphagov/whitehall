require 'logger'

module Whitehall
  class DataMigration
    def initialize(path, options = {})
      @path = path.to_s
      @logger = options[:logger] || Logger.new($stderr)
    end

    def name
      File.basename(@path, ".rb").match(/^[0-9]+_(.*)$/)[1].humanize
    end

    def filename
      File.basename(@path)
    end

    def version
      filename.match(/^([0-9]+)_/)[1]
    end

    def due?
      DataMigrationRecord.find_by_version(version).nil?
    end

    def run
      ActiveRecord::Base.connection.transaction do
        begin
          @logger.info "============================================="
          @logger.info "Running data migration #{version}: #{name}"
          instance_eval File.read(@path), @path
          DataMigrationRecord.create!(version: version)
          @logger.info "Migration complete"
        rescue => e
          @logger.error "Migration failed due to #{e}"
          @logger.error "  " + e.backtrace.join("\n  ")
          raise ActiveRecord::Rollback
        end
        @logger.info "============================================="
        @logger.info "\n"
      end
    end
  end
end
