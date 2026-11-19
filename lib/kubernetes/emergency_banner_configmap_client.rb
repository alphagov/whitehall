require "kubeclient"

module Kubernetes
  class EmergencyBannerConfigmapClient
    API_VERSION = "v1".freeze
    DEFAULT_SERVICE_HOST = "kubernetes.default.svc".freeze
    DEFAULT_SERVICE_PORT = 443
    SERVICE_ACCOUNT = "/var/run/secrets/kubernetes.io/serviceaccount".freeze

    BEARER_TOKEN_FILE = "#{SERVICE_ACCOUNT}/token".freeze
    CA_FILE = "#{SERVICE_ACCOUNT}/ca.crt".freeze
    NAMESPACE_FILE = "#{SERVICE_ACCOUNT}/namespace".freeze

    NAME = "govuk-apps-emergency-banner".freeze
    DATA_KEY = "config.yaml".freeze

    # Configmap will be `deployed: false` when not deployed. When deployed,
    # it will have additional keys:
    #
    # deployed: true
    # campaign_class: (local-emergency|national-emergency|notable-death),
    # heading: string (mandatory)
    # link: url or empty,
    # link_text: string or empty,
    # short_description: string or empty,
    #
    EMPTY_PARAMS = {
      deployed: false,
    }.freeze

    attr_reader :client

    def initialize
      service_host = ENV.fetch("KUBERNETES_SERVICE_HOST", DEFAULT_SERVICE_HOST)
      service_port = ENV.fetch("KUBERNETES_SERVICE_PORT", DEFAULT_SERVICE_PORT)
      api_server = "https://#{service_host}:#{service_port}"

      @client = Kubeclient::Client.new(
        api_server, API_VERSION,
        auth_options: { bearer_token_file: BEARER_TOKEN_FILE },
        ssl_options: { ca_file: CA_FILE }
      )
    end

    def namespace
      @namespace ||= File.read(NAMESPACE_FILE)
    end

    def clear
      config_map = @client.get_config_map(NAME, namespace)
      config_map.data[DATA_KEY] = EMPTY_PARAMS.stringify_keys.to_yaml
      @client.update_config_map(config_map)
    end

    def configmap_present?
      @client.get_config_map(NAME, namespace)

      true
    rescue StandardError
      false
    end

    def create_empty
      @client.create_config_map(
        Kubeclient::Resource.new(
          {
            metadata: {
              name: NAME,
              namespace:,
              annotations: {
                "kubernetes.io/description" => "Emergency banner config applied to relevant frontend apps and read/written by Whitehall.",
              },
            },
            data: {
              DATA_KEY => EMPTY_PARAMS.stringify_keys.to_yaml,
            },
          },
        ),
      )
    end

    def deploy(data)
      config_map = @client.get_config_map(NAME, namespace)
      config_map.data[DATA_KEY] = { deployed: true }.merge(data).stringify_keys.to_yaml
      @client.update_config_map(config_map)
    end
  end
end
