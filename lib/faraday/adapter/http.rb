module Faraday
  class Adapter
    class HTTP < Faraday::Adapter
      dependency 'http'

      # Hook into Faraday and perform the request with HTTP.rb.
      #
      # @param [ Hash ] env The environment.
      #
      # @return [ void ]
      def call(env)
        super
        perform_request(env)
        @app.call env
      end

      private

      def perform_request(env)
        conn = ::HTTP

        if req = env[:request]
          if timeout = req[:timeout]
            conn = conn.timeout(:connect => timeout, :read => timeout, :write => timeout)
          end

          if timeout = req[:open_timeout]
            conn = conn.timeout(:connect => timeout, :write => timeout)
          end

          if proxy = req[:proxy]
            conn = conn.via(proxy.uri.host, proxy.uri.port, proxy.user, proxy.password)
          end
        end

        conn = conn.headers(env.request_headers)

        begin
          resp = conn.request env[:method], env[:url], :body => env[:body]
          save_response env, resp.code, resp.body.to_s, resp.headers, resp.status.reason
        rescue ::HTTP::TimeoutError
          raise Faraday::Error::TimeoutError, $!
        rescue ::HTTP::ConnectionError
          raise Faraday::Error::ConnectionFailed, $!
        end
      end
    end
  end
end
