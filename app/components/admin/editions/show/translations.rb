# frozen_string_literal: true

class Admin::Editions::Show::Translations < ViewComponent::Base
  def initialize(edition)
    @edition = edition
  end

  def render?
    edition.translatable?
  end

private

  attr_reader :edition
end
