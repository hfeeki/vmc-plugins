require "vmc/cli"

module VMCAdmin
  class Curl < VMC::CLI
    def precondition
      check_target
    end

    desc "Execute a raw request"
    group :admin
    input :mode, :argument => :required,
      :desc => "Request mode (Get/Put/etc.)"
    input :path, :argument => :required,
      :desc => "Request path"
    input :headers, :argument => :splat,
      :desc => "Headers (i.e. Foo: bar)"
    input :body, :alias => "-b",
      :desc => "Request body"
    def curl
      mode = input[:mode].capitalize.to_sym
      path = input[:path]
      body = input[:body]

      headers = {}
      input[:headers].each do |h|
        k, v = h.split(/\s*:\s*/, 2)
        headers[k.downcase] = v
      end

      content = headers["content-type"] || :json
      accept = headers["accept"] || :json
      
      res =
        client.base.request_path(
          Net::HTTP.const_get(mode),
          path.split("/"),
          :headers => headers,
          :accept => accept,
          :payload => body,
          :content => body && content)

      if [:json, "application/json"].include? accept
        puts MultiJson.dump(res, :pretty => true)
      else
        puts res
      end
    end
  end
end
