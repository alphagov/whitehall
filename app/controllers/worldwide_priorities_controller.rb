class WorldwidePrioritiesController < DocumentsController
  before_filter :find_document, only: [:show, :activity]
  helper_method :show_navigation?

  def index
    @worldwide_priorities = WorldwidePriority.published.includes(:document, :translations).in_reverse_chronological_order
  end

  def show
    set_meta_description(@document.summary)
    set_slimmer_headers_for_document(@document)
  end

  def activity
    @related_editions = @document.published_related_editions.with_translations(I18n.locale).in_reverse_chronological_order.page(params[:page]).per(40)
  end

  private

  def show_navigation?
    @document.published_related_editions.any?
  end

  def document_class
    WorldwidePriority
  end
end
