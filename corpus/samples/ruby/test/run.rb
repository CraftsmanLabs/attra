require_relative "coverage_setup"
$LOAD_PATH.unshift File.expand_path("../lib", __dir__), File.expand_path("../vendor_lib", __dir__)
require "sample/classify"
require "sample/big"

raise unless Sample.classify(-2) == "negative even"
raise unless Sample.classify(5) == "positive"
raise unless Sample.size(3) == "small"
raise unless Sample.total(1, 2, 3) == 6
raise unless Sample.kind("a") == 1
raise unless Big.run > 0
