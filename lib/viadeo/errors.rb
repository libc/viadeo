module Viadeo
  module Errors
    class ViadeoError < StandardError
      attr_reader :data, :status, :headers
      def initialize(status = 500, headers = nil, data = nil)
        @data = data
        @headers = headers
        @status = status
        super()
      end
    end

    class RateLimitExceededError < ViadeoError; end
    class UnauthorizedError      < ViadeoError; end
    class GeneralError           < ViadeoError; end

    class UnavailableError       < ViadeoError; end
    class InformViadeoError      < ViadeoError; end
    class NotFoundError          < ViadeoError; end
  end
end
