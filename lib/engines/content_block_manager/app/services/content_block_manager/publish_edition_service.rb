module ContentBlockManager
  class PublishEditionService
    include Publishable

    def call(edition)
      publish_with_rollback(edition)
    end
  end
end
