require "test_helper"

class Kubernetes::EmergencyBannerConfigmapClientTest < ActiveSupport::TestCase
  DEFAULT_API_SERVER = "https://kubernetes.default.svc:443".freeze
  DEPLOYED_BANNER_YAML = "---\ndeployed: true\ncampaign_class: local-emergency\nheading: Test Emergency\nlink:\nlink_text:\nshort_description:\n".freeze
  EMPTY_BANNER_YAML = "---\ndeployed: false\n".freeze

  test "initialises a client with defaults" do
    Kubeclient::Client.stubs(:new).with(
      DEFAULT_API_SERVER,
      Kubernetes::EmergencyBannerConfigmapClient::API_VERSION,
      auth_options: { bearer_token_file: Kubernetes::EmergencyBannerConfigmapClient::BEARER_TOKEN_FILE },
      ssl_options: { ca_file: Kubernetes::EmergencyBannerConfigmapClient::CA_FILE },
    ).once

    Kubernetes::EmergencyBannerConfigmapClient.new
  end

  test "#namespace returns the namespace stored filepath" do
    Kubeclient::Client.stubs(:new)

    File.stubs(:read).with(Kubernetes::EmergencyBannerConfigmapClient::NAMESPACE_FILE)
      .returns("apps").once

    client = Kubernetes::EmergencyBannerConfigmapClient.new

    assert_equal "apps", client.namespace
  end

  test "#clear calls update_config_map on the underlying client with an empty banner" do
    kubeclient = mock("kubeclient")
    Kubeclient::Client.stubs(:new).returns(kubeclient)

    config = {
      metadata: {
        name: "govuk-apps-emergency-banner",
        namespace: "apps",
        annotations: {
          "kubernetes.io/description" => "Emergency banner config applied to relevant frontend apps and read/written by Whitehall.",
        },
      },
      data: {
        "config.yaml" => DEPLOYED_BANNER_YAML,
      },
    }
    resource = Kubeclient::Resource.new(config)
    kubeclient.expects(:get_config_map).with("govuk-apps-emergency-banner", "apps").returns(resource)

    kubeclient.expects(:update_config_map).with(resource)

    client = Kubernetes::EmergencyBannerConfigmapClient.new
    client.stubs(:namespace).returns("apps")

    client.clear

    assert_equal EMPTY_BANNER_YAML, resource.data["config.yaml"]
  end

  test "#configmap_present? returns false if configmap is absent" do
    kubeclient = mock("kubeclient")
    kubeclient.expects(:get_config_map).with("govuk-apps-emergency-banner", "apps").raises(StandardError)

    Kubeclient::Client.stubs(:new).returns(kubeclient)

    client = Kubernetes::EmergencyBannerConfigmapClient.new
    client.stubs(:namespace).returns("apps")

    assert_equal false, client.configmap_present?
  end

  test "#configmap_present? returns true if configmap is present" do
    kubeclient = mock("kubeclient")
    config_map = mock("config_map")
    kubeclient.expects(:get_config_map).with("govuk-apps-emergency-banner", "apps").returns(config_map)

    Kubeclient::Client.stubs(:new).returns(kubeclient)

    client = Kubernetes::EmergencyBannerConfigmapClient.new
    client.stubs(:namespace).returns("apps")

    assert_equal true, client.configmap_present?
  end

  test "#create_empty calls create_config_map on the underlying client" do
    kubeclient = mock("kubeclient")
    Kubeclient::Client.stubs(:new).returns(kubeclient)

    config = {
      metadata: {
        name: "govuk-apps-emergency-banner",
        namespace: "apps",
        annotations: {
          "kubernetes.io/description" => "Emergency banner config applied to relevant frontend apps and read/written by Whitehall.",
        },
      },
      data: {
        "config.yaml" => EMPTY_BANNER_YAML,
      },
    }
    resource = Kubeclient::Resource.new(config)
    Kubeclient::Resource.stubs(:new).with(config).returns(resource)
    kubeclient.expects(:create_config_map).with(resource)

    client = Kubernetes::EmergencyBannerConfigmapClient.new
    client.stubs(:namespace).returns("apps")

    client.create_empty
  end

  test "#deploy calls update_config_map on the underlying client" do
    kubeclient = mock("kubeclient")
    Kubeclient::Client.stubs(:new).returns(kubeclient)

    config = {
      metadata: {
        name: "govuk-apps-emergency-banner",
        namespace: "apps",
        annotations: {
          "kubernetes.io/description" => "Emergency banner config applied to relevant frontend apps and read/written by Whitehall.",
        },
      },
      data: {
        "config.yaml" => EMPTY_BANNER_YAML,
      },
    }
    resource = Kubeclient::Resource.new(config)
    kubeclient.expects(:get_config_map).with("govuk-apps-emergency-banner", "apps").returns(resource)

    kubeclient.expects(:update_config_map).with(resource)

    client = Kubernetes::EmergencyBannerConfigmapClient.new
    client.stubs(:namespace).returns("apps")

    data = {
      campaign_class: "local-emergency",
      heading: "Test Emergency",
      link: nil,
      link_text: nil,
      short_description: nil,
    }

    client.deploy(data)

    assert_equal ({ deployed: true }.merge(data)), YAML.load(resource.data["config.yaml"], symbolize_names: true)
  end
end
