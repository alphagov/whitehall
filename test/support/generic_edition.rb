class GenericEdition < Edition
  include Attachable

  class << self
    attr_accessor :translatable
  end

  def translatable?
    self.class.translatable
  end

  def publishing_api_presenter
    PublishingApi::NewsArticlePresenter
  end
end
