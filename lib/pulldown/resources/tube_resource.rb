require 'lims-api/resources/tube_resource'

module Lims::Api
  module Resources
    class TubeResource
      
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
              
      def order_uuid
#        debugger
        "af7df460-2112-0130-7567-406c8f37cea7"
      end

      def item
        @order_item ||= @context.store.with_session do |s|
          order = s[order_uuid]
          lambda {
            order.keys.each do |key|
              if order[key].uuid == self.uuid
                return OpenStruct.new(:role => key.to_s, :status => order[key].status.to_s)
              end
            end
            return OpenStruct.new(:role => "mocked", :status => "mocked")
          }
        end.call
        @order_item
      end

      def purpose_uuid
        item.role
      end
      
      def sequencescape_state_mapper(state)
        case state
        when "in_progress" then "started"
        when "done" then "passed"
        else state
        end
      end

      def state
        sequencescape_state_mapper(item.status)
      end
    end
  end
end