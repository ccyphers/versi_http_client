class Hash
  def delete_unexpected_keys(expected_keys = [])
    self.each { |k,v|
      self.delete(k) unless expected_keys.include? k
    }
  end
end

module VersiHTTPClient

  module Generator
    def self.extended(obj)
      tmp = ""

      obj.cfg.each { |site, config|
        tmp += "@#{site} = Class.new\n"
        methods="@agent = VersiHTTPClient::Browser.agent\n"
        config['actions'].each { |meth_name, meth_cfg|
          methods += "def #{meth_name}(params={})\n"
          methods += "required_args = #{meth_cfg['required_params'].inspect}\n"
          methods += "optional_args = #{meth_cfg['optional_params'].inspect}\n"

          meth_cfg['required_params'].each { |required_arg|
            methods += "raise ArgumentError unless params['#{required_arg}']\n"
          }

          methods += "expected_keys = required_args + optional_args\n"
          methods += "params.delete_unexpected_keys(expected_keys)\n"
          #methods += "puts params.inspect\n"
          methods += "@agent.send('#{meth_cfg['request_method']}', '#{config['base_url']}#{meth_cfg['path']}', params)\n"
          methods += "end\n"
        }
        methods.gsub!(/"/, "'")

        #puts methods
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
