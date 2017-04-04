require 'rubygems'
require 'sinatra'
require 'twilio-ruby'

puts("\n\n\n\nStarting up...")
 # Your Account SID from www.twilio.com/console
account_sid = "AC3ef5925b6a0dc9c604471a3e5ac521a5"
 # Your Auth Token from www.twilio.com/console
auth_token = "86574bf2193ad221bee0ca1d593a40b3"  

get '/message' do

  puts("\n\n\n\nrecieved\n")
  
  # store incoming sms text 
  sms = params['Body']

  #body = content of sms minus the botkey
  body = sms[2..-1]

  # botkey = first two chars of sms
  botKey = sms[0,2]

  # BotFinder uses botkey to return name of program to run
  bot = %x{ruby BotFinder.rb #{botKey}}
  bot = bot.chomp

  # Runs bot, result contains the bot's output
  result = %x{ruby bots/#{bot} #{body}}

  #-----------------------------------------------------
  #break answer into chunks for sms
  output = result.scan(/.{1,#{100}}/)
  puts output
  
  #-----------------------------------------------------
  #  <Sends sms response to user>
  #  loops through 
  index = 0
  max = output.length + 1
  while(index<max)
    smsMessage = output[index]
    @client = Twilio::REST::Client.new account_sid, auth_token
    message = @client.account.messages.create(:body => smsMessage,
       :to => "+",    # Replace with your phone number "+15555555555"
       :from => "")  # Replace with your Twilio number "+15555555555"
    index+=1
  end
  #-----------------------------------------------------
 
end

#-------------------------------------------------------------------------
=begin

---------------
Variables
---------------
Receiving User Request
 - sms: String containing message from the user
        formatted as botKey + body
 - body: String with user's request
 - botKey: 2 char String with key identifying which bot user wants
           The DataFree app automatically adds this key to beginning of sms

Retreiving the Answer
 - result: String that bot outputs
 - output: Array - result, broken into chunks that can be sent in one text

Sending the Answer
 - index: int, increments through all Strings in output
 - max: int, size limit of output
 - smsMessage: String, stores the String at output[index] to send to user
=end
