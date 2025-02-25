module ContentBlockManager
  def self.product_name
    "Content Block Manager"
  end

  def self.support_url
    "#{Plek.external_url_for('support')}/general_request/new"
  end

  def self.router_prefix
    "/content-block-manager"
  end
end
