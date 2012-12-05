require 'lims-api/resources/plate_resource'

module Lims::Api
  module Resources
    class PlateResource
	    
      def content_to_stream(s, mime_type)
        dimensions_to_stream(s)
        
        s.add_key "pools"
        pools_to_stream(s, mime_type)
        
        s.add_key "wells"
        wells_to_stream(s, mime_type)

        s.add_key "state"
        s.add_value state 

        s.add_key "created_at"
        s.add_value "2012/12/25"

        s.add_key "plate_purpose"
        s.with_hash do
          s.add_key "uuid"
          s.add_value purpose_uuid
          s.add_key "name"
          s.add_value purpose_uuid
          s.add_key "actions"
          s.with_hash do
            s.add_key "read"
            s.add_value "http://localhost:9292/"
          end
          s.add_key "children"
          s.with_hash do
            s.add_key "size"
            s.add_value 1
            s.add_key "actions"
            s.with_hash do
              s.add_key "first"
              s.add_value "http://localhost:9292/plates/page=1"
            end
          end
        end

        s.add_key "source_transfers"
        s.add_value Hash.new

        s.add_key "transfers_to_tubes"
        s.add_value Hash.new
        
        s.add_key "creation_transfer"
        s.add_value Hash.new
      end

      def order_uuid
        "4e52bfb0-204d-0130-7f9f-282066132de2"
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

      def pools_to_stream(s, mime_type)
        s.with_hash do
          s.add_key "1d5d1b9e-274d-11e2-93c9-406c8ffffeb6" 
          s.with_hash do
            s.add_key "wells"
            wells_to_stream(s, mime_type)
          end
        end
      end
    end
  end
end  
