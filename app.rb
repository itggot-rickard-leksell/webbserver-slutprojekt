class App < Sinatra::Base

	get '/' do
	 erb(:index)
	end

	get '/login' do
	erb(:login)
	end
end           
