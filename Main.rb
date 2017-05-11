# Data Free Server

require 'rubygems'
require 'sinatra'
require 'twilio-ruby'

require_relative 'HuffmanEncoder.rb' # encodes a word
require_relative 'Encoder.rb' # uses Huffman Encoder to encode a string
require_relative 'SeparateIntoTexts.rb' # prepares huffman to send

#---main-----------------------------------------------------------------

def main()
  puts("\n\nStarting up...")

  #-------------------------
  # SET UP INFO
  #-------------------------
  # set up twilio info
  account_sid, auth_token, twilio_number = get_account_info()
  wordHash = HuffmanEncoder.getHash() # list of words to encode with

  
  get '/message' do

    #----------------------------
    # PREPARE TEXT RESPONSE
    #----------------------------
    puts("\n\n\n\nrecieved\n")
    
    # 1) Collect information from user text
    user_number = params['From']
    sms = params['Body'] # store incoming sms text
    declaration, bot_key, bot_case, instance, content_request =
                                             get_request_info(sms)
  
    # 2) Run Bot
    # Gets bot name, and then runs bot from command line
    bot = %x{ruby BotFinder.rb #{bot_key}}.chomp
    result = %x{ruby bots/#{bot} #{content_request}}.downcase 
    
    # 3) prepare result for sms
    encoded = Encoder.encode(result, wordHash) # encode it
    output = SeparateIntoTexts.separate(encoded, 150) # split it
  
    # print to terminal
    print_string(result)
    printf("packages expected: %d\n", output.length)
    print_string(output)
    # print packages expected: 
       
    #----------------------------
    # SEND TEXT TO USER
    #----------------------------
    size = output.length
    
    if(declaration)
      # Send Declaration Text
      # { + bot_key + request + instance + size 
      size = output.length
      sms_message = "{" + bot_key + bot_case +
                    instance + int_to_key(size) + content_request
      
      send_text(account_sid, auth_token, sms_message,
                user_number, twilio_number)
    else
      # Send Content Texts
      # instance + index + content
      index = 0
      while(index<size)
        sms_message = instance + int_to_key(index) + output[index] 
        
        send_text(account_sid, auth_token, sms_message,
                  user_number, twilio_number)
        index+=1
      end
    end
    
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

#---get_account_info-----------------------------------------------------

# Sets up account information from a text file
def get_account_info()
  info = Array.new
  
  File.readlines('TwilioAccountInfo').each do |line|
    info.push(line.chomp())
  end

  account_sid = info[0] 
  auth_token = info[1]
  twilio_number = info[2]

  return account_sid, auth_token, twilio_number
end

#---get_request_info-----------------------------------------------------------

# parses incoming text and extracts relevant info
def get_request_info(message)

  # check if a declaration
  if(message[0] == '{')
    # { BK R I ...
    declaration = true
    bot_key = message[1..2]
    request = message[3]
    instance = message[4]
    content_request = message[5..-1]
  else
    # else: BK R I ...
    declaration = false
    bot_key = message[0..1]
    request = message[2]
    instance = message[3]
    content_request = message[4..-1]
  end

  return declaration, bot_key, request, instance, content_request
end

#---send_text------------------------------------------------------------

# sends text
def send_text(account_sid, auth_token, sms_message,
              user_number, twilio_number)
  
  @client = Twilio::REST::Client.new account_sid, auth_token
  message = @client.account.messages.create(:body => sms_message,
                                            :to => user_number,
                                            :from => twilio_number)
end

#---RUN------------------------------------------------------------------

main()

