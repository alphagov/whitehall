# This is mostly taken from rspec.
# Specifically: https://raw.github.com/rspec/rspec-rails/52493649d70754377b5e41be1c385a742f268bd7/lib/rspec/rails/view_rendering.rb
module ViewRendering
  extend ActiveSupport::Concern

  attr_accessor :controller

  def render_views?
    self.class.view_tests.include?(self.method_name)
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
      self.view_tests << test_name
    end
  end
  # Delegates find_all to the submitted path set and then returns templates
  # with modified source
  class EmptyTemplatePathSetDecorator < ::ActionView::Resolver
    attr_reader :original_path_set

    def initialize(original_path_set)
      @original_path_set = original_path_set
    end

    def find_all(*args)
      original_path_set.find_all(*args).collect do |template|
        ::ActionView::Template.new(
          "",
          template.identifier,
          EmptyTemplateHandler,
          {
            virtual_path: template.virtual_path,
            format: template.formats
          }
        )
      end
    end
  end

  class EmptyTemplateHandler
    def self.call(template)
      %("")
    end
  end

  module EmptyTemplates
    def prepend_view_path(new_path)
      lookup_context.view_paths.unshift(*_path_decorator(new_path))
    end

    def append_view_path(new_path)
      lookup_context.view_paths.push(*_path_decorator(new_path))
    end

  private

    def _path_decorator(path)
      EmptyTemplatePathSetDecorator.new(ActionView::PathSet.new(Array.wrap(path)))
    end
  end

  included do
    setup do
      unless render_views?
        @_empty_view_path_set_delegator = EmptyTemplatePathSetDecorator.new(controller.class.view_paths)
        controller.class.view_paths = ::ActionView::PathSet.new.push(@_empty_view_path_set_delegator)
        controller.extend(EmptyTemplates)
      end
    end

    teardown do
      unless render_views?
        controller.class.view_paths = @_empty_view_path_set_delegator.original_path_set
      end
    end
  end
end
