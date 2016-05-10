require_relative "../publishing_api_presenters"

class PublishingApiPresenters::DetailedGuide < PublishingApiPresenters::Edition
  def links
    extract_links([
      :lead_organisations,
      :organisations,
    ]).merge(
      related_guides: related_guides,
      related_mainstream: related_mainstream
    )
  end

private

  def schema_name
    "detailed_guide"
  end

  def details
    super.merge(
      body: body,
      first_public_at: first_public_at,
      change_history: item.change_history.as_json,
      related_mainstream_content: related_mainstream,
      political: item.political?,
      government: government,
    ).tap do |json|
      json[:withdrawn_notice] = withdrawn_notice if item.withdrawn?
      json[:national_applicability] = national_applicability if item.nation_inapplicabilities.any?
    end
  end

  def body
    Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(item)
  end

  def first_public_at
    if item.document.published?
      item.first_public_at
    else
      item.document.created_at.iso8601
    end
  end

  def related_guides
    item.related_detailed_guide_content_ids
  end

  def related_mainstream
    base_paths = []
    base_paths.push(item.related_mainstream_base_path)
    base_paths.push(item.additional_related_mainstream_base_path)
    base_paths.compact!

    if base_paths.any?
      Whitehall.publishing_api_v2_client
        .lookup_content_ids(base_paths: base_paths)
        .values
        .compact
    else
      []
    end
  end

  # Detailed Guides need a government to publish successfully.
  def government
    gov = item.government
    {
      title: gov.name,
      slug: gov.slug,
      current: gov.current?
    }
  end

  def withdrawn_notice
    {
      explanation: unpublishing_explanation,
      withdrawn_at: item.updated_at
    }
  end

  def unpublishing_explanation
    if item.unpublishing.try(:explanation).present?
      Whitehall::GovspeakRenderer.new.govspeak_to_html(item.unpublishing.explanation)
    end
  end

  def nation_to_sym(nation)
    key = nation.tr(' ', '_').downcase.to_sym
  end

  def universally_applicable
    all_nations = %w(England Northern\ Ireland Scotland Wales)
    all_nations.reduce({}) { |hash, nation|
      key = nation_to_sym(nation)
      hash[key] = {
        label: nation,
        applicable: true
      }
      hash
    }
  end

  def national_applicability
    nations = universally_applicable

    inapplicabilities = item.nation_inapplicabilities
    nations = inapplicabilities.reduce(nations) { |hash, inapplicability|
      key = nation_to_sym(inapplicability.nation.name)
      hash[key][:applicable] = false
      hash[key][:alternative_url] = inapplicability.alternative_url if inapplicability.alternative_url
      hash
    }

    nations
  end
end
