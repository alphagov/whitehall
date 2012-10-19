module Whitehall
  autoload :Random, 'whitehall/random'
  autoload :RandomKey, 'whitehall/random_key'
  autoload :FormBuilder, 'whitehall/form_builder'

  mattr_accessor :government_search_client
  mattr_accessor :mainstream_search_client
  mattr_accessor :detailed_guidance_search_client
  mattr_accessor :mainstream_content_api
  mattr_accessor :stats_collector

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

    def asset_host
      ENV['GOVUK_ASSET_HOST']
    end

    def router_prefix
      "/government"
    end

    def admin_hosts
      ADMIN_HOSTS
    end

    def government_single_domain?(request)
      PUBLIC_HOSTS.values.include?(request.host) || request.headers["HTTP_X_GOVUK_ROUTER_REQUEST"].present?
    end

    def admin_whitelist?(request)
      !Rails.env.production? || ADMIN_HOSTS.include?(request.host)
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
      edition_classes = Edition.subclasses - [DetailedGuide] - DetailedGuide.subclasses
      (edition_classes + [MinisterialRole, Organisation, SupportingPage, Topic]).map(&:search_index).sum([])
    end

    def detailed_guidance_search_index
      [DetailedGuide].map(&:search_index).sum([])
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
