# HuffmanEncoder takes a word and encodes it
module HuffmanEncoder
  def self.encode(message, words)
    words = getHash() # create words hash
    
    input = message.split(" ");
    size = input.size
    loopIndex = 0
    encoded = ""

    # Loop converts words in input to key and adds to result
    while(loopIndex<size)

      currentWord = input[loopIndex]
      pPunctuation = "" # put before word 
      punctuation = "" # put after word
      
      intKey = words[currentWord] # turn word into int index from list

      #---
      # check for punctuation as cause of nil
      if(intKey == nil)

        # check word again without any punctuation attached
        pCheck = removePunctuation(currentWord)
        if(pCheck != currentWord)

          if(!isLetter(currentWord[0]))
            # if first char isn't a letter, save it
            pPunctuation = currentWord[0]
          end
          punctuation = getPunctuation(currentWord)
        end
        
        intKey = words[pCheck]

        # check to see if word still not in list 
        if(intKey == nil)
          intKey = -1  # if word still isn't in word list, flag it
        end
      end # end check for punctuation
      #---
      
      result = intToIndexKey(intKey) # convert to String key

      # if not indexable, return word with 0 flag
      if(result == "0")     
        result = result + currentWord + " "
      end

      encoded += pPunctuation + result + punctuation
      
      loopIndex += 1 #  increment loop
    end # end convert loop

    #puts(encoded)
    return encoded
  end # end main

  #------------------------------------------------
  # FUNCTIONS
  #------------------------------------------------

  # creates hash containing words and corresponding indexes
  # ["String"] = int
  def self.getHash()
    hash = {}
    index = 0
    
    #read through lines and add to hash
    wordList = File.readlines('google-10000-english-usa.txt').each do |line|
      hash[line.chomp] = index
      index += 1
    end  # end read through word doc

    return hash
  end

  #------------------------------------------------------------

  # takes in an int and outputs a 2-3 digit String key
  def self.intToIndexKey(num)

    #check to see if it is indexable
    if(num<0)
      return "0"  # if not, return flag 0
    end

    #scale = decimal multiplier put in front of key
    scale = 0 
    if(num>2703 and num<24328)
      scale = (num/2703)%10 + 49
      num = (num%2703)
    end

    c1 = get10sDigit(num).chr
    c2 = get1sDigit(num).chr
    

    result = scale.chr + c1 + c2
    return result
  end

  #----------------------------------------------------------

  #return 10s digit char as an int value
  def self.get10sDigit(num)
    #10s digit = num/52
    d1 = num/52
    if(d1>25)
      d1 += 39
    else
      d1+=97
    end
    return d1
  end

  #----------------------------------------------------------

  #return 1s digit char as an int value
  def self.get1sDigit(num)
    #1s digit = num%52
    d2 = num%52
    if(d2>25)
      d2 += 39
    else
      d2 += 97
    end
    return d2
  end

  #---------------------------------------------------------

  def self.isLetter(char)
    num = char.to_i
    bool = ((num>=65 && num<=90) || (num>=97 && num<=122))
    return bool
  end

  #----------------------------------------------------------

  # returns word with only letter (a-Z)
  def self.removePunctuation(word)
    charArray = word.chars
    index = 0
    result = ""

    while(index<charArray.size)
      cNum = charArray[index].ord

      # if current char is a letter
      if((cNum>=65 && cNum<=90) || (cNum>=97 && cNum<=122))
        result += charArray[index]
      end
      index += 1
    end
    return result
  end

  #-----------------------------------------------------------

  # returns the non letter (a-Z) characters in word
  def self.getPunctuation(word)
    charArray = word.chars
    index = 1 # ignore the first one since it gets checked already
    result = ""

    while(index<charArray.size)
      cNum = charArray[index].ord

      # if not a letter
      if(!((cNum>=65 && cNum<=90) || (cNum>=97 && cNum<=122)))
        result += charArray[index]
      end

      index += 1
    end
    return result
  end

  #------------------------------------------------
  # RUN
  #------------------------------------------------
end
#encode()
