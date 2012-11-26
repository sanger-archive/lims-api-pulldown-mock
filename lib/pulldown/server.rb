require 'lims-api/server'
require 'pulldown/resources/plate_resource'
require 'rubygems'
require 'ruby-debug/debugger'

module Lims
  module Api
    module Pulldown
      def initialize(app)
        @app=app
      end
      # This class allow to do a around filter , around the normal server.
      # This is necessary to add new url (otherwire they are caught by the '*' in the normal server
      # and generates a general error.
      #
      # filters actually modifying @resource  needs to be defined in the normal server
      class Server < Sinatra::Base
        # call normal server if this one doesn't handle properly the current request
        def call(env)
          status, body, header = response = super(env)
          if status == 404
            @app.call(env)
          else
            response
          end
        end

        post '/pulldown/search-:extra/all' do
          _status, header, body= call(env.merge("PATH_INFO" => '/plates/page=1', "REQUEST_METHOD" => "GET"))
	        status 300
          headers({"Content-Type" => header["Content-Type"]})
          h = JSON.parse(body.first)
          h["actions"]["all"] = h["plates"]
          [{"searches" => h["plates"].map { |p| p["plate"].merge({:state => "mocked state",
                                                                 :created_at => "2012/12/25",
                                                                 :plate_purpose => {:name => "plate purpose"} })},
            "size" => h["size"], 
            "success" => 1
          }.to_json]
        end

	      get '/pulldown/search-:extra/all' do
          call(env.merge("REQUEST_METHOD" => "POST"))
        end

	      get '/pulldown/search-:extra' do
          path=request.url
          headers({"Content-Type" => 'application/json'})
          {"search" =>  {
            "actions" =>  {
            "read" =>  "#{path}",
            "first" =>  "#{path}/first",
            "last" =>  "#{path}/last",
            "all" =>  "#{path}/all"}
          }
          }.to_json
        end

        get '/' do
          status, header, body = @app.call(env) 
          headers({"Content-Type" => "application/json"})
          path = request.url
          h = JSON.parse(body.first)
          h["barcode_printers"] = {"actions" => {"first" => "#{path}barcode_printers"}}
          h["state_changes"] = {"actions" => {"first" => "#{path}state_changes", "create" => "#{path}state_changes"}}
          h["transfer_templates"] = {"actions" => {"first" => "#{path}transfer_templates"}}
          h["plate_creations"] = {"actions" => {"create" => "#{path}plates"}}
          h.to_json
        end

        get '/barcode_printers' do
          path = request.url
          headers({"Content-Type" => "application/json"})
          {"size" => 1,
            "barcode_printers" => [{"actions" => {"first" => "#{path}"}}],
            "actions" => {
            "first" => "#{path}",
            "read" => "#{path}",
            "last" => "#{path}"}}.to_json
        end
        
        get '/transfer_templates_1_12' do
          path_preview = request.url
          path = path_preview - request.env["PATH_INFO"]
          headers({"Content-Type" => "application/json"})
          { "transfer_template" => { "actions" => { "create" => "#{path}/actions/plate_transfer",
                    "preview" => "#{path_preview}/preview",
                    "read" => "#{path}/actions/plate_transfer"
                  },
                "created_at" => "2012-11-20T16:46:14+00:00",
                "name" => "Transfer columns 1-12",
                "transfers" => { "A1" => "A1",
                    "A10" => "A10",
                    "A11" => "A11",
                    "A12" => "A12",
                    "A2" => "A2",
                    "A3" => "A3",
                    "A4" => "A4",
                    "A5" => "A5",
                    "A6" => "A6",
                    "A7" => "A7",
                    "A8" => "A8",
                    "A9" => "A9",
                    "B1" => "B1",
                    "B10" => "B10",
                    "B11" => "B11",
                    "B12" => "B12",
                    "B2" => "B2",
                    "B3" => "B3",
                    "B4" => "B4",
                    "B5" => "B5",
                    "B6" => "B6",
                    "B7" => "B7",
                    "B8" => "B8",
                    "B9" => "B9",
                    "C1" => "C1",
                    "C10" => "C10",
                    "C11" => "C11",
                    "C12" => "C12",
                    "C2" => "C2",
                    "C3" => "C3",
                    "C4" => "C4",
                    "C5" => "C5",
                    "C6" => "C6",
                    "C7" => "C7",
                    "C8" => "C8",
                    "C9" => "C9",
                    "D1" => "D1",
                    "D10" => "D10",
                    "D11" => "D11",
                    "D12" => "D12",
                    "D2" => "D2",
                    "D3" => "D3",
                    "D4" => "D4",
                    "D5" => "D5",
                    "D6" => "D6",
                    "D7" => "D7",
                    "D8" => "D8",
                    "D9" => "D9",
                    "E1" => "E1",
                    "E10" => "E10",
                    "E11" => "E11",
                    "E12" => "E12",
                    "E2" => "E2",
                    "E3" => "E3",
                    "E4" => "E4",
                    "E5" => "E5",
                    "E6" => "E6",
                    "E7" => "E7",
                    "E8" => "E8",
                    "E9" => "E9",
                    "F1" => "F1",
                    "F10" => "F10",
                    "F11" => "F11",
                    "F12" => "F12",
                    "F2" => "F2",
                    "F3" => "F3",
                    "F4" => "F4",
                    "F5" => "F5",
                    "F6" => "F6",
                    "F7" => "F7",
                    "F8" => "F8",
                    "F9" => "F9",
                    "G1" => "G1",
                    "G10" => "G10",
                    "G11" => "G11",
                    "G12" => "G12",
                    "G2" => "G2",
                    "G3" => "G3",
                    "G4" => "G4",
                    "G5" => "G5",
                    "G6" => "G6",
                    "G7" => "G7",
                    "G8" => "G8",
                    "G9" => "G9",
                    "H1" => "H1",
                    "H10" => "H10",
                    "H11" => "H11",
                    "H12" => "H12",
                    "H2" => "H2",
                    "H3" => "H3",
                    "H4" => "H4",
                    "H5" => "H5",
                    "H6" => "H6",
                    "H7" => "H7",
                    "H8" => "H8",
                    "H9" => "H9"
                  },
                "updated_at" => "2012-11-20T16:46:14+00:00",
                "uuid" => "transfer_templates_1_12"
              }
          }.to_json
        end

        post '/state_changes' do
         headers({"Content-Type" => "application/json"})
         {}.to_json 
        end

        get '/pulldown/find-assets-by-barcode' do
          headers({"Content-Type" => "application/json"})
          path = request.url
          {"search" => {"actions" => {"first" => "#{path}/first"}}}.to_json
        end

        post '/pulldown/find-assets-by-barcode/first' do
          _status, header, body= call(env.merge("PATH_INFO" => '/plates/page=1', "REQUEST_METHOD" => "GET"))
          status 301
          headers({"Content-Type" => "application/json"})
          h = JSON.parse(body.first)
          h["plates"].first.to_json
        end

        get '/pulldown/find-user' do
          path = request.url
          headers({"Content-Type" => "application/json"})
          {"user" => {
            "has_a_swipecard_code" => true,
            "actions" => {
            "update" => "#{path}",
            "read" => "#{path}",
            "first" => "#{path}/first",
            "last" => "#{path}/last"
          },
            "login" => "testuser",
            "email" => nil,
            "updated_at" => "2012-11-05T13:30:04+00:00",
            "uuid" => "e86fddea-274c-11e2-93c9-406c8ffffeb6",
            "last_name" => nil,
            "created_at" => "2012-11-05T13:30:04+00:00",
            "first_name" => nil,
            "barcode" => nil
          }}.to_json
        end

        post '/pulldown/find-user/first' do
          path = request.url	
          status 301
          headers({"Content-Type" => "application/json"})
          {"user" => {
            "has_a_swipecard_code" => true,
            "actions" => {
            "update" => "#{path}",
            "read" => "#{path}",
            "first" => "#{path}",
            "last" => "#{path}"
          },
            "login" => "testuser",
            "email" => nil,
            "updated_at" => "2012-11-05T13:30:04+00:00",
            "uuid" => "e86fddea-274c-11e2-93c9-406c8ffffeb6",
            "last_name" => nil,
            "created_at" => "2012-11-05T13:30:04+00:00",
            "first_name" => nil,
            "barcode" => nil
          }}.to_json
        end

      end
    end

    class Server
      use Pulldown::Server
      before ('/') do
        @resource.resource_map["searches"]= CoreClassResource.new(@context, "", "searches")
      end                                                          
    end
  end
end
