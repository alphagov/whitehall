# frozen_string_literal: true

class Admin::EditionImages::UploadedImagesComponent < ViewComponent::Base
  def initialize(edition:)
    @edition = edition
  end
end
