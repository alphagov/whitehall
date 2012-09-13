module PluralizeHelper
  include ActiveSupport::Concern

  include ActionView::Helpers::TextHelper

  def pluralize(count, singular, plural = nil, &block)
    if block_given?
      count_str = count || 0
      suffix = count.to_i == 1 ? singular : (plural || singular.pluralize)
      capture(count_str, suffix, &block)
    else
      super
    end
  end
end
