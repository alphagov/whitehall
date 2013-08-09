namespace :topics do
  desc "Map topics assigned via policies directly onto editions"
  task from_policies_to_editions: :environment do

    class TopicTransfer < Struct.new(:logger, :edition)
      def copy_topics_from_policies
        existing_topics = edition.directly_associated_topics.pluck(:id)
        new_topics = policy_topics.select do |topic|
          ! existing_topics.include?(topic.id)
        end
        logger.info "Copying #{new_topics.size} topics to #{edition.slug}"
        edition.directly_associated_topics << new_topics
      end

      def policy_topics
        edition.related_policies.map(&:topics).flatten.uniq
      end
    end

    logger = Logger.new($stderr)

    [Announcement, Publicationesque].each do |edition_type|
      logger.info "-- Associating #{edition_type.name.downcase.pluralize} directly with policies' topics"
      edition_type.find_each do |announcement|
        TopicTransfer.new(logger, announcement).copy_topics_from_policies
      end
    end
  end
end
