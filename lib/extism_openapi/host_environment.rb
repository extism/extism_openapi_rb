require 'extism'
require 'openapi3_parser'
require 'net/http'
require 'uri'

module ExtismOpenapi
  module HostEnvironment
    BASE_URL = 'http://api.lago.dev/api/v1'.freeze

    def initialize(options = {})
      @base_url = options[:base_url]
      @auth = options[:auth]
    end

    def request(endpoint, query_params: nil, body: nil)
      uri = URI "#{@base_url}#{endpoint}"
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = authorization_header
      request['Content-Type'] = 'application/json'
      uri.query = URI.encode_www_form(query_params) unless query_params.nil?
      puts "calling #{uri} with body #{body}"

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end

      # TODO: need a cleaner way to do this without parsing the json
      content = '{"status":'
      content << response.code
      content << ',"content":"application/json","entity":'
      content << response.body
      content << '}'
      content
    end

    def authorization_header
      raise 'Only bearer type auth supported' unless @auth[:type] == :bearer

      "Bearer #{@auth[:token]}"
    end

    def self.included(base)
      base.extend ClassMethods
      base.include Extism::HostEnvironment
    end

    module ClassMethods
      def underscore(p)
        p.gsub(/::/, '/')
         .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
         .gsub(/([a-z\d])([A-Z])/, '\1_\2')
         .tr('-', '_')
         .downcase
      end

      def register(yaml_path)
        document = Openapi3Parser.load_file(yaml_path)
        document.paths.each do |p|
          path, node = p
          node.to_h.each do |k, v|
            next if v.nil?
            next unless %w[get post put delete].include? k
            next unless k == 'get' && %w[findAllBillableMetrics findAllPlans findAllAddOns].include?(v.operation_id)

            # underscore all of them for now
            host_func_name = underscore(v.operation_id).to_sym

            params = []
            params << Extism::ValType::I64 if v.parameters
            params << Extism::ValType::I64 if v.request_body

            register_import host_func_name, params, [Extism::ValType::I64]

            class_eval do
              define_method(host_func_name) do |plugin, inputs, outputs, _user_data|
                query_params = (plugin.input_as_json(inputs.shift) if v.parameters)
                body = (plugin.input_as_string(inputs.shift) if v.request_body)
                resp = request(path, query_params: query_params, body: body)
                plugin.output_string(outputs.first, resp)
              end
            end
          end
        end
      end
    end
  end
end
