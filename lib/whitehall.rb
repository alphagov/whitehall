module Whitehall
  autoload :Random, 'whitehall/random'
  autoload :RandomKey, 'whitehall/random_key'
  autoload :FormBuilder, 'whitehall/form_builder'
  autoload :Uploader, 'whitehall/uploader'
  autoload :UrlMaker, 'whitehall/url_maker'
  autoload :ExtraQuoteRemover, 'whitehall/extra_quote_remover'
  autoload :GovspeakRenderer, 'whitehall/govspeak_renderer'

  mattr_accessor :content_store
  mattr_accessor :default_cache_max_age
  mattr_accessor :document_collections_cache_max_age
  mattr_accessor :government_search_client
  mattr_accessor :link_checker_api_client
  mattr_accessor :maslow
  mattr_accessor :publishing_api_client
  mattr_accessor :search_backend
  mattr_accessor :force_search_backend
  mattr_accessor :search_client
  mattr_accessor :skip_safe_html_validation
  mattr_accessor :statistics_announcement_search_client
  mattr_accessor :uploads_cache_max_age

  class NoConfigurationError < StandardError; end

  def self.public_protocol
    Plek.new.website_uri.scheme
  end

  def self.support_url
    Plek.new.external_url_for('support')
  end

  def self.available_locales
    [
      :en, :ar, :az, :be, :bg, :bn, :cs, :cy, :de, :dr, :el,
      :es, 'es-419', :et, :fa, :fr, :he, :hi, :hu, :hy, :id,
      :it, :ja, :ka, :ko, :lt, :lv, :ms, :pl, :ps, :pt, :ro,
      :ru, :si, :sk, :so, :sq, :sr, :sw, :ta, :th, :tk, :tr,
      :uk, :ur, :uz, :vi, :zh, 'zh-hk', 'zh-tw'
    ]
  end

  def self.system_binaries
    {
      zipinfo: File.which("zipinfo"),
      unzip: File.which("unzip")
    }
  end

  def self.router_prefix
    "/government"
  end

  def self.asset_root
    @asset_root ||= Plek.new.asset_root
  end

  def self.public_asset_host
    @public_asset_host ||= Plek.new.public_asset_host
  end

  def self.admin_host
    @admin_host ||= URI(admin_root).host
  end

  def self.internal_admin_host
    @internal_admin_host ||=
      URI(Plek.new.find('whitehall-admin')).host
  end

  def self.public_host
    @public_host ||= Plek.new.website_uri.host
  end

  def self.public_root
    @public_root ||= Plek.new.website_root
  end

  def self.admin_root
    @admin_root ||= Plek.new.external_url_for('whitehall-admin')
  end

  def self.secrets
    @secrets ||= load_secrets
  end

  # The base folder where uploads live.
  def self.uploads_root
    (Rails.env.test? ? uploads_root_for_test_env : Rails.root).to_s
  end

  def self.uploads_root_for_test_env
    env_number = ENV['TEST_ENV_NUMBER'].blank? ? '1' : ENV['TEST_ENV_NUMBER']
    Rails.root.join("tmp/test/env_#{env_number}")
  end

  def self.asset_manager_tmp_dir
    File.join(uploads_root, 'asset-manager-tmp')
  end

  def self.edition_classes
    [
      CaseStudy,
      Consultation,
      CorporateInformationPage,
      DetailedGuide,
      DocumentCollection,
      FatalityNotice,
      NewsArticle,
      Publication,
      Speech,
      StatisticalDataSet,
      WorldLocationNewsArticle,
    ]
  end

  def self.edition_route_path_segments
    %w(news speeches policies publications consultations priority detailed-guides case-studies statistical-data-sets fatalities world-location-news collections supporting-pages)
  end

  def self.analytics_format(format)
    {
      policy: "policy",
      news: "news",
      detailed_guidance: "detailed_guidance"
    }[format]
  end

  def self.rummager_work_queue_name
    'rummager-delayed-indexing'
  end

  def self.url_maker
    @url_maker ||= Whitehall::UrlMaker.new(host: Whitehall.public_host, protocol: Whitehall.public_protocol)
  end

  def self.atom_feed_maker
    @atom_feed_maker ||= Whitehall::UrlMaker.new(host: Whitehall.public_host, protocol: Whitehall.public_protocol, format: 'atom')
  end

  def self.edition_services
    @edition_services ||= EditionServiceCoordinator.new
  end

  def self.worldwide_tagging_organisations
    @worldwide_tagging_organisations ||=
      YAML.load_file(Rails.root + "config/worldwide_tagging_organisations.yml")
  end

  def self.load_secrets
    if File.exist?(secrets_path)
      YAML.load_file(secrets_path)
    else
      {}
    end
  end
  private_class_method :load_secrets

  def self.secrets_path
    Rails.root + 'config' + 'whitehall_secrets.yml'
  end
  private_class_method :secrets_path
end
