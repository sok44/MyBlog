require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def check_parameters_empty hh
  return hh.select {|key,_| params[key]  == ""}.values.join(", ")
end

def init_db
  @db = SQLite3::Database.new 'MyBlog.db'
  @db.results_as_hash = true
end

before do
  init_db
end

configure do
  init_db
  @db.execute 'CREATE TABLE IF NOT EXISTS Posts 
  (
    id INTEGER PRIMARY KEY AUTOINCREMENT, 
    created_date DATE, 
    content TEXT,
    author TEXT
  )'

   @db.execute 'CREATE TABLE IF NOT EXISTS Comments 
  (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    post_id INTEGER, 
    created_date DATE, 
    content TEXT
  )'
end

get '/' do

  @results = @db.execute 'SELECT * FROM Posts ORDER BY id DESC'
  erb :index
end 

get '/new' do
  erb :new
end

post '/new' do
  @content = params[:content]
  @author = params[:author]

  hh = {content: 'Введите текст поста',
        author: 'Введите ваше имя (автора)'}
  
  my_error = check_parameters_empty hh

  if my_error != ''
    @error = my_error
    return erb :new
  end

  @db.execute 'INSERT INTO Posts (created_date, content, author) VALUES (datetime(), ?, ?)', [@content, @author]
 
  redirect to '/'
end

get '/details/:post_id' do
  post_id = params[:post_id]

  results = @db.execute 'SELECT * FROM Posts WHERE id = ?', [post_id]
  @row = results[0]

  @comments =  @db.execute 'SELECT * FROM Comments WHERE post_id = ? ORDER BY id', [post_id]

  erb :details
end

post '/details/:post_id' do
  post_id = params[:post_id]

  @content = params[:content] 

  hh = {content: 'Введите текст поста',
        author: 'Введите ваше имя (автора)'}

  my_error = check_parameters_empty hh

  if my_error != ''
    @error = my_error

    results = @db.execute 'SELECT * FROM Posts WHERE id = ?', [post_id]
    @row = results[0]
    @comments =  @db.execute 'SELECT * FROM Comments WHERE post_id = ? ORDER BY id', [post_id]

    return erb :details
  end

  
  @db.execute 'INSERT INTO Comments
    (
      post_id,
      created_date,
      content
    )
      VALUES
    (
      ?,
      datetime(),
      ?
    )', [post_id, @content]

    redirect to '/details/' + post_id
end