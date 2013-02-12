# Turn off XML and JSON parsing:
# https://groups.google.com/forum/#!topic/rubyonrails-security/61bkgvnSGTQ/discussion
ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::XML)
ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::JSON)
