require_relative "./locale"

module Whitehall
  autoload :Random, "whitehall/random"
  autoload :RandomKey, "whitehall/random_key"
  autoload :FormBuilder, "whitehall/form_builder"
  autoload :Uploader, "whitehall/uploader"
  autoload :GovspeakRenderer, "whitehall/govspeak_renderer"

  mattr_accessor :content_store
  mattr_accessor :default_cache_max_age
  mattr_accessor :default_api_cache_max_age
  mattr_accessor :document_collections_cache_max_age
  mattr_accessor :link_checker_api_client
  mattr_accessor :maslow
  mattr_accessor :publishing_api_client
  mattr_accessor :skip_safe_html_validation
  mattr_accessor :uploads_cache_max_age

  class NoConfigurationError < StandardError; end

  def self.public_protocol
    URI(Plek.website_root).scheme
  end

  def self.support_url
    Plek.external_url_for("support")
  end

  def self.product_name
    "Whitehall Publisher"
  end

  def self.available_locales
    Locale.all_keys.map(&:to_sym)
  end

  def self.system_binaries
    {
      zipinfo: File.which("zipinfo"),
      unzip: File.which("unzip"),
    }
  end

  def self.router_prefix
    "/government"
  end

  def self.admin_host
    @admin_host ||= URI(admin_root).host
  end

  def self.internal_admin_host
    @internal_admin_host ||=
      URI(Plek.find("whitehall-admin")).host
  end

  def self.public_host
    @public_host ||= URI(public_root).host
  end

  def self.public_root
    @public_root ||= Plek.website_root
  end

  def self.admin_root
    @admin_root ||= Plek.external_url_for("whitehall-admin")
  end

  # The base folder where uploads live.
  def self.uploads_root
    if Rails.env.test?
      uploads_root_for_test_env.to_s
    else
      (ENV["GOVUK_UPLOADS_ROOT"].presence || Rails.root).to_s
    end
  end

  def self.uploads_root_for_test_env
    env_number = ENV["TEST_ENV_NUMBER"].presence || "1"
    Rails.root.join("tmp/test/env_#{env_number}")
  end

  def self.asset_manager_tmp_dir
    File.join(uploads_root, "asset-manager-tmp")
  end

  def self.bulk_upload_tmp_dir
    @bulk_upload_tmp_dir ||= FileUtils.mkdir_p(File.join(uploads_root, "bulk-upload-zipfile-tmp"))
  end

  def self.edition_classes
    [
      CaseStudy,
      CallForEvidence,
      Consultation,
      CorporateInformationPage,
      DetailedGuide,
      DocumentCollection,
      FatalityNotice,
      LandingPage,
      NewsArticle,
      Publication,
      Speech,
      StatisticalDataSet,
      WorldwideOrganisation,
    ]
  end

  def self.edition_route_path_segments
    %w[news speeches policies publications consultations priority detailed-guides case-studies statistical-data-sets fatalities collections supporting-pages calls-for-evidence worldwide-organisations landing-pages]
  end

  def self.analytics_format(format)
    {
      policy: "policy",
      news: "news",
      detailed_guidance: "detailed_guidance",
    }[format]
  end

  def self.search_api_work_queue_name
    "search_api-delayed-indexing"
  end

  def self.edition_services
    @edition_services ||= EditionServiceCoordinator.new
  end

  def self.worldwide_tagging_organisations
    @worldwide_tagging_organisations ||=
      YAML.load_file(Rails.root.join("config/worldwide_tagging_organisations.yml"))
  end

  def self.image_kinds
    @image_kinds ||= ImageKinds.build_image_kinds(YAML.load_file(Rails.root.join("config/image_kinds.yml")))
  end

  def self.integration_or_staging?
    website_root = ENV.fetch("GOVUK_WEBSITE_ROOT", "")
    %w[integration staging].any? { |environment| website_root.include?(environment) }
  end
end
