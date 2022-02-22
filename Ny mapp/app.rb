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
    slim(:index)
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
    redirect("/show")
  else
    "fel LÖSEN!"
  end

end

get("/show") do
  db = db_called("db/data.db")
  result = db.execute("SELECT * FROM servers")
  p "RRRR #{result}"
  slim(:"server/index", locals:{servers:result})
end
