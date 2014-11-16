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
          meth_cfg['required_params'] ||= []
          meth_cfg['optional_params'] ||= []
          methods += <<-EOF
           def #{meth_name}(params={})
             required_args = #{meth_cfg['required_params'].inspect}
             optional_args = #{meth_cfg['optional_params'].inspect}
          EOF

          meth_cfg['required_params'].each { |required_arg|
            puts required_arg
            methods += <<-EOF

              raise ArgumentError, "could not find required arg: #{required_arg} " unless params["#{required_arg}"]
            EOF
          }

          methods += <<-EOF
            expected_keys = required_args + optional_args
            params.delete_unexpected_keys(expected_keys)
          EOF
          if meth_cfg['resource']
            methods += "p = {}\n"
            methods += "resource = '#{meth_cfg['resource']}'\n"
            #methods += "params.each { |k,v| p['#{meth_cfg['resource']}[\"\#{k}\"]'] = v }\n"
            methods += "params.each { |k,v|\n"
            #methods += "require 'debugger';debugger\n"
            methods += "p[\"\\\#{resource}[\\\#{k}]\"]=v }\n"
            methods += "@agent.send('#{meth_cfg['request_method']}', '#{config['base_url']}#{meth_cfg['path']}', p)\n"
            #methods += "params.each { |k,v| require 'debugger';debugger ; false }\n"
          else
            methods += "@agent.send('#{meth_cfg['request_method']}', '#{config['base_url']}#{meth_cfg['path']}', params)\n"
          end

          methods += "end\n"

        }
        methods.gsub!(/"/, "\\\"")

        puts methods
        tmp += "@#{site}.instance_eval \"#{methods}\"\n"

        tmp += "class << self\n"
        tmp += "attr_reader :#{site}, :agent\n"
        tmp += "end\n"

      }

      obj.instance_eval tmp


    end
  end
end
