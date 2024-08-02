class Api::NewsArticlePresenter
  attr_reader :news_article

  def initialize(news_article)
    @news_article = news_article
  end

  def content
    {
      analytics_identifier: nil,
      base_path: news_article.base_path,
      content_id: news_article.content_id,
      description: news_article.summary,
      details:,
      document_type: news_article.display_type_key,
      first_published_at: news_article.first_published_at,
      links:,
      locale: news_article.primary_locale,
      phase: "live",
      public_updated_at: (news_article.public_timestamp || news_article.updated_at).rfc3339,
      rendering_app: news_article.rendering_app,
      schema_name: "news_article",
      title: news_article.title,
      updated_at: news_article.updated_at,
      withdrawn_notice: {},
    }
  end

  def details
    {
      attachments: [],
      body: Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(news_article),
      change_history: news_article.change_history,
      emphasised_organisations: news_article.lead_organisations.map(&:content_id),
      first_public_at: news_article.first_public_at,
      image: {
        high_resolution_url: news_article.high_resolution_lead_image_url,
        url: news_article.lead_image_url,
        caption: news_article.lead_image_caption,
        alt_text: news_article.lead_image_alt_text.squish,
      },
      political: news_article.political?,
      tags: {
        browse_pages: [],
        topics: [],
      },
    }
  end

  def links
    {
      available_translations: news_article.translations.map do |translation|
        {
          api_path: "/api/content#{news_article.base_path}",
          api_url: "#{Plek.find('content-store')}/api/content#{news_article.base_path}",
          base_path: news_article.base_path,
          content_id: news_article.document.content_id,
          document_type: news_article.display_type_key,
          links: {},
          locale: translation.locale,
          public_updated_at: (news_article.public_timestamp || news_article.updated_at).rfc3339,
          schema_name: "news_article",
          title: translation.title,
          web_url: news_article.public_url(locale: translation.locale),
          withdrawn: news_article.withdrawn?,
        }
      end,
      organisations: news_article.organisations.map do |organisation|
        {
          api_path: "/api/content/government/organisations/#{organisation.slug}",
          api_url: "#{Plek.find('content-store')}/api/content/government/organisations/#{organisation.slug}",
          base_path: organisation.slug,
          content_id: organisation.content_id,
          document_type: "organisation",
          details: {
            acronym: "",
            brand: nil,
            default_news_image: nil,
            logo: {
              crest: organisation.organisation_logo_type.class_name,
              formatted_title: ERB::Util.html_escape(organisation.logo_formatted_name || "").strip.gsub(/(?:\r?\n)/, "<br/>").html_safe,
            },
            organisation_govuk_status: {
              status: organisation.govuk_status,
              updated_at: organisation.closed_at,
              url: organisation.url,
            },
          },
          links: {},
          locale: "en",
          public_updated_at: organisation.updated_at.rfc3339,
          schema_name: "organisation",
          title: organisation.logo_formatted_name,
          web_url: organisation.public_url,
          withdrawn: organisation.closed?,
        }
      end,
    }
  end
end
