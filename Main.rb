require 'rubygems'
require 'sinatra'
require 'twilio-ruby'

require_relative 'HuffmanEncoder.rb' # encodes a word
require_relative 'Encoder.rb' # uses Huffman Encoder to encode a string
require_relative 'SeparateIntoTexts.rb' # prepares huffman to send

# ------------------------------------------------------------
def main()
  puts("\n\nStarting up...")

  # set up account info
  account_sid = ""
  auth_token = ""
  twilio_number = ""
  account_sid, auth_token, twilio_number = get_info()
  
  wordHash = HuffmanEncoder.getHash()
  # ------------------------------------------------------------
  
  get '/message' do
    
    puts("\n\n\n\nrecieved\n")
    
    # Collect information from user text
    user_number = params['From']
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
    output = SeparateIntoTexts.separate(encoded, 150)
  
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
                                              :to => user_number,
                                              :from => twilio_number) # Replace with your Twilio number "+15555555555"
    
    #--------
    #  loops through and prints response
    index = 0
    while(index<size)
      # smsMessage = getKey(index)
      sms_message = int_to_key(index) + output[index] 
      
      #send text
      @client = Twilio::REST::Client.new account_sid, auth_token
      message = @client.account.messages.create(:body => sms_message,
                                                :to => user_number,
                                                :from => twilio_number)  # Replace with your Twilio number "+15555555555"
      
      index+=1
    end
    #-----------------------------------------------------
    
  end
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

#---print----------------------------------------------------------------

def print_string(input)
  puts("-------------------------------------------------------")
  puts(input)
  puts("-------------------------------------------------------")
end

#---get_info-------------------------------------------------------------

# Sets up account information from a text file
# line 1 of text file will have account_sid from twilio
# line 2 of text file will have authentication token from twilio
# line 3 of text file will have twilio phone number
def get_info()
  info = Array.new
  
  File.readlines('TwilioAccountInfo').each do |line|
    info.push(line.chomp())
  end

  account_sid = info[0]
  auth_token = info[1]
  twilio_number = info[2]

  return account_sid, auth_token, twilio_number
end

#------------------------------------------------------------------------
main()

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
