# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
ActiveSupport::Inflector.inflections(:en) do |inflect|
  #   inflect.plural /^(ox)$/i, '\1en'
  #   inflect.singular /^(ox)en/i, '\1'
  #   inflect.irregular 'person', 'people'
  #   inflect.uncountable %w( fish sheep )
  inflect.acronym "FOI"
  inflect.acronym "BSL"
  inflect.plural %r{^(Minister)}, '\0s'
  inflect.plural %r{^Chancellor}, '\0s'
  inflect.plural %r{\A(call)(.*evidence)\z}i, '\1s\2'
  inflect.singular %r{\A(call)s(.*evidence)\z}i, '\1\2'
end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym "RESTful"
# end
