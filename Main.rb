require 'rubygems'
require 'sinatra'
require 'twilio-ruby'

require_relative 'HuffmanEncoder.rb' # encodes a word
require_relative 'Encoder.rb' # uses Huffman Encoder to encode a string
require_relative 'SeparateIntoTexts.rb' # prepares huffman to send

#------main--------------------------------------------------------------

def main()
  puts("\n\nStarting up...")

  #-------------------------
  # SET UP INFO
  #-------------------------
  account_sid = ""
  auth_token = ""
  twilio_number = ""
  account_sid, auth_token, twilio_number = get_info()
  
  wordHash = HuffmanEncoder.getHash() # create list of words


  get '/message' do

    #----------------------------
    # PREPARE TEXT RESPONSE
    #----------------------------
    puts("\n\n\n\nrecieved\n")
    
    # 1) Collect information from user text
    user_number = params['From']
    sms = params['Body'] # store incoming sms text
    body = sms[2..-1] # get content of request (minus botkey)
    bot_key = sms[0,2] # get botkey
    
    # 2) Run Bot
    # Gets bot name, and then runs bot from command line
    bot = %x{ruby BotFinder.rb #{bot_key}}.chomp
    result = %x{ruby bots/#{bot} #{body}}.downcase 
    
    # 3) prepare result for sms
    encoded = Encoder.encode(result, wordHash) # encode it
    output = SeparateIntoTexts.separate(encoded, 150)
  
    # print to terminal
    print_string(result)
    print_string(output)
       
    #----------------------------
    # SEND TEXT TO USER
    #----------------------------
    
    # 1) Send Header Texts
    size = output.length;
    sms_message = "{" + int_to_key(size) + " HEADER TEXT"
    
    send_text(account_sid, auth_token, sms_message,
              user_number, twilio_number)
    
    # 2) Send Content Texts
    index = 0
    while(index<size)
      sms_message = int_to_key(index) + output[index] 
            
      send_text(account_sid, auth_token, sms_message,
              user_number, twilio_number)
      index+=1
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

#---get_info-------------------------------------------------------------

# Sets up account information from a text file
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

