# Huffman Encoder takes a string and encodes it
module Encoder

  # takes a string of words, breaks it apart, encodes the words
  # returns the words
  def self.encode(message, wordList)
    
    input = message.split(" ") # split message into array of words
    encodedMessage = "" # this is what the function returns
    counter = 0 # keeps track of where we are in loop

    # BEGIN CONVERT LOOP
    while(counter < input.size) 
      huffKey = ""
      currentWord = input[counter]

      intKey = wordList[currentWord] # find index of currentWord in list
      if(intKey != nil)  

        # if intKey != nil, then we can get the huffman key!
        huffKey = intToIndexKey(intKey)
        encodedMessage += huffKey
        
      else
        # if intKey == nil, then we didn't get a huffman key...
        
        # but, it could be because punctuation was in the way!
        modifiedWord = removeNonLetters(currentWord)
        intKey = wordList[modifiedWord] # try without punctuation

        if(intKey != nil)
          # if intKey != nil this time, then it means that this was
          # an indexed word, it just has punctuation surrounding it

          huffKey = intToIndexKey(intKey)
          preChars = getPrePunctuation(currentWord)
          postChars = getPostPunctuation(currentWord)

          # add the punctuation back to the key
          # if word was "the", we'd want to add "aa"
          encodedMessage += preChars + huffKey + postChars
          
        else
          # if intKey == nil this time, then it means this is just a
          # word that isn't in the word List

          # for words like these, the decoder sees the 0 flag as start
          # and " " as end of word 
          encodedMessage += "0" + currentWord  + " "
        end
      end

      counter += 1
      # END CONVERT LOOP
    end

    return encodedMessage
  end

  #----------------------------------------------------------------------
  # FUNCTIONS
  #----------------------------------------------------------------------

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

  # returns word with only letters
  def self.removeNonLetters(word)
    first = findFirstLetter(word)
    last = findLastLetter(word)
    return word[first..last]
  end
  #----------------------------------

  # returns the index of the last letter
  def self.findLastLetter(word)
    charArray = word.split("")
    index = charArray.size - 1
    result = 0

    # starting at end, come in until you reach a letter
    while(index >= 0 && !isLetter(charArray[index]))
      index -= 1
    end

    return index
  end

  #----------------------------------

  # returns index of first letter
  def self.findFirstLetter(word)
    charArray = word.split("")
    index = 0

    if(isLetter(charArray[index]))
      return 0
    else
      # starting at 0, go until you reach a letter
      while(index < charArray.size && !isLetter(charArray[index]))
        index += 1
      end
    end

    return index
  end

  #---------------------------------

    # return substring of word from last letter on
  def self.getPostPunctuation(word)
    
    lastLetter = findLastLetter(word) + 1
    punctuation =  word[lastLetter..(word.size-1)]
    punctuation = correctForNumbers(punctuation)
    return punctuation
  end

  #---------------------------------
  
  # slap a zero in front of first number in punctuation
  # mid-2005 should result in "nP-02005 ", not "nP-2005"
  def self.correctForNumbers(punctuation)
    result = ""
  
    foundNum = false
    punctuation.split("").each do |char|
      if(isNumber(char) && !foundNum)
        foundNum = true
        result += "0"
      end
      result += char
    end
    
    if(foundNum)
      result += " "
    end
    
    return result
  end

  #---------------------------------
  
  # returns true if input is a 0-9
  def self.isNumber(char)
    return (char.ord >= 48 && char.ord <= 57)
  end
  
  #----------------------------------

  def self.getPrePunctuation(word)
    firstLetter = findFirstLetter(word) 
    if(firstLetter == 0)
      return ""
    end
    return word[0..(firstLetter-1)]
  end

  #----------------------------------
  # returns true if char is letter
  def self.isLetter(input)
    char = input.ord
    bool = ((char>=65 && char<=90) || (char>=97 && char<=122))
    return bool
  end

  #--------------------------------------


end
