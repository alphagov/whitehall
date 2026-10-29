require "test_helper"

class Kubernetes::EmergencyBannerConfigmapClientTest < ActiveSupport::TestCase
  test "initialises a client with defaults" do
    File.stubs(:exist?).with(Kubernetes::EmergencyBannerConfigmapClient::CA_FILE)
      .returns(false).once

    Kubeclient::Client.stubs(:new).with(
      Kubernetes::EmergencyBannerConfigmapClient::API_SERVER,
      Kubernetes::EmergencyBannerConfigmapClient::API_VERSION,
      auth_options: { bearer_token_file: Kubernetes::EmergencyBannerConfigmapClient::BEARER_TOKEN_FILE },
      ssl_options: {},
    ).once

    Kubernetes::EmergencyBannerConfigmapClient.new
  end

  test "initialises a client with CA file if exists" do
    File.stubs(:exist?).with(Kubernetes::EmergencyBannerConfigmapClient::CA_FILE)
      .returns(true).once

    Kubeclient::Client.stubs(:new).with(
      Kubernetes::EmergencyBannerConfigmapClient::API_SERVER,
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
        "config.yaml" => "---\ncampaign_class: ''\nheading: ''\nlink: ''\nlink_text: ''\nshort_description: ''\n",
      },
    }
    resource = Kubeclient::Resource.new(config)
    Kubeclient::Resource.stubs(:new).with(config).returns(resource)
    kubeclient.expects(:create_config_map).with(resource)

    client = Kubernetes::EmergencyBannerConfigmapClient.new
    client.stubs(:namespace).returns("apps")

    client.create_empty
  end

  test "#load_params loads parameters from the configmap" do
    kubeclient = mock("kubeclient")
    config = {
      metadata: {
        name: "govuk-apps-emergency-banner",
        namespace: "apps",
        annotations: {
          "kubernetes.io/description" => "Emergency banner config applied to relevant frontend apps and read/written by Whitehall.",
        },
      },
      data: {
        "config.yaml" => "---\ncampaign_class: 'local-emergency'\nheading: 'Test Emergency'\nlink: ''\nlink_text: ''\nshort_description: ''\n",
      },
    }
    resource = Kubeclient::Resource.new(config)
    kubeclient.expects(:get_config_map).with("govuk-apps-emergency-banner", "apps").returns(resource)

    Kubeclient::Client.stubs(:new).returns(kubeclient)

    client = Kubernetes::EmergencyBannerConfigmapClient.new
    client.stubs(:namespace).returns("apps")

    expected_data = {
      campaign_class: "local-emergency",
      heading: "Test Emergency",
      link: "",
      link_text: "",
      short_description: "",
    }

    assert_equal expected_data, client.load_params
  end

  test "#update_params calls update_config_map on the underlying client" do
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
        "config.yaml" => "---\ncampaign_class: ''\nheading: ''\nlink_text: ''\nlink: ''\nshort_description: ''\n",
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
      link: "",
      link_text: "",
      short_description: "",
    }

    client.update_params(data)

    expected_yaml = "---\ncampaign_class: local-emergency\nheading: Test Emergency\nlink: ''\nlink_text: ''\nshort_description: ''\n"
    assert_equal expected_yaml, resource.data["config.yaml"]
  end
end
