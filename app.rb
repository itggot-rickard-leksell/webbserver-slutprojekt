require_relative 'auth.rb'

include Auth
enable:sessions

class App < Sinatra::Base

	get '/' do
	 erb(:index)
	 
	end

	get '/login' do
	erb(:login)
	end

	post '/login' do
		result = 0
		new_name = params[:name]
		new_password = params[:password]
		if params[:confirmed_password] != nil
			confirmed_password = params[:confirmed_password]
			result = Auth::create(new_name, new_password, confirmed_password)
			if result == 0
				redirect('/')
			elsif result == 1
				erb(:login, locals:{failure: "Username is already taken."})
			elsif result == 2
				erb(:login, locals:{failure: "Passwords didn't match. Please try again."})
			end
		else
			result = Auth::login(new_name, new_password)
			if result == 0
				db = SQLite3::Database::new("./database/webbshop.db")
				session[:user_id] = db.execute("SELECT id FROM users WHERE name=?", [new_name])[0][0]
				redirect('/')
			elsif result == 1
				erb(:login, locals:{failure2: "Wrong password. Please try again."})
			end
		end
	end
end           
