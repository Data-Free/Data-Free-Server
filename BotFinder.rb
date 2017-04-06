# Takes in 2 char String -> returns name of bot file
# base 52 using alphabet
#   aa < az < aA < aZ < Aa
botKey = ARGV[0]

if botKey == "aa"
  puts("suggestions.rb")
elsif botKey == "ab"
  puts("wiki.rb")
elsif botKey == "ac"
  puts("urban_dic.rb")
else
  puts("null")
end

