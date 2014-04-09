class ClassificationFeaturingPresenter < Whitehall::Decorators::Decorator
  delegate_instance_methods_of ClassificationFeaturing

  def image_tag(size)
    image_url = model.image.file.url(size || :s630)
    context.image_tag image_url, class: 'featured-image', alt: model.alt_text
  end
end
