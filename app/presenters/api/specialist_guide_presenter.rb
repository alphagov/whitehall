class Api::SpecialistGuidePresenter < Draper::Base
  class Paginator < Struct.new(:collection, :params)
    class << self
      def paginate(collection, params)
        new(collection, params).page
      end
    end

    def current_page
      current_page = page_param > 0 ? page_param : 1
    end

    def page
      collection.page(current_page).per(20)
    end

    def page_param
      params[:page].to_i
    end
  end

  class PagePresenter < Draper::Base
    def initialize(page)
      super(page)
    end

    def as_json(options = {})
      {
        results: model.map(&:as_json),
        previous_page_url: previous_page_url,
        next_page_url: next_page_url
      }.reject {|k, v| v.nil? }
    end

    def previous_page_url
      unless model.first_page?
        url(page: model.current_page - 1)
      end
    end

    def next_page_url
      unless model.last_page?
        url(page: model.current_page + 1)
      end
    end

    private

    def url(override_params)
      h.url_for(h.params.merge(override_params.merge(only_path: false)))
    end
  end

  class << self
    def paginate(collection)
      page = Paginator.paginate(collection, h.params)
      PagePresenter.new decorate(page)
    end
  end

  def as_json(options = nil)
    {
      title: model.title,
      id: h.api_specialist_guide_url(model.document),
      web_url: h.specialist_guide_url(model.document),
      details: {
        body: h.govspeak_edition_to_html(model)
      },
      format: model.type.underscore,
      related: related_json
    }
  end

  private

  def related_json
    model.published_related_specialist_guides.map do |guide|
      {
        id: h.api_specialist_guide_url(guide.document),
        title: guide.title,
        web_url: h.specialist_guide_url(guide.document)
      }
    end
  end
end
