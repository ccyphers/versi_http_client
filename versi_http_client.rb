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


require 'nokogiri'
num_pages=5
1.upto(num_pages) do |page_number|
  params = {'q' => 'blah'}
  if page_number > 1
    params['start'] = (10*page_number)-10
  end

  res = google_api.google_prod.web_search(params)
  doc = Nokogiri.parse(res.body)

  # display titles 
  1.upto(10) do |ct|
    puts doc.search("//*[@id=\"ires\"]/ol/li[#{ct}]/h3/a").children.map { |i| i.to_s}.join(" ") 
  end

end


=end
