# safely separates encoded message into texts of designated size
module SeparateIntoTexts
  
  # returns encoded message as array of texts of proper char sizes
  # do this because we don't want to split keys in wrong place
  def self.separate(encodedMessage, textSize)
    encodedChars = encodedMessage.split("")
    separatedTexts = Array.new # returns this
    currentText = "" # String gets added to separatedTexts
    cIndex = 0  # keeps track of index in encoded message
    textIndex = 0 # keeps track of which number
    
    stillGoing = true # loop limiter
    # LOOP
    while(stillGoing)

      # check to see if still going
      if(encodedChars[cIndex] == nil)
        #(cIndex >= encodedChars.length-1) || 
        stillGoing = false
        separatedTexts[textIndex] = currentText
      else
        
        # get keysize and key
        keySize = getNextKeySize(encodedChars, cIndex)
        nextKey = getNextKey(encodedChars, cIndex, keySize)
        
        # check if adding current key to text would make it too large
        if((currentText.length + keySize) > textSize)
          
          # add currentText to separatedTexts
          separatedTexts[textIndex] = currentText
          textIndex += 1 # move on to next text
          currentText = nextKey # reset currentText with nextKey
          
        else
          # if it doesn't make text too large, add it on
          currentText += nextKey
        end

        
        cIndex += keySize # move to start of next Key
      end
    end # END LOOP
    
    return separatedTexts
  end

  #---getNextKey-----------------------------------------------------------

  # returns the next key
  def self.getNextKey(keys, cIndex, keySize)
    count = 0
    nextKey = ""

    # get key
    while(count<keySize)
      nextKey += keys[cIndex]
      count += 1
      cIndex += 1
    end

    #puts("NK: " + nextKey)
    return nextKey
  end
  #---getNextKeySize-------------------------------------------------------

  # returns size of next key
  def self.getNextKeySize(keys, cIndex)
    firstChar = keys[cIndex]
    keySize = 1
    
    if(isLetter(firstChar))
      keySize = 2
    elsif(is2through9(firstChar))
      keySize = 3
    elsif(isZero(firstChar))
      nextSpace = getNextSpace(keys, cIndex)
      keySize = nextSpace - cIndex
      #printf("SIZE: %d\n", keySize)
    end

    return keySize
  end

  #---getNextSpace---------------------------------------------------------

  # returns index of next space
  def self.getNextSpace(keys, cIndex)
    found = false
    cIndex -= 1
    
    while(cIndex<keys.size && found == false)
      cIndex += 1
      if(keys[cIndex] == ' ')
        found = true
      end
    end

    return cIndex
  end

  #---isLetter-------------------------------------------------------------

  # returns true if char is letter
  def self.isLetter(input)
    char = input.ord
    bool = ((char>=65 && char<=90) || (char>=97 && char<=122))
    return bool
  end

  #---is2through9----------------------------------------------------------

  # returns true if char is 2-9
  def self.is2through9(input)
    char = input.ord
    bool = (char>=50 && char<=57)
    return bool
  end

  #---isZero---------------------------------------------------------------

  # returns true if char is zero
  def self.isZero(input)
    char = input.ord
    bool = (char == 48)
    return bool
  end

  #------------------------------------------------------------------------
end
