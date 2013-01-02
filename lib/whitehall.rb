module Whitehall
  autoload :Random, 'whitehall/random'
  autoload :RandomKey, 'whitehall/random_key'
  autoload :FormBuilder, 'whitehall/form_builder'
  autoload :Uploader, 'whitehall/uploader'

  mattr_accessor :government_search_client
  mattr_accessor :mainstream_search_client
  mattr_accessor :detailed_guidance_search_client
  mattr_accessor :mainstream_content_api
  mattr_accessor :stats_collector
  mattr_accessor :skip_safe_html_validation

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

    def system_binaries
      {
        zipinfo: "/usr/bin/zipinfo"
      }
    end

    def asset_host
      ENV['GOVUK_ASSET_HOST']
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

    def secrets
      @secrets ||= load_secrets
    end

    def aws_access_key_id
      secrets["aws_access_key_id"]
    end

    def aws_secret_access_key
      secrets["aws_secret_access_key"]
    end

    def asset_storage_mechanism
      if Rails.env.test?
        :file
      elsif %w{preview production}.include?(platform)
        :quarantined_file
      else
        :file
      end
    end

    def clean_upload_path
      Rails.root.join('clean-uploads').realpath
    end

    def government_search_index_name
      '/government'
    end

    def detailed_guidance_search_index_name
      '/detailed'
    end

    def mainstream_search_index_name
      '/mainstream'
    end

    def government_search_index
      (government_edition_classes + [MinisterialRole, Organisation, SupportingPage, Topic, TopicalEvent]).map(&:search_index).sum([])
    end

    def detailed_guidance_search_index
      [DetailedGuide].map(&:search_index).sum([])
    end

    def edition_classes
      [NewsArticle, Speech, Policy, Publication, Consultation, InternationalPriority, DetailedGuide, CaseStudy, StatisticalDataSet, FatalityNotice]
    end

    def edition_route_path_segments
      %w(news speeches policies publications consultations international-priorities detailed-guides case-studies statistical-data-sets fatalities)
    end

    def government_edition_classes
      edition_classes - [DetailedGuide] - DetailedGuide.descendants
    end

    def analytics_format(format)
      ANALYTICS_FORMAT[format]
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
