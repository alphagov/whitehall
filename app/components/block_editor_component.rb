# frozen_string_literal: true

class BlockEditorComponent < ViewComponent::Base
  attr_reader :edition

  def initialize(edition:)
    @edition = edition
  end

  def editor_config
    {
      html: helpers.bare_govspeak_edition_to_html(@edition)
    }
  end
end
