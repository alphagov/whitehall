module ContentObjectStore
  class PublishEditionService
    include Publishable

    def initialize(schema)
      @schema = schema
    end

    def call(edition)
      publish_with_rollback(@schema) do
        edition
      end
      edition
    end
  end
end
