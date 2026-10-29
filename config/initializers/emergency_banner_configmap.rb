# Checks to see if the emergency banner configmap is present in the cluster, and creates it
# if not. We want this to be a startup thing because frontend apps relying on mounting
# the configmap will not deploy if it isn't available, so it should be done early.
require "kubernetes/emergency_banner_configmap_client"

if ENV.key?("KUBERNETES_PORT")
  client = Kubernetes::EmergencyBannerConfigmapClient.new

  unless client.configmap_present?
    client.create_empty
  end
end
