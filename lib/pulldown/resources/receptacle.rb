#resource_helper.rb
module Lims::Api
  module Resources
    module MockedReceptacle

      # add a state property corresponding to the state of the item
      # It's used to display properly the well color in pulldown
      def receptacle_to_stream(s, receptacle, mime_type)
        s.with_array do
          receptacle.each do |aliquot|
            s.with_hash do
              s.add_key "state"
              s.add_value state
              aliquot.attributes.each do |k,v|
                case v
                when nil # skip nill value
                  next
                when Lims::Core::Resource
                  s.add_key k
                  resource = @context.resource_for(v,@context.find_model_name(v.class))
                  s.with_hash do
                    resource.encoder_for([mime_type]).actions_to_stream(s)
                  end
                  k = nil # to skip default  assignation to key
                end
                if k
                  s.add_key k
                  s.add_value v
                end
              end
            end 
          end
        end
      end
    end
  end
end


