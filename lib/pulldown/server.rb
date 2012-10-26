require 'lims-api/server'

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
              "size" => h["size"], "success" => 1
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
            "first" =>  "#{path}/last",
            "all" =>  "#{path}/all"}
          }
          }.to_json
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
