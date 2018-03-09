require File.expand_path('../integration', __FILE__)

module Adapters
  class HttpTest < Faraday::TestCase

    def adapter() :http end

    Integration.apply(self, :NonParallel)
  end
end
