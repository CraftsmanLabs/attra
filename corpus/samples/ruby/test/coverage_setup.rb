require "simplecov"
require "simplecov_json_formatter" unless defined?(SimpleCov::Formatter::JSONFormatter)
formatters = [SimpleCov::Formatter::JSONFormatter]
if ENV["WITH_PLUGINS"]
  require "simplecov-cobertura"
  require "simplecov-lcov"
  SimpleCov::Formatter::LcovFormatter.config { |c| c.report_with_single_file = true; c.single_report_path = "coverage/lcov.info" }
  formatters += [SimpleCov::Formatter::CoberturaFormatter, SimpleCov::Formatter::LcovFormatter]
end
SimpleCov.formatters = formatters
SimpleCov.start do
  enable_coverage :branch if ENV["BRANCH"]
  enable_coverage :method if ENV["METHOD"] && Gem::Version.new(SimpleCov::VERSION) >= Gem::Version.new("1.0")
  add_filter "/test/"
  track_files "{lib,vendor_lib}/**/*.rb"
end
