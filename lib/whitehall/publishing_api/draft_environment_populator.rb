module Whitehall
  class PublishingApi
    class DraftEnvironmentPopulator
      attr_reader :draft_items, :logger

      def initialize(draft_items: nil, logger: Logger.new(nil))
        @logger = logger
        @draft_items = draft_items || default_draft_items
      end

      def call
        draft_items.each do |edition|
          PublishingApi.publish_draft_async(edition, 'bulk_draft_update', 'bulk_republishing')
        end
      end

    private
      class ProgressLogger
        attr_reader :name, :count, :logger

        def initialize(count, logger)
          @count = count
          @logger = logger
          @i = 0
        end

        def inc
          @i += 1
          if @i % 1000 == 0
            logger.info "done #{i}..."
          end
        end
      end

      def default_draft_items
        Enumerator.new do |yielder|
          progress_logger = ProgressLogger.new(Edition.latest_edition.count, logger)
          logger.info "Exporting #{progress_logger.count} Editions"

          Edition.latest_edition.find_each do |edition|
            yielder << edition
            progress_logger.inc
          end

          [
            MinisterialRole,
            Organisation,
            Person,
            WorldLocation,
            WorldwideOrganisation
          ].each do |klass|
            progress_logger = ProgressLogger.new(klass.count, logger)
            logger.info "Exporting #{progress_logger.count} #{klass.name}s"

            klass.find_each do |item|
              yielder << item
              progress_logger.inc
            end
          end
        end
      end
    end
  end
end
