module Auth

    def escape(input)
        return input.gsub("<", "&lt;").gsub(">", "&gt;")
    end

    def checkchar(input)
      if (input.gsub(/[a-zA-Z0-9]/, "")).empty?
        return input
      else
        return false
      end
    end

    def checkInt(string)
       if string.scan(/\D/).empty?
        return string
    else
        return false
      end
    end

    def getDb()
        db = SQLite3::Database::new("./database/webbshop.db")
        return db
    end

    def getUser(name)
        db = getDb()
        return db.execute("SELECT id FROM users WHERE name=?", [name])[0][0]
    end
    def user(current_id)
        db = getDb()
        name = db.execute("SELECT name FROM users WHERE id IS ?", [current_id])
        return name
    end

    def create(new_name, new_password, confirmed_password)
        if new_password == confirmed_password
            db = getDb()
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
        db = getDb()
		real_password = db.execute("SELECT password FROM users WHERE name=?", [name])
		if real_password != [] && BCrypt::Password.new(real_password[0][0]) == password
			return 0
		else
            return 1
        end
    end

    def cartcount(user)
        db = getDb()
        count = db.execute(" SELECT COUNT(*) FROM orderlist where user_id IS ? AND status IS ?", [user, "pending"])
        p Integer(count[0][0])
        if Integer(count[0][0]) > 0
            return 0
        else
            return 1
        end
    end
end