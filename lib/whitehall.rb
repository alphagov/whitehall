module Whitehall
  autoload :Random, 'whitehall/random'
  autoload :RandomKey, 'whitehall/random_key'
  autoload :FormBuilder, 'whitehall/form_builder'
  autoload :Uploader, 'whitehall/uploader'

  mattr_accessor :search_backend
  mattr_accessor :government_search_client
  mattr_accessor :content_api
  mattr_accessor :stats_collector
  mattr_accessor :public_host
  mattr_accessor :skip_safe_html_validation
  mattr_accessor :govuk_delivery_client
  mattr_accessor :default_cache_max_age
  mattr_accessor :organisations_transition_visualisation_feature_enabled

  revision_file = "#{Rails.root}/REVISION"
  if File.exists?(revision_file)
    CURRENT_RELEASE_SHA = File.read(revision_file).chomp
  else
    CURRENT_RELEASE_SHA = "development"
  end

  asset_host_override = Rails.root.join("config/initializers/asset_host.rb")
  if File.exist?(asset_host_override)
    load asset_host_override
  end

  class NoConfigurationError < StandardError; end

  PUBLIC_HOSTS = {
    'whitehall.preview.alphagov.co.uk'    => 'www.preview.alphagov.co.uk',
    'whitehall.production.alphagov.co.uk' => 'www.gov.uk',
    'whitehall-admin.preview.alphagov.co.uk' => 'www.preview.alphagov.co.uk',
    'whitehall-admin.production.alphagov.co.uk' => 'www.gov.uk',
    'whitehall-frontend.preview.alphagov.co.uk' => 'www.preview.alphagov.co.uk',
    'whitehall-frontend.production.alphagov.co.uk' => 'www.gov.uk',
    'public-api.preview.alphagov.co.uk' => 'www.preview.alphagov.co.uk',
    'public-api.production.alphagov.co.uk' => 'www.gov.uk'
  }

  def self.public_protocol
    if Rails.env.development? || Rails.env.test?
      'http'
    else
      'https'
    end
  end

  def self.available_locales
    [
      :en, :ar, :az, :be, :bg, :bn, :cs, :cy, :de, :dr, :el,
      :es, 'es-419', :fa, :fr, :he, :hi, :hu, :hy, :id, :it,
      :ja, :ka, :ko, :lt, :lv, :ms, :pl, :ps, :pt, :ro, :ru,
      :si, :sk, :so, :sq, :sr, :sw, :ta, :th, :tk, :tr, :uk,
      :ur, :uz, :vi, :zh, 'zh-hk', 'zh-tw'
    ]
  end

  def self.system_binaries
    {
      zipinfo: "/usr/bin/zipinfo",
      unzip: "/usr/bin/unzip"
    }
  end

  def self.asset_host
    ENV['GOVUK_ASSET_ROOT'] || raise(NoConfigurationError, 'Expected GOVUK_ASSET_ROOT to be set. Perhaps you should run your task through govuk_setenv <appname>?')
  end

  def self.router_prefix
    "/government"
  end

  def self.admin_hosts
    [
      'whitehall-admin.preview.alphagov.co.uk',
      'whitehall-admin.production.alphagov.co.uk'
    ]
  end

  def self.public_hosts
    PUBLIC_HOSTS.values.uniq
  end

  def self.government_single_domain?(request)
    PUBLIC_HOSTS.values.include?(request.host) || request.headers["HTTP_X_GOVUK_ROUTER_REQUEST"].present?
  end

  def self.admin_whitelist?(request)
    (! Rails.env.production?) || admin_hosts.include?(request.host)
  end

  def self.public_host_for(request_host)
    PUBLIC_HOSTS[request_host] || request_host
  end

  def self.secrets
    @secrets ||= load_secrets
  end

  def self.aws_access_key_id
    secrets["aws_access_key_id"]
  end

  def self.aws_secret_access_key
    secrets["aws_secret_access_key"]
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

  def self.government_search_index_path
    '/government'
  end

  def self.detailed_guidance_search_index_path
    '/detailed'
  end

  def self.government_search_index
    Enumerator.new do |y|
      government_edition_classes.each do |klass|
        klass.search_index.each do |search_index_entry|
          y << search_index_entry
        end
      end
    end
  end

  def self.detailed_guidance_search_index
    DetailedGuide.search_index
  end

  def self.edition_classes
    [
      CaseStudy,
      FatalityNotice,
      WorldwidePriority,
      StatisticalDataSet,
      Policy,
      Consultation,
      WorldLocationNewsArticle,
      Speech,
      DetailedGuide,
      NewsArticle,
      Publication,
      DocumentCollection,
      SupportingPage
    ]
  end

  def self.searchable_classes
    additional_classes = [
      Organisation,
      MinisterialRole,
      Person,
      Topic,
      TopicalEvent,
      CorporateInformationPage,
      OperationalField,
      PolicyAdvisoryGroup,
      PolicyTeam,
      TakePartPage
    ]
    not_yet_searchable_classes = []
    if world_feature?
      additional_classes += [
        WorldLocation,
        WorldwideOrganisation
      ]
    else
      not_yet_searchable_classes += [
        WorldLocationNewsArticle,
        WorldwidePriority
      ]
    end
    additional_classes + edition_classes - not_yet_searchable_classes
  end

  def self.edition_route_path_segments
    %w(news speeches policies publications consultations priority detailed-guides case-studies statistical-data-sets fatalities world-location-news collections supporting-pages)
  end

  def self.government_edition_classes
    (searchable_classes - detailed_edition_classes).uniq
  end

  def self.detailed_edition_classes
    ([DetailedGuide] - DetailedGuide.descendants).uniq
  end

  def self.analytics_format(format)
    {
      policy: "policy",
      news: "news",
      detailed_guidance: "detailed_guidance"
    }[format]
  end

  def self.local_government_features?
    true
  end

  def self.world_feature?
    true
  end

  def self.extract_text_feature?
    (ENV['WHITEHALL_EXTRACT_TEXT_FEATURE'] || true).to_s =~ /^(1|true)$/
  end

  def self.rummager_work_queue_name
    'rummager-delayed-indexing'
  end

  def self.url_maker
    @url_maker ||= Whitehall::UrlMaker.new(host: Whitehall.public_host, protocol: Whitehall.public_protocol)
  end

  def self.edition_services
    @edition_actions ||= EditionServiceCoordinator.new
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
