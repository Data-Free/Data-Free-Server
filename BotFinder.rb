# Takes in 2 char String -> returns name of bot file
# base 52 using alphabet
#   aa < az < aA < aZ < Aa
botKey = ARGV[0]

if botKey == "aa"
  puts("wiki.rb")
elsif botKey == "ab"
  puts("urban_dic.rb")
else
  puts("null")
end

