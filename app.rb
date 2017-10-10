require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

get '/' do
  erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"
end

get '/about' do
  @error = 'Внимание ошибка!'
  erb :about
end

get '/visit' do
  erb :visit
end

post '/visit' do
  
  @username = params[:username] 
  @phone = params[:phone]
  @datetime = params[:datetime]
  @barber = params[:barber]
  @color = params[:color]
  
  hh = {:username => 'Введите имя',
        phone: 'Введите телефон',
        datetime: 'Введите дату и время'}
  
  #@error = ''
  #hh.each do |key, value|
  #  #Если параметр пуст
   # if params[key] == ''
   #   @error = @error + hh[key] + ' '
  #  end
 # end
  
  @my_error = check_parameters_empty hh

  if @my_error != ''
    @error = @my_error
    return erb :visit
  end

  running_dir = File.dirname(__FILE__)
  running_dir = Dir.pwd if (running_dir == '.')
  f = File.open running_dir + '/public/users.txt', 'a:windows-1251'
  f.write "User: #{@username}, phone: #{@phone}, datetime: #{@datetime}, employee: #{@barber},
    color: #{@color}. \n"
  f.close

  erb "Вы записались! #{@username} спасибо что выбрали нас! 
    Ждем вас #{@datetime}. Ваш телефон #{@phone}. Ваш мастер #{@barber}. 
    Выбранный цвет покраски #{@color}."
end

def check_parameters_empty hh
  return hh.select {|key,_| params[key]  == ""}.values.join(", ")
end