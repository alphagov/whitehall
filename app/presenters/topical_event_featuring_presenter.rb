class TopicalEventFeaturingPresenter < Whitehall::Decorators::Decorator
  delegate_instance_methods_of TopicalEventFeaturing

  def image_tag(size)
    model.image.file.url(size || :s630)
  end
end
