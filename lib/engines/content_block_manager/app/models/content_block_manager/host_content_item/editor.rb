module ContentBlockManager
  class HostContentItem
    class Editor < Data.define(:uid, :name, :email, :organisation)
      def self.with_uuids(uuids)
        Services.signon_api_client.get_users(uuids:).map do |user|
          new(
            uid: user["uid"],
            name: user["name"],
            email: user["email"],
            organisation: ContentBlockManager::HostContentItem::Editor::Organisation.from_user_hash(user),
          )
        end
      end
    end
  end
end
