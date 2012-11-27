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
