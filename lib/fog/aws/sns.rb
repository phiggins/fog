module Fog
  module AWS
    class SNS < Fog::Service

      requires :aws_access_key_id, :aws_secret_access_key
      recognizes :host, :path, :port, :scheme, :persistent

      request_path 'fog/aws/requests/sns'
      request :add_permission
      request :create_topic
      request :delete_topic
      request :get_topic_attributes
      request :list_subscriptions
      request :list_subscriptions_by_topic
      request :list_topics
      request :publish

      class Mock

        def initialize(options={})
        end

      end

      class Real

        # Initialize connection to SNS
        #
        # ==== Notes
        # options parameter must include values for :aws_access_key_id and
        # :aws_secret_access_key in order to create a connection
        #
        # ==== Examples
        #   sns = SNS.new(
        #    :aws_access_key_id => your_aws_access_key_id,
        #    :aws_secret_access_key => your_aws_secret_access_key
        #   )
        #
        # ==== Parameters
        # * options<~Hash> - config arguments for connection.  Defaults to {}.
        #
        # ==== Returns
        # * SNS object with connection to AWS.
        def initialize(options={})
          require 'json'
          @aws_access_key_id      = options[:aws_access_key_id]
          @aws_secret_access_key  = options[:aws_secret_access_key]
          @hmac       = Fog::HMAC.new('sha256', @aws_secret_access_key)
          
          options[:region] ||= 'us-east-1'
          @host = options[:host] || case options[:region]
          when 'ap-southeast-1'
            'sns.ap-southeast-1.amazonaws.com'
          when 'eu-west-1'
            'sns.eu-west-1.amazonaws.com'
          when 'us-east-1'
            'sns.us-east-1.amazonaws.com'
          when 'us-west-1'
            'sns.us-west-1.amazonaws.com'
          else
            raise ArgumentError, "Unknown region: #{options[:region].inspect}"
          end

          @path       = options[:path]      || '/'
          @port       = options[:port]      || 443
          @scheme     = options[:scheme]    || 'https'
          @connection = Fog::Connection.new("#{@scheme}://#{@host}:#{@port}#{@path}", options[:persistent])
        end

        def reload
          @connection.reset
        end

        private

        def request(params)
          idempotent  = params.delete(:idempotent)
          parser      = params.delete(:parser)

          body = AWS.signed_params(
            params,
            {
              :aws_access_key_id  => @aws_access_key_id,
              :hmac               => @hmac,
              :host               => @host,
              :path               => @path,
              :port               => @port
            }
          )

          response = @connection.request({
            :body       => body,
            :expects    => 200,
            :idempotent => idempotent,
            :headers    => { 'Content-Type' => 'application/x-www-form-urlencoded' },
            :host       => @host,
            :method     => 'POST',
            :parser     => parser
          })

          response
        end

      end
    end
  end
end
