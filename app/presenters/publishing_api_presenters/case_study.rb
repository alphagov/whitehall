module PublishingApiPresenters
  class CaseStudy < PublishingApiPresenters::Edition
    def as_json
      super.merge(format: "case_study")
    end

  private

    def details
      super.merge({body: body, first_public_at: edition.first_public_at}).tap do |json|
        json[:image] = image_details if image_available?
      end
    end

    def image_details
      {
        url: Whitehall.asset_root + presented_case_study.lead_image_path,
        alt_text: presented_case_study.lead_image_alt_text,
        caption: presented_case_study.lead_image_caption,
      }
    end

    def body
      Whitehall::EditionGovspeakRenderer.new(edition).body
    end

    def image_available?
      edition.images.any? || lead_organisation_default_image_available?
    end

    def lead_organisation_default_image_available?
      edition.lead_organisations.first.default_news_image.present?
    end

    def presented_case_study
      CaseStudyPresenter.new(edition)
    end
  end
end
