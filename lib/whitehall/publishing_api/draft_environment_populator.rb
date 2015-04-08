module Whitehall
  class PublishingApi
    class DraftEnvironmentPopulator
      attr_reader :draft_items

      def initialize(draft_items: default_draft_items)
        @draft_items = draft_items
      end

      def call
        draft_items.each do |edition|
          PublishingApi.publish_draft_async(edition, 'bulk_draft_update', 'bulk_republishing')
        end
      end

      def self.default_draft_items
        Enumerator.new do |yielder|
          Edition.latest_edition.find_each do |edition|
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
    end
  end
end
