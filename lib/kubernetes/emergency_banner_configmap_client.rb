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
    EMPTY_PARAMS = {
      campaign_class: "",
      heading: "",
      link: "",
      link_text: "",
      short_description: "",
    }.freeze

    attr_reader :client

    def initialize
      ssl_options = {}
      ssl_options[:ca_file] = CA_FILE if File.exist?(CA_FILE)

      service_host = ENV.fetch("KUBERNETES_SERVICE_HOST", DEFAULT_SERVICE_HOST)
      service_port = ENV.fetch("KUBERNETES_SERVICE_PORT", DEFAULT_SERVICE_PORT)
      api_server = "https://#{service_host}:#{service_port}"

      @client = Kubeclient::Client.new(
        api_server, API_VERSION,
        auth_options: { bearer_token_file: BEARER_TOKEN_FILE },
        ssl_options:
      )
    end

    def namespace
      @namespace ||= File.read(NAMESPACE_FILE)
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

    def load_params
      config_map = @client.get_config_map(NAME, namespace)
      YAML.load(config_map.data[DATA_KEY], symbolize_names: true)
    end

    def update_params(data)
      config_map = @client.get_config_map(NAME, namespace)
      config_map.data[DATA_KEY] = data.stringify_keys.to_yaml
      @client.update_config_map(config_map)
    end
  end
end
