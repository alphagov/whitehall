module PublishingApi
  module PayloadBuilder
    class LastEditedByEditorId
      def self.for(item)
        last_author = item.respond_to?(:last_author) ? item.last_author : nil

        return {} if last_author.nil? || last_author.uid.blank?

        { last_edited_by_editor_id: last_author.uid }
      end
    end
  end
end
