require 'lims-api/server'
require 'pulldown/resources/receptacle'
require 'pulldown/resources/plate_resource'
require 'pulldown/resources/tube_resource'

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
        def initialize(*args)
          super(*args)
          config = YAML.load_file(File.join('config', 'database.yml'))
          db = ::Sequel.connect(config['development'])
          @store = Lims::Core::Persistence::Sequel::Store.new(db)
        end

        def options
          {:store => @store, :user => Lims::Core::Organization::User.new, :application => 'mock server'}
        end	

        def call(env)
          status, body, header = response = super(env)
          if status == 404
            @app.call(env)
          else
            response
          end
        end

        # Create a search object
        def search_action(attributes)
          Lims::Core::Actions::CreateSearch.new(options) do |a,s|
            a.description = attributes[:description] 
            a.model = attributes[:model]
            a.criteria = attributes[:criteria]
          end
        end

        # Display the item if it has a pending/done/in_progress status
        # and if it is a plate object
        def display_item?(item, uuid_resource)
          %w{pending done in_progress}.include?(item.status) && 
            uuid_resource.model_class == Lims::Core::Laboratory::Plate
        end

        # Return the item ids which need to be displayed in the inbox
        def item_ids
          search = search_action(
            :description => 'order lookup', 
            :model => 'order', 
            :criteria => {:status => 'in_progress'}
          ).call[:search] 

          ids = @store.with_session do |session| 
            search.call(session).slice(0,9).inject([]) do |m,o| 
              item_ids = []
              o.values.each do |item|
                uuid_resource = session.uuid_resource[:uuid => item.uuid]
                if display_item?(item, uuid_resource)
                  item_ids << session.uuid_resource[:uuid => item.uuid].key
                end
              end
              m.merge(item_ids)
            end
          end
        end

        # Search the plates selected in item_ids
        def ongoing_plates_search_uuid
          search_action(
            :description => 'plates search',
            :model => 'plate',
            :criteria => {:id => item_ids}
          ).call[:uuid]        
        end

        post '/pulldown/search-:extra/all' do
          status, header, body = call(env.merge("PATH_INFO" => "/#{ongoing_plates_search_uuid}", "REQUEST_METHOD" => "GET"))
          search_body = JSON.parse(body.first)
          first_page = search_body["search"]["actions"]["first"]
          relative_first_page = /^http:\/\/[^:]*:[0-9]*(?<relative_url>.*)/.match(first_page)[:relative_url]

          status, header, body = call(env.merge("PATH_INFO" => relative_first_page, "REQUEST_METHOD" => "GET"))
          status 300
          headers({"Content-Type" => header["Content-Type"]})

          h = JSON.parse(body.first)
          h["actions"]["all"] = h["plates"]
          [{"searches" => h["plates"].map { |p| p["plate"]},
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
          h["tag_layout_templates"] = {"actions" => {"first" => "#{path}tag_layout_templates"}}
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

        get '/tag_layout_templates' do
          path = request.url
          headers({"Content-Type" => "application/json"})
          tags = Hash[(1..96).to_a.map {|n| [n.to_s, "ACGT#{n}"]}]
          {"tag_layout_templates" => [
            {
              "tag_group" => {
                "tags" => tags, 
                "name"=>"Tagging",
                "updated_at"=>"2012-11-20T16:46:07+00:00",
                "created_at"=>"2012-11-20T16:46:07+00:00",
                "uuid"=>"pulldown_tagging_template",
                "direction"=>"column",
                "walking_by"=>"wells in pools"
              },
              "direction"=>"column",
              "name"=>"Old 12 TagTubes - do not use in column major order",
              "updated_at"=>"2012-11-20T16:46:14+00:00",
              "created_at"=>"2012-11-20T16:46:14+00:00",
              "actions"=>{
                "create"=>"#{path}",
                "read"=>"#{path}"
              },
              "walking_by"=>"wells in pools",
              "uuid"=>"cbe6b900-3331-11e2-9adf-406c8ffffeb6"
            }],
          "actions" => {
                  "first" => "#{path}",
                  "read" => "#{path}",
                  "last" => "#{path}"
               },
             "size" => 1}.to_json
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
