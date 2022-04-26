require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

def db_called(path)
  db = SQLite3::Database.new(path)
  db.results_as_hash = true
  return db
end

get("/") do
  db = db_called("db/data.db")
  result = db.execute("SELECT * FROM servers")
  slim(:"server/index", locals:{servers:result})
end

post("/servers/:id/update") do
  servername = params[:servername]
  ip = params[:ip]
  id = params[:id]
  db = db_called("db/data.db")
  db.execute("UPDATE servers SET servername=?,ip=? WHERE id=?", params[:servername],params[:ip],params[:id])
  redirect("/")
end

get("/servers/:id/update") do
  id = params[:id].to_i
  db = db_called("db/data.db")
  result = db.execute("SELECT * FROM servers WHERE id=?", id).first
  slim(:"/server/edit", locals:{result:result})
end

post('/delete/:id') do
  db = db_called("db/data.db")
  id = params[:id]
  db.execute("DELETE FROM servers WHERE id = ?", id)
  redirect("/")
end

get('/register') do
  slim(:register)
end

get("/loggin") do
    slim(:loggin)
end

get("/loggout") do
    session[:auth] = false
  slim(:index)
end

get("/dumskalle") do
    slim(:dumskalle)
end

get("/servers/new")do
    slim(:"/server/new")
end

post("/servers") do
  if session[:auth] 
      servername = params[:servername]
      ip = params[:ip]
      db=SQLite3::Database.new('db/data.db')
      db.execute("INSERT INTO servers (servername,ip) VALUES (?,?)",servername,ip)
      #hämta det nyaste id för server
      last_id = db.last_insert_row_id

      #Hämta användarid för den som äger servern
     # session[:id] = id
      #lägg in båda i relationsdatabas
     # db.execute("INSERT INTO userserver (userid,serverid) VALUES (?,?)",id,last_id)
      redirect("/")
    else
        "401"
    end
end

#här är register sidan.
post("/register") do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
    mcname = params[:mcname]
    discordname = params[:discordname]
    age = params[:age]
    if (password == password_confirm)
      #lägg till användare
      password_digest = BCrypt::Password.create(password)
      db = SQLite3::Database.new("db/data.db")
      db.execute("INSERT INTO users (username,pwdigest,mcname,discordname,age) VALUES (?,?,?,?,?)",username,password_digest,mcname,discordname,age)
      session[:auth]=true
      redirect("/")
    else
      redirect("/dumskalle")
    end
    

end
#loggin
post("/loggin") do
  username = params[:username]
  password = params[:password]
  db = SQLite3::Database.new("db/data.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM users WHERE username = ?",username).first
  pwdigest = result["pwdigest"]
  id = result["id"]
  
  if BCrypt::Password.new(pwdigest) == password
    session[:id] = id
    session[:username] = username
    session[:auth] = true
    redirect("/")
  else
    "fel LÖSEN!"
  end

end
