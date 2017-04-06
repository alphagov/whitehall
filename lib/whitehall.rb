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
  mattr_accessor :search_client
  mattr_accessor :skip_safe_html_validation
  mattr_accessor :statistics_announcement_search_client
  mattr_accessor :uploads_cache_max_age

  class NoConfigurationError < StandardError; end

  def self.public_protocol
    Plek.new.website_uri.scheme
  end

  def self.support_url
    Plek.find('support')
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
      zipinfo: "/usr/bin/zipinfo",
      unzip: "/usr/bin/unzip"
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
    @admin_host ||=  URI(admin_root).host
  end

  def self.public_host
    @public_host ||= Plek.new.website_uri.host
  end

  def self.public_root
    @public_root ||= Plek.new.website_root
  end

  def self.admin_root
    @admin_root ||= Plek.find('whitehall-admin')
  end

  # NOOP until alphagov-deployment is updated to not set this in the
  # public_host.rb initializer
  def self.public_host=(_)
  end

  def self.secrets
    @secrets ||= load_secrets
  end

  # The base folder where incoming-uploads and clean-uploads live.
  def self.uploads_root
    (Rails.env.test? ? uploads_root_for_test_env : Rails.root).to_s
  end

  def self.uploads_root_for_test_env
    env_number = ENV['TEST_ENV_NUMBER'].blank? ? '1' : ENV['TEST_ENV_NUMBER']
    Rails.root.join("tmp/test/env_#{env_number}")
  end

  def self.incoming_uploads_root
    File.join(uploads_root, 'incoming-uploads')
  end

  def self.clean_uploads_root
    File.join(uploads_root, 'clean-uploads')
  end

  def self.infected_uploads_root
    File.join(uploads_root, 'infected-uploads')
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
    @edition_actions ||= EditionServiceCoordinator.new
  end

  def self.organisations_in_tagging_beta
    @taggable_organisations ||=
      YAML.load_file(Rails.root + "config/organisations_in_tagging_beta.yml")["organisations_in_tagging_beta"]
  end

  def self.load_secrets
    if File.exists?(secrets_path)
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
