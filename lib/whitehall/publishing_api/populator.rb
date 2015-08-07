module Whitehall
  class PublishingApi
    class Populator
      attr_reader :items, :logger, :sender

      def initialize(items:, sender:, logger: Logger.new(nil))
        @logger = logger
        @progress_logger = ProgressLogger.new(logger)
        @items = items
        @sender = sender
      end

      def call
        items.each do |item|
          @progress_logger.log(item)
          sender.call(item)
        end

        logger.info "Finished."
      end

      def self.edition_scope
        raise "abstract method not implemented"
      end

      def self.default_items
        Enumerator.new do |yielder|
          edition_scope.find_each do |edition|
            yielder << edition
          end

          [
            MinisterialRole,
            Organisation,
            Person,
            WorldLocation,
            WorldwideOrganisation
          ].each do |klass|
            klass.find_each do |item|
              yielder << item
            end
          end
        end
      end

    private
      class ProgressLogger
        attr_reader :logger

        def initialize(logger)
          @logger = logger
          @i = 0
          @type = nil
        end

        def log(item)
          new_class = item.class
          new_class = new_class.base_class if new_class.respond_to?(:base_class)
          if @type != new_class
            @type = new_class
            logger.info "Exporting items of class '#{@type}'..."
          end

          @i += 1
          if @i % 1000 == 0
            logger.info "done #{@i}..."
          end
        end
      end
    end
  end
end
