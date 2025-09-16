require_relative "./generic_edition_presenter"

class GenericEdition < Edition
  include Attachable

  class << self
    attr_accessor :translatable
  end

  def translatable?
    self.class.translatable
  end

  def publishing_api_presenter
    GenericEditionPresenter
  end

  def allows_external_attachments?
    true
  end

  def allows_html_attachments?
    true
  end
end
