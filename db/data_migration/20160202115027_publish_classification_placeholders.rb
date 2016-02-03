Classification.where.not(content_id: nil).each(&:publish_to_publishing_api)
