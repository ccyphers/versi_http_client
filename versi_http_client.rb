base = File.expand_path(File.dirname(__FILE__))
require "#{base}/lib/browser"
require "#{base}/lib/generator"

require 'yaml'

module VersiHTTPClient

  class Base
    attr_reader :cfg
    def initialize(cfg)
      if cfg.kind_of? String
        @cfg = YAML::load_file cfg
      elsif cfg.kind_of? Hash
        @cfg = cfg
      else
        raise ArgumentError, "Pass in a YAML config file or a Hash"
      end

      extend VersiHTTPClient::Generator
    end
  end

  def self.new(cfg)
    Base.new(cfg)
  end
end

=begin
cfg = YAML::load_file "#{base}/conf/ex.yml"

google_api  = VersiHTTPClient.new(cfg)
puts google_api.google_prod.web_search('q' => 'blah', 'invalid1' => 'invalid1', :invalid2 => 'invalid2')#.inspect
=end
