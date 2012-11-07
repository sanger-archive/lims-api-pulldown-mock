require 'lims-api/resources/plate_resource'

module Lims::Api
  module Resources
    class PlateResource
	    
      def content_to_stream(s, mime_type)
        s.start_hash
	s.add_key "pools"
	pools = {"1cdc5cac-274d-11e2-93c9-406c8ffffeb6" => {"wells" => ["A7","A8","A9","A10","A11","A12","B7","B8","B9","B10","B11","B12","C7","C8","C9","C10","C11","C12","D7","D8","D9","D10","D11","D12","E7","E8","E9","E10","E11","E12","F7","F8","F9","F10","F11","F12","G7","G8","G9","G10","G11","G12","H7","H8","H9","H10","H11","H12"],"bait_library" => {"target" => {"species" => "Human"},"updated_at" => "2012-11-05T13 => 30 => 01+00 => 00","name" => "Human all exon 50MB","bait_library_type" => "Standard","created_at" => "2012-11-05T13 => 30 => 01+00 => 00","supplier" => {"name" => "Agilent","identifier" => nil}},"library_type" => {"name" => "Agilent Pulldown"},"insert_size" => {"to" => 400,"from" => 100}}, "1c4dd478-274d-11e2-93c9-406c8ffffeb6" => {"wells" => ["A1","A2","A3","A4","A5","A6","B1","B2","B3","B4","B5","B6","C1","C2","C3","C4","C5","C6","D1","D2","D3","D4","D5","D6","E1","E2","E3","E4","E5","E6","F1","F2","F3","F4","F5","F6","G1","G2","G3","G4","G5","G6","H1","H2","H3","H4","H5","H6"],"bait_library" => {"target" => {"species" => "Human"},"updated_at" => "2012-11-05T13 => 30 => 01+00 => 00","name" => "Human all exon 50MB","bait_library_type" => "Standard","created_at" => "2012-11-05T13 => 30 => 01+00 => 00","supplier" => {"name" => "Agilent","identifier" => nil}},"library_type" => {"name" => "Agilent Pulldown"},"insert_size" => {"to" => 400,"from" => 100}}}
  s.add_value pools      
	s.end_hash

      end


    end
  end
end  
