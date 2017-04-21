require 'rubygems'
require 'sinatra'
require 'twilio-ruby'

require_relative 'HuffmanEncoder.rb' # encodes a word
require_relative 'Encoder.rb' # uses Huffman Encoder to encode a string
require_relative 'SeparateIntoTexts.rb' # use to separate encoded messages
                                        # into properly sized texts

# ------------------------------------------------------------
puts("\n\nStarting up...")
 # Your Account SID from www.twilio.com/console
account_sid = ""
 # Your Auth Token from www.twilio.com/console
auth_token = ""

wordHash = HuffmanEncoder.getHash()
# ------------------------------------------------------------

get '/message' do

  puts("\n\n\n\nrecieved\n")

  # Collect information from user text
  userNumber = params['From']
  sms = params['Body'] # store incoming sms text
  body = sms[2..-1] # get content of request (minus botkey)
  bot_key = sms[0,2] # get botkey

  # Run Bot
  bot = %x{ruby BotFinder.rb #{bot_key}} # returns name of program to run
  bot = bot.chomp
  result = %x{ruby bots/#{bot} #{body}} # run bot
  result = result.downcase

  # prepare result for sms
  encoded = Encoder.encode(result, wordHash) # encode it
  #output = encoded.scan(/.{1,#{150}}/) # break it into proper size for sms
  output = SeparateIntoTexts.separate(encoded, 150)
  # replace ^ with Separator

  # print to terminal
  print_string(result)
  print_string(output)
 
  
  #-----------------------------------------------------
  #  <Sends sms response to user>
  #-----

  #send Header text, notifying expected package size
  size = output.length;
  sms_message = "{" + int_to_key(size) + " HEADER TEXT"
  #send text
    @client = Twilio::REST::Client.new account_sid, auth_token
    message = @client.account.messages.create(:body => sms_message,
       :to => userNumber,
       :from => "")  # Replace with your Twilio number "+15555555555"
  
  #--------
  #  loops through and prints response
  index = 0
  while(index<size)
    # smsMessage = getKey(index)
    sms_message = int_to_key(index) + output[index] 

    #send text
    @client = Twilio::REST::Client.new account_sid, auth_token
    message = @client.account.messages.create(:body => sms_message,
       :to => userNumber,
       :from => "")  # Replace with your Twilio number "+15555555555"

    index+=1
  end
  #--------

  #send final message so app knows sending should be finished
  #sleep(size+3)
  #sms_message = ""
  #send text
  #  @client = Twilio::REST::Client.new account_sid, auth_token
  #  message = @client.account.messages.create(:body => sms_message,
  #     :to => "",    # Replace with your phone number "+15555555555"
  #     :from => "")  # Replace with your Twilio number "+15555555555"
  #-----------------------------------------------------
 
end

#---int_to_key------------------------------------------------------------

#converts an int into base 26(a-z)
def int_to_key(num)
  #10s digit = num/26
  d1 = num/26 + 97

  #1s digit = num%26
  d2 = num%26 + 97
  result = d1.chr + d2.chr

  return result
end

#---print-----------------------------------------------------------------

def print_string(input)
  puts("-------------------------------------------------------")
  puts(input)
  puts("-------------------------------------------------------")
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
 - bot_key: 2 char String with key identifying which bot user wants
           The DataFree app automatically adds this key to beginning of sms

Retreiving the Answer
 - result: String that bot outputs
 - output: Array - result, broken into chunks that can be sent in one text

Sending the Answer
 - index: int, increments through all Strings in output
 - max: int, size limit of output
 - sms_message: String, stores the String at output[index] to send to user
=end
