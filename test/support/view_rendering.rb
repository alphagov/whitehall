# This is mostly taken from rspec.
# Specifically: https://raw.github.com/rspec/rspec-rails/52493649d70754377b5e41be1c385a742f268bd7/lib/rspec/rails/view_rendering.rb
# Helpers for optionally rendering views in controller specs.
module ViewRendering
  extend ActiveSupport::Concern

  attr_accessor :controller

  def render_views?
    self.class.view_tests.include?(method_name)
  end

  module ClassMethods
    def view_test(name, &block)
      test(name, &block)
      add_view_test("test_#{name.gsub(/\s+/, '_')}")
    end

    def view_tests
      @view_tests ||= []
    end

    def add_view_test(test_name)
      view_tests << test_name
    end
  end

  class EmptyTemplateResolver
    def self.build(path)
      if path.is_a?(::ActionView::Resolver)
        ResolverDecorator.new(path)
      else
        FileSystemResolver.new(path)
      end
    end

    def self.nullify_template_rendering(templates)
      templates.map do |template|
        ::ActionView::Template.new(
          "",
          template.identifier,
          EmptyTemplateHandler,
          virtual_path: template.virtual_path,
          format: template.format,
          locals: [],
        )
      end
    end

    # Delegates all methods to the submitted resolver and for all methods
    # that return a collection of `ActionView::Template` instances, return
    # templates with modified source
    class ResolverDecorator < ::ActionView::Resolver
      (::ActionView::Resolver.instance_methods - Object.instance_methods).each do |method|
        undef_method method
      end

      (::ActionView::Resolver.methods - Object.methods).each do |method|
        singleton_class.undef_method method
      end

      # rubocop:disable Lint/MissingSuper
      def initialize(resolver)
        @resolver = resolver
      end
      # rubocop:enable Lint/MissingSuper

      # rubocop:disable Style/MissingRespondToMissing
      def method_missing(name, *args, &block)
        result = @resolver.send(name, *args, &block)
        nullify_templates(result)
      end
      # rubocop:enable Style/MissingRespondToMissing

    private

      def nullify_templates(collection)
        return collection unless collection.is_a?(Enumerable)
        return collection unless collection.all? { |element| element.is_a?(::ActionView::Template) }

        EmptyTemplateResolver.nullify_template_rendering(collection)
      end
    end

    # Delegates find_templates to the submitted path set and then returns
    # templates with modified source
    class FileSystemResolver < ::ActionView::FileSystemResolver
    private

      def find_templates(*args)
        templates = super
        EmptyTemplateResolver.nullify_template_rendering(templates)
      end
    end
  end

  class EmptyTemplateHandler
    def self.call(_template, _source = nil)
      ::Rails.logger.info("  Template rendering was prevented by rspec-rails. Use `render_views` to verify rendered view contents if necessary.")

      %("")
    end
  end

  # Used to null out view rendering in controller specs.
  module EmptyTemplates
    def prepend_view_path(new_path)
      super(_path_decorator(*new_path))
    end

    def append_view_path(new_path)
      super(_path_decorator(*new_path))
    end

  private

    def _path_decorator(*paths)
      paths.map { |path| EmptyTemplateResolver.build(path) }
    end
  end

  RESOLVER_CACHE = Hash.new do |hash, path|
    hash[path] = EmptyTemplateResolver.build(path)
  end

  included do
    setup do
      unless render_views?
        @_original_path_set = controller.class.view_paths
        path_set = @_original_path_set.map { |resolver| RESOLVER_CACHE[resolver] }

        controller.class.view_paths = path_set
        controller.extend(EmptyTemplates)
      end
    end

    teardown do
      controller.class.view_paths = @_original_path_set unless render_views?
    end
  end
end
