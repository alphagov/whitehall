module Whitehall
  autoload :Random, 'whitehall/random'
  autoload :RandomKey, 'whitehall/random_key'
  autoload :FormBuilder, 'whitehall/form_builder'
  autoload :QuietAssetLogger, 'whitehall/quiet_asset_logger'
  autoload :Presenters, 'whitehall/presenters'
  autoload :SearchClient, 'whitehall/search_client'

  class << self
    PUBLIC_HOSTS = {
      'whitehall.preview.alphagov.co.uk'    => 'www.preview.alphagov.co.uk',
      'whitehall.production.alphagov.co.uk' => 'www.gov.uk'
    }

    def router_prefix
      "/government"
    end

    def government_single_domain?(request)
      PUBLIC_HOSTS.values.include?(request.host) || request.headers["HTTP_X_GOVUK_ROUTER_REQUEST"].present?
    end

    def platform
      ENV["FACTER_govuk_platform"] || Rails.env
    end

    def public_host_for(request_host)
      if PUBLIC_HOSTS.values.include?(request_host)
        request_host
      else
        PUBLIC_HOSTS[request_host]
      end
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

    def use_s3?
      !Rails.env.test? && aws_access_key_id && aws_secret_access_key
    end

    def search_index
      [Edition, MinisterialRole, Organisation, SupportingPage, PolicyTopic].map(&:search_index).sum([])
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