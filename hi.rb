require 'sinatra'
require 'sequel'
require 'aescrypt'
require 'base64'

# prod DB = Sequel.connect(ENV['DATABASE_URL'])
DB = Sequel.sqlite # dev

DB.create_table :items do
	primary_key :id
	String :text
	Integer :count
	Integer :timecreated
	Integer :timetodelete
	Integer :countlimit
    String :fancyid
end

items = DB[:items]

items.insert(:text => 'Hello world', :count => 0, :timecreated => 0, :fancyid => SecureRandom.urlsafe_base64)
items.insert(:text => 'Top kek', :count => 0, :timecreated => 0, :fancyid => "rhewkdfh")


get '/' do
	erb :input_form	
end

post '/' do
	fancyid = SecureRandom.urlsafe_base64
	encoded = AESCrypt.encrypt(params[:secret_message],params[:encode_key])
	items.insert(:text => encoded, :count =>0, :timecreated => 0, :countlimit => params[:count_limit], :timetodelete => params[:timetodelete], :fancyid => fancyid)
	idlink = request.host_with_port+"/messagelink/"+fancyid
	erb :message_link, :locals => {'message_link' => idlink}
end

get '/message/:id' do
	message = items.select(:text)[:id => params[:id]][:text]
	erb :message, :locals => {'message' => message}
end

post '/message/' do
	decoded = AESCrypt.decrypt(params[:message], params[:encode_key])
	linktonewmessage = request.host_with_port
	erb :message_decrypted, :locals => {'message' => decoded, 'url' => linktonewmessage }
end

get '/messagelink/:fancyid' do
	@message = items.select(:text)[:fancyid => params[:fancyid]][:text]
	erb :message, :locals => {'message' => @message}
end