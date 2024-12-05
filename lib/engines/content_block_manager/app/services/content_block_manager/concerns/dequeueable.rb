module ContentBlockManager
  module Concerns
    module Dequeueable
      extend ActiveSupport::Concern

      def dequeue_all_previously_queued_editions(content_block_edition)
        content_block_edition.document.editions.where(state: :scheduled).find_each do |edition|
          next if content_block_edition.id == edition.id

          ContentBlockManager::SchedulePublishingWorker.dequeue(edition)
          edition.supersede!
        end
      end

      def dequeue_current_edition_if_previously_scheduled(content_block_edition)
        ContentBlockManager::SchedulePublishingWorker.dequeue(content_block_edition) if content_block_edition.scheduled?
      end
    end
  end
end
