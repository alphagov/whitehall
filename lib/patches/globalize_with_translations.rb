# Backport https://github.com/globalize/globalize/pull/489
require 'globalize/active_record/class_methods'
require 'globalize/version'

raise "Check if #{__FILE__} is still needed, we expect it to be redundant with Globalize 5.1.0+. (We are now using #{Globalize::Version})" if Globalize::Version != '5.0.1'

module Globalize
  module ActiveRecord
    module ClassMethods
      def with_translations(*locales)
        locales = translated_locales if locales.empty?
        preload(:translations).joins(:translations).readonly(false).with_locales(locales).uniq
      end
    end
  end
end
