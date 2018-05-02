module Auth

    def user(current_id)
        db = SQLite3::Database::new("./database/webbshop.db")
        name = db.execute("SELECT name FROM users WHERE id IS ?", [current_id])
        return name
    end

    def create(new_name, new_password, confirmed_password)
        if new_password == confirmed_password
            db = SQLite3::Database::new("./database/webbshop.db")
            taken_name = db.execute("SELECT * FROM users WHERE name IS ?", [new_name])
            if taken_name == []
                hashed_password = BCrypt::Password.create(new_password)
                db.execute("INSERT INTO users (name, password) VALUES (?,?)", [new_name, hashed_password])
                return 0    
            else
                return 1
            end
        else
            return 2
        end
    end

    def login(name, password)
        db = SQLite3::Database::new("./database/webbshop.db")
		real_password = db.execute("SELECT password FROM users WHERE name=?", [name])
		if real_password != [] && BCrypt::Password.new(real_password[0][0]) == password
			return 0
		else
            return 1
        end
    end

    def cartcount(user)
        db = SQLite3::Database::new("./database/webbshop.db")
        count = db.execute(" SELECT COUNT(*) FROM orderlist where user_id IS ? AND status IS ?", [user, "pending"])
        p Integer(count[0][0])
        if Integer(count[0][0]) > 0
            return 0
        else
            return 1
        end
    end
end