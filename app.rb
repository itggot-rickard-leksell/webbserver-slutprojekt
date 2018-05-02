require_relative 'auth.rb'

include Auth

class App < Sinatra::Base

	enable :sessions

	get '/' do
		erb(:index)
	end

	get '/shop' do
		db = SQLite3::Database::new("./database/webbshop.db")
		products = db.execute("SELECT * FROM items")
		if session[:user_id]
			current_id = session[:user_id]
			result = Auth::user(current_id)
			erb(:shop, locals:{name: result, products: products})
		else
			erb(:shop, locals:{products: products})
		end
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
				db = SQLite3::Database::new("./database/webbshop.db")
				session[:user_id] = db.execute("SELECT id FROM users WHERE name=?", [new_name])[0][0]
				redirect('/shop')
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
				redirect('/shop')
			elsif result == 1
				erb(:login, locals:{failure2: "Wrong password. Please try again."})
			end
		end
	end

	get '/purchase/:product' do
		product_name = params[:product]
		db = SQLite3::Database::new("./database/webbshop.db")
		product = db.execute("SELECT * FROM items where name IS ?", [product_name])
		if session[:user_id]
			current_id = session[:user_id]
			result = Auth::user(current_id)
			erb(:purchase, locals:{name: result, product: product})
		else
		erb(:purchase, locals:{product: product})
		end
	end
	
	post '/purchase/:product' do
		db = SQLite3::Database::new("./database/webbshop.db")
		product_name = params[:product]
		quantity = params[:quantity]
		price = db.execute("SELECT price FROM items where name IS ?", [product_name])[0][0]
		total = quantity.to_f * price.to_f
		user_id = session[:user_id]
		db.execute("insert into orderlist (user_id, item_name, item_quantity, total_price, status) VALUES (?,?,?,?,?)", [user_id, product_name, quantity, total, "pending"])
		redirect('/shop')
	end

	get '/profile' do

		if session[:user_id]
			current_id = session[:user_id]
			result = Auth::user(current_id)
			result2 = Auth::cartcount(current_id)
			db = SQLite3::Database::new("./database/webbshop.db")
			cart = db.execute("SELECT * FROM orderlist WHERE user_id IS ? AND status IS ?", [current_id, "pending"])
			history = db.execute("SELECT * FROM orderlist WHERE user_id IS ? AND status IS ?", [current_id, "finished"])
			erb(:profile, locals: {db: db, name: result, cartcount: result2, cart: cart, history: history})
		else
			redirect("/login")
		end
	end

	post '/profile' do
		order_id = params[:id]
		p order_id
		db = SQLite3::Database::new("./database/webbshop.db")
		db.execute("DELETE FROM orderlist WHERE order_id IS ?", [order_id])
		redirect("/profile")
	end

	get('/checkout') do
		erb(:checkout)
	end

	post '/checkout' do
		current_id = session[:user_id]
		db = SQLite3::Database::new("./database/webbshop.db")
		db.execute("UPDATE orderlist SET status = ? WHERE user_id = ?", ["finished", current_id])
		redirect ("/checkout")
	end
end           
