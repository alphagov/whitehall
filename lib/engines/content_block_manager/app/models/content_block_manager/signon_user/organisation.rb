module ContentBlockManager
  class SignonUser
    class Organisation < Data.define(:content_id, :name, :slug)
      def self.from_user_hash(user)
        if user["organisation"].present?
          new(
            content_id: user["organisation"]["content_id"],
            name: user["organisation"]["name"],
            slug: user["organisation"]["slug"],
          )
        end
      end
    end
  end
end
