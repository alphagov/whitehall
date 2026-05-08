# frozen_string_literal: true

module TabForms
  class SocialMediaTabForm
    include ActiveModel::Model
    include StandardEdition::HasBlockContent

    attr_reader :type_instance
    attr_accessor :edition
    def initialize(edition)
      @edition = edition
      @type_instance = edition.type_instance
    end

    def current_tab_context
      "social_media_accounts"
    end
  end
end