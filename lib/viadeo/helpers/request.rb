require 'active_support/concern'
require 'active_support/notifications'
require 'active_support/core_ext/class/attribute'
require 'curb'

module Viadeo
  module Helpers
    module Request
      extend ActiveSupport::Concern

      included do
        class_attribute :base_url
        self.base_url = 'https://api.viadeo.com/'
      end

      def get(path, query = {}, options={})
        ActiveSupport::Notifications.instrument('viadeo.request', extra: {path: path, query: query, method: :get}) do
          request :get, path, query, nil, options
        end
      end

      %w{post put delete}.each do |method|
        class_eval <<-RUBY, __FILE__, __LINE__+1
          def #{method}(path, query = {}, data = nil, options={})
            ActiveSupport::Notifications.instrument('viadeo.request', extra: {path: path, query: query, method: :#{method}, data: data}) do
              request :#{method}, path, query, data, options
            end
          end
        RUBY
      end

    private

      def curl
        @curl ||= Curl::Multi.new.tap do |curl|
          curl.pipeline = true
        end
      end

      def request(method, path, query, data, options)
        c = Curl::Easy.new(to_uri(base_url, path, query))
        c.ssl_version = Curl::CURL_SSLVERSION_TLSv1
        c.ssl_verify_peer = Rails.env.production? if defined? Rails
        c.encoding = ''
        c.verbose = true

        error = nil
        c.on_failure { |easy, code| error = parse_errors(easy) }
        c.on_missing { |easy, code| error = parse_errors(easy) }

        if !data.respond_to?(:bytesize) && data.respond_to?(:map)
          data = to_query(data)
          c.headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
        end

        case method
        when :get
          # nothing :-)
        when :post
          c.post_body = data
        when :put
          c.put_data = data
        when :delete
          c.post_body = data if data
          c.delete = true
        end

        if defined? VCR
          # VCR doesn't support Curl::Multi
          c.perform
        else
          # reusing the connection if possible
          curl.add(c)
          curl.perform
        end

        raise error, "An error, has occured: http code: #{error.status}, response body: #{error.data.inspect}" if error

        parse_response c
      end

      def parse_response(response)
        headers = parse_headers(response.header_str)
        if json_response?(headers)
          body = Mash.from_json(response.body_str)
        else
          body = response.body_str
        end

        ResponseWrapper.new(response.response_code, headers, body)
      end

      def parse_errors(response)
        parsed_response = parse_response(response)
        klass = case parsed_response.status
        when 401
          Viadeo::Errors::UnauthorizedError
        when 400, 403
          Viadeo::Errors::GeneralError
        when 404
          Viadeo::Errors::NotFoundError
        when 409
          Viadeo::Errors::ConflictError
        when 500
          Viadeo::Errors::InformViadeoError
        when 502..503
          Viadeo::Errors::UnavailableError
        else
          Viadeo::Errors::GeneralError
        end

        klass.new(parsed_response.status, parsed_response.headers, parsed_response.body)
      rescue Exception => e
        puts "#{e.class}: #{e.message}"
        puts e.backtrace
        raise e
      end

      def to_query(options)
        options.map { |k, v| "#{CGI.escape k.to_s}=#{CGI.escape v.to_s}" }.join('&')
      end

      def to_uri(base_url, path, options)
        uri = URI.parse(File.join(base_url, path))

        if options && options != {}
          uri.query = to_query(options)
        end
        uri.to_s
      end

      def parse_headers(str)
        headers = str.split(/\r?\n/)
        status_line = headers.shift
        if status_line =~ %r{^HTTP/\d\.\d 1\d{2}} # 100
          headers.shift # empty line
          status_line = headers.shift
        end
        hash = Headers.new(headers.map { |h| h.split(/:\s*/, 2) })
        hash['Status'] = $1.to_i if status_line =~ %r{^HTTP/\d\.\d (\d{3})}
        hash
      end

      def json_response?(headers)
        ct = headers['Content-Type']
        ct =~ %r{^application/json(?:;|$)}
      end

      class Headers
        include Net::HTTPHeader

        def initialize(headers)
          initialize_http_header(headers)
        end
      end

      ResponseWrapper = Struct.new(:status, :headers, :body)
    end
  end
end
