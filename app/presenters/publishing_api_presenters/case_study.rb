module PublishingApiPresenters
  class CaseStudy < PublishingApiPresenters::Edition
    def as_json
      super.merge(format: "case_study")
    end

  private

    def details
      super.merge({
        body: body,
        first_published_at: edition.first_public_at,
      })
    end

    def body
      Whitehall::EditionGovspeakRenderer.new(edition).body
    end
  end
end
