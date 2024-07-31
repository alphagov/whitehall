module ContentObjectStore
  class PublishEditionService
    include Publishable

    def initialize(schema)
      @schema = schema
    end

    def call(edition)
      title = edition.title
      details = edition.details
      publish_with_rollback(schema: @schema, title:, details:) do
        edition
      end
      edition
    end
  end
end
