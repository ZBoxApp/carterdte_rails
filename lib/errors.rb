module Errors
  
  class MissingAccountJail < StandardError; end
  class NoElasticSearchResults < StandardError; end
  class UnknownDeliveryStatus < StandardError; end
end