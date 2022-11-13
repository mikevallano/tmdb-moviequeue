# monkey patch for the json gem to fix ruby keyword arg deprecation
# https://github.com/flori/json/issues/399
module JSON
  module_function

  def parse(source, opts = {})
    Parser.new(source, **opts).parse
  end
end
