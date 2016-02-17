module ClassificationRoutesHelper
  def classification_path(classification, options = {})
    polymorphic_path(classification_model_name(classification), options.merge(id: classification))
  end

  def classification_url(classification, options = {})
    polymorphic_url(classification_model_name(classification), options.merge(id: classification))
  end

  def public_classification_url(classification, options = {})
    classification_url(classification, public_url_options.merge(options))
  end

  def public_url_options
    { host: Whitehall.public_host, protocol: Whitehall.public_protocol }
  end

  def cachebust_options
    { cachebust: Time.zone.now.getutc.to_i }
  end

private

  # NOTE: This method could (possibly) be dropped once Draper has been removed/replaced.
  def classification_model_name(classification)
    klass = classification.to_model.class
    klass.name.underscore
  end
end
