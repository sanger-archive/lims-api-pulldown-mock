require 'lims-api/resources/tube_resource'
require 'pulldown/resources/order.rb'

module Lims::Api
  module Resources
    class TubeResource
      include Order
      
      def content_to_stream(s, mime_type)
        s.add_key "aliquots"
        receptacle_to_stream(s, object, mime_type)
        s.add_key "purpose"
        s.with_hash do
          s.add_key "uuid"
          s.add_value purpose_uuid
          s.add_key "name"
          s.add_value purpose_uuid
        end
        s.add_key "state"
        s.add_value state
        s.add_key "type"
        s.add_value "Barcode Printer Type"
        s.add_key "number"
        s.add_value "89"
        s.add_key "ean13"
        s.add_value "EAN13 code"
        s.add_key "prefix"
        
        s.add_value "prefix code"
      end
    end
  end
end
