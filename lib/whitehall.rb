module Whitehall
  autoload :Random, 'whitehall/random'
  autoload :RandomKey, 'whitehall/random_key'
  autoload :FormBuilder, 'whitehall/form_builder'
  autoload :Uploader, 'whitehall/uploader'

  mattr_accessor :search_backend
  mattr_accessor :government_search_client
  mattr_accessor :mainstream_content_api
  mattr_accessor :stats_collector
  mattr_accessor :skip_safe_html_validation
  mattr_accessor :govuk_delivery_client
  mattr_accessor :public_host

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

  class << self
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

    ADMIN_HOSTS = [
      'whitehall-admin.preview.alphagov.co.uk',
      'whitehall-admin.production.alphagov.co.uk'
    ]

    ANALYTICS_FORMAT = {
      policy: "policy",
      news: "news",
      detailed_guidance: "detailed_guidance"
    }

    def available_locales
      [
        :en, :ar, :az, :be, :bg, :bn, :cs, :cy, :de, :dr, :el,
        :es, 'es-419', :fa, :fr, :he, :hi, :hu, :hy, :id, :it,
        :ja, :ka, :ko, :lt, :lv, :ms, :pl, :ps, :pt, :ro, :ru,
        :si, :sk, :so, :sq, :sr, :sw, :ta, :th, :tk, :tr, :uk,
        :ur, :uz, :vi, :zh, 'zh-hk', 'zh-tw'
      ]
    end

    def system_binaries
      {
        zipinfo: "/usr/bin/zipinfo",
        unzip: "/usr/bin/unzip"
      }
    end

    def asset_host
      ENV['GOVUK_ASSET_ROOT'] || raise(NoConfigurationError, 'Expected GOVUK_ASSET_ROOT to be set. Perhaps you should run your task through govuk_setenv <appname>?')
    end

    def router_prefix
      "/government"
    end

    def admin_hosts
      ADMIN_HOSTS
    end

    def public_hosts
      PUBLIC_HOSTS.values.uniq
    end

    def government_single_domain?(request)
      PUBLIC_HOSTS.values.include?(request.host) || request.headers["HTTP_X_GOVUK_ROUTER_REQUEST"].present?
    end

    def admin_whitelist?(request)
      !Rails.env.production? || ADMIN_HOSTS.include?(request.host)
    end

    def default_cache_max_age
      30.minutes
    end

    def platform
      ENV["FACTER_govuk_platform"] || Rails.env
    end

    def public_host_for(request_host)
      PUBLIC_HOSTS[request_host] || request_host
    end

    def public_protocol
      ENV['FACTER_govuk_platform'] == 'development' ? 'http': 'https'
    end

    def secrets
      @secrets ||= load_secrets
    end

    def aws_access_key_id
      secrets["aws_access_key_id"]
    end

    def aws_secret_access_key
      secrets["aws_secret_access_key"]
    end

    # The base folder where incoming-uploads and clean-uploads live.
    def uploads_root
      (Rails.env.test? ? uploads_root_for_test_env : Rails.root).to_s
    end

    def uploads_root_for_test_env
      env_number = ENV['TEST_ENV_NUMBER'].blank? ? '1' : ENV['TEST_ENV_NUMBER']
      Rails.root.join("tmp/test/env_#{env_number}")
    end

    def incoming_uploads_root
      File.join(uploads_root, 'incoming-uploads')
    end

    def clean_uploads_root
      File.join(uploads_root, 'clean-uploads')
    end

    def infected_uploads_root
      File.join(uploads_root, 'infected-uploads')
    end

    def government_search_index_path
      '/government'
    end

    def detailed_guidance_search_index_path
      '/detailed'
    end

    def government_search_index
      Enumerator.new do |y|
        government_edition_classes.each do |klass|
          klass.search_index.each do |search_index_entry|
            y << search_index_entry
          end
        end
      end
    end

    def detailed_guidance_search_index
      DetailedGuide.search_index
    end

    def edition_classes
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
        Publication
      ]
    end

    def searchable_classes
      additional_classes = [
        Organisation,
        MinisterialRole,
        Person,
        Topic,
        TopicalEvent,
        DocumentSeries,
        CorporateInformationPage,
        OperationalField,
        PolicyAdvisoryGroup,
        PolicyTeam,
        SupportingPage,
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

    def edition_route_path_segments
      %w(news speeches policies publications consultations priority detailed-guides case-studies statistical-data-sets fatalities world-location-news)
    end

    def government_edition_classes
      searchable_classes - [DetailedGuide] - DetailedGuide.descendants
    end

    def analytics_format(format)
      ANALYTICS_FORMAT[format]
    end

    def local_government_features?
      true
    end

    def world_feature?
      true
    end

    def extract_text_feature?
      true
    end

    def rummager_work_queue_name
      'rummager-delayed-indexing'
    end

    def url_maker
      @url_maker ||= Whitehall::UrlMaker.new
    end

    private

    def load_secrets
      if File.exists?(secrets_path)
        YAML.load_file(secrets_path)
      else
        {}
      end
    end

    def secrets_path
      Rails.root + 'config' + 'whitehall_secrets.yml'
    end
  end
end
