module PublishingApi
  class UnpublishingPresenter
    attr_accessor :item
    attr_accessor :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || "major"
    end

    def content_id
      item.content_id
    end

    def content
      return redirect_hash if item.redirect?
      content = BaseItemPresenter.new(
        item,
        title: edition.title,
        need_ids: edition.need_ids
      ).base_attributes

      content.merge!(
        base_path: base_path,
        description: description,
        details: details,
        document_type: document_type,
        public_updated_at: public_updated_at,
        rendering_app: rendering_app,
        schema_name: schema_name,
      )
      content.merge!(PayloadBuilder::Routes.for(base_path))
    end

    def links
      {}
    end

  private

    def schema_name
      item.redirect? ? 'redirect' : 'unpublishing'
    end

    def document_type
      edition.class.name.underscore
    end

    def base_path
      item.document_path
    end

    def redirect_hash
      {
        base_path: base_path,
        format: 'redirect',
        publishing_app: 'whitehall',
        redirects: [
          { path: base_path, type: 'exact', destination: alternative_path }
        ],
      }
    end

    def edition
      @edition ||= ::Edition.unscoped.find(item.edition_id)
    end

    def rendering_app
      edition.rendering_app
    end

    def description
      edition.summary
    end

    def public_updated_at
      edition.public_timestamp
    end

    def alternative_path
      full_uri = Addressable::URI.parse(item.alternative_url)

      path_uri = Addressable::URI.new(
        path: full_uri.path,
        query: full_uri.query,
        fragment: full_uri.fragment
      )

      path_uri.to_s
    end

    def details
      {
        explanation: unpublishing_explanation,
        unpublished_at: item.created_at,
        alternative_url: item.alternative_url
      }
    end

    def unpublishing_explanation
      if item.try(:explanation).present?
        Whitehall::GovspeakRenderer.new.govspeak_to_html(item.explanation)
      end
    end
  end
end
