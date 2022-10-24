# frozen_string_literal: true

class Admin::Editions::ImageComponent < ViewComponent::Base
  include ErrorsHelper

  attr_reader :image, :index, :checked

  def initialize(image:, index:, checked: true)
    @image = image
    @index = index
    @checked = checked
  end

private

  def title
    image.persisted? ? "Image #{index + 1}" : "New image"
  end

  def edition
    image.edition
  end
end
