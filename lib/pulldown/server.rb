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
          #h["revision"] = 2
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

        get '/pulldown/find-assets-by-barcode' do
          headers({"Content-Type" => "application/json"})
          path = request.url
          {"search" => {
            "actions" => {
            "all" => "#{path}/all",
            "first" => "#{path}/first",
            "read" => "#{path}",
            "last" => "#{path}/last"},
            "name" => "Find assets by barcode",
            "uuid" => "e2501a1a-274c-11e2-93c9-406c8ffffeb6",
            "updated_at" => "2012-11-05T13:29:54+00:00",
            "created_at" => "2012-11-05T13:29:54+00:00"}}.to_json 	  	
        end

        post '/pulldown/find-assets-by-barcode/first' do
          path = request.url
          status 301
          headers({"Content-Type" => "application/json"})
          {"plate" =>
            {"actions"=>{"read"=> path,
              "update"=> path,
              "delete"=> path,
              "create"=> path,
            },
            "uuid" => "ab4810c0-096c-0130-7898-282066132de2",
            "wells"=>{
              "A1"=>[],"A2"=>[],"A3"=>[],"A4"=>[],"A5"=>[],"A6"=>[],"A7"=>[],"A8"=>[],"A9"=>[],"A10"=>[],"A11"=>[],"A12"=>[],
              "B1"=>[],"B2"=>[],"B3"=>[],"B4"=>[],"B5"=>[],"B6"=>[],"B7"=>[],"B8"=>[],"B9"=>[],"B10"=>[],"B11"=>[],"B12"=>[],
              "C1"=>[],"C2"=>[],"C3"=>[],"C4"=>[],"C5"=>[],"C6"=>[],"C7"=>[],"C8"=>[],"C9"=>[],"C10"=>[],"C11"=>[],"C12"=>[],
              "D1"=>[],"D2"=>[],"D3"=>[],"D4"=>[],"D5"=>[],"D6"=>[],"D7"=>[],"D8"=>[],"D9"=>[],"D10"=>[],"D11"=>[],"D12"=>[],
              "E1"=>[],"E2"=>[],"E3"=>[],"E4"=>[],"E5"=>[],"E6"=>[],"E7"=>[],"E8"=>[],"E9"=>[],"E10"=>[],"E11"=>[],"E12"=>[],
              "F1"=>[],"F2"=>[],"F3"=>[],"F4"=>[],"F5"=>[],"F6"=>[],"F7"=>[],"F8"=>[],"F9"=>[],"F10"=>[],"F11"=>[],"F12"=>[],
              "G1"=>[],"G2"=>[],"G3"=>[],"G4"=>[],"G5"=>[],"G6"=>[],"G7"=>[],"G8"=>[],"G9"=>[],"G10"=>[],"G11"=>[],"G12"=>[],
              "H1"=>[],"H2"=>[],"H3"=>[],"H4"=>[],"H5"=>[],"H6"=>[],"H7"=>[],"H8"=>[],"H9"=>[],"H10"=>[],"H11"=>[],"H12"=>[]}}}.to_json
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
