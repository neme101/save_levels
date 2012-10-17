require 'sinatra'
require 'sinatra/contrib'
require 'data_mapper'
require 'haml'
require 'json'

# Datamapper
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

# Models
class Level
  include DataMapper::Resource

  property :id,         Serial
  property :city,       String
  property :data,       Text, :required => true
  property :created_at, DateTime
end

DataMapper.finalize
DataMapper.auto_upgrade!

# Controller
class Levels < Sinatra::Base

  helpers do
    def proper_response(haml_view,json_data,redirect=false)
      request.accept.each do |type|
        case type
        when 'text/html'
          if(redirect)
            redirect(redirect)
          else
            halt haml haml_view
          end
        when 'text/json','application/json'
          content_type :json
          halt json_data
        end
      end
      error 406
    end
  end

  get '/' do
    @levels = Level.all
    haml :index
  end

  get '/levels/last', :provides => [:html,:json] do
    if !@level = Level.last()
      error 404
    end

    # Can't actually do a "to_json" because the data stored is already a json string :(
    proper_response(:level_details,@level.data)
  end

  post '/levels' do
    level = Level.create params[:level]
    json = JSON.parse(level.data)
    level.city = json['name']
    level.save!
    proper_response(false,level.data,"/level/#{level.id}")
  end

  get '/level/:id' do
    if !@level = Level.get(params[:id])
      error 404
    end

    proper_response(:level_details,@level.data)
  end

  delete '/level/:id' do
    if !level = Level.get(params[:id])
      error 404
    end

    level.destroy
    proper_response(false,{:status => 1}.to_json,'/')
  end
end