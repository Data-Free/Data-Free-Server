# Takes in 2 char String -> returns name of bot file
# base 52 using alphabet
#   aa < az < aA < aZ < Aa
botKey = ARGV[0]

#suggestions, updates
if botKey == "aa"
  puts("tutorial.rb")
elsif botKey == "ab"
  puts("updates.rb")
elsif botKey == "ac"
  puts("suggestions.rb")
elsif botKey == "ad"
  puts("wiki.rb")
elsif botKey == "ae"
  puts("urban_dic.rb")
else
  puts("null")
end

