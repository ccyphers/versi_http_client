module VersiHTTPClient
  module Generator
    def self.extended(obj)
      tmp = ""

      obj.cfg.each { |site, config|
        tmp += "@#{site} = Class.new\n"
        methods="@agent = VersiHTTPClient::Browser.agent\n"
        config['actions'].each { |meth_name, meth_cfg|
          methods += "def #{meth_name}(params={})\n"
          meth_cfg['required_params'].each { |required_arg|
            methods += "raise ArgumentError unless params['#{required_arg}']\n"
          }
          methods += "@agent.send('#{meth_cfg['request_method']}', '#{config['base_url']}#{meth_cfg['path']}', params)\n"
          methods += "end\n"
        }
        tmp += "@#{site}.instance_eval \"#{methods}\"\n"

        tmp += "class << self\n"
        tmp += "attr_reader :#{site}, :agent\n"
        tmp += "end\n"

      }
      #puts tmp
      obj.instance_eval tmp


    end
  end
end
