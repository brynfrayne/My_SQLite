require 'CSV'
def split_args(string)
  delimiters = ['"', "'"]
  split_str = string.split(Regexp.union(delimiters))
  split_outside_quotes = split_str.each_with_index.map do |element, i|
    if i.even?
      element.split(' ')
    end
  end.compact

  split_outside_quotes.each do |array|
    array.each do |element|
      element.delete!(',', '(', ')', ';')
      element.to_i if element.match?(/\A\d+\z/)
    end
  end

  split_str.each_with_index do |element, i|
    split_str[i] = split_outside_quotes[i / 2] if i.even?
  end

  split_str.flatten
end

=begin
This refactored version simplifies the code by:

Removing unnecessary comments
Combining multiple if statements that perform the same action (removing characters and converting to integer)
Using the each_with_index.map method to split the elements outside of quotes and store them in a new array
Using the compact method to remove nil values from the new array
Using the delete! method to remove multiple characters in one call
Using the each_with_index method to iterate through split_str and replace the elements with the corresponding filtered element in split_outside_quotes


=end
# def split_args(string)



#   # split all values by quotes, seperating values inside and outside quotes
#   delimiters = ['"', "'"]
#   split_str = string.split(Regexp.union(delimiters))
#   strings_outside_quotes_array = []

#   # go through the split string and split and elements at index value outside of quotations and push to new array
#   split_str.each_with_index do |element, i|

#     # split all values outside of quotes
#     if i % 2 == 0
#       # push all split values outside of quotes into a new array
#       split_str_outside_quotes = element.split(' ')
#       strings_outside_quotes_array.push(split_str_outside_quotes)

#     end

#   end

#   # go through the array of subarrays containing the split strings
#   strings_outside_quotes_array.each do |array|
#     # go through the subarray of the split strings
#     array.each_with_index do |element, i|

#       # remove any elements == ','
#       if element == ','
#         split_str.slice!(i)
#       end

#       # remove any occcurences of ',' in an element
#       if element.include?(',')
#         element.slice!(element.index(','))
#       end

#       if element.include?('(')
#         element.slice!(element.index('('))
#       end

#       if element.include?(')')
#         element.slice!(element.index(')'))
#       end

#       if element.include?(';')
#         element.slice!(element.index(';'))
#       end

#       if element == ';'
#         array.slice!(i)
#       end

#       # check for any numeric values and convert to integers
#       if element.match? /\A\d+\z/
#         array[i] = element.to_i
#       end

#     end
#   end

#   j = 0
#   i = 0
#   # go through the string split on quotations, and replace the strings outside quotes with their corresponding filtered array
#   while i < split_str.length
#     if i % 2 == 0
#       split_str[i] = strings_outside_quotes_array[j]
#       j += 1
#     end
#     i += 1
#   end

#   split_str = split_str.flatten
#   return split_str

# end


def create_hash_from_insert_args(string)
  columns = []
  result_hash = {}

  if string.count('(') > 1
    # slice of the colum values provided in the first brackets
    insert_column_values = string[string.index('(')+1..string.index(')')-1];
    # slice off all the values in the first brackets(including the brackets)
    string.slice!(string.index('(')..string.index(')'))
    # split the sliced off column value string and set the column array to that
    columns = insert_column_values.split(',').map(&:strip)
  else
    file_name = ''
    split_str = string.split(' ')
    split_str.each do |element|
      if element.include?('.csv')
        file_name = element
      end
    end
    columns = CSV.open(file_name, 'r') { |csv| csv.first }
    columns.each do |column|
      if column == 'id'
        columns.delete(column)
      end
    end
  end

  insert_values = string[string.index('(')+1..string.index(')')-1].split(',').map(&:strip)
  string.slice!(string.index('(')..-1)
  puts "string: #{string}"
  insert_values.each_with_index do |value, i|
    insert_values[i] = value.delete_prefix("'").delete_suffix("'")
  end
  puts "isnert values: #{insert_values}"

  # if columns.length < insert_values.length
  # end

  columns.each_with_index do |value, i|
    # puts insert_values[i]
    result_hash["#{value}"] = insert_values[i]

  end
  return result_hash

end

def create_hash_from_set_args(string)
  result_hash = {}
  set_index = string.index('SET')
  set_values = ''

  if string.split(' ').include?('WHERE')
    where_index = string.index('WHERE')
    set_values = string[set_index+4..where_index-1].split(',').map(&:strip)
    string.slice!(set_index..where_index-1)
  else
    set_values = string[set_index+4..-1].split(',').map(&:strip)
    string.slice!(set_index..-1)
  end

  set_values.each_index do |i|
    delimiters = ['"', "'"]
    set_values[i]  = set_values[i].split(Regexp.union(delimiters))
    split_set_values = set_values[i][0].split(' ')
    result_hash["#{split_set_values[0]}"] = set_values[i][1]
  end

puts "#{result_hash}"
end

# string = 'SELECT email, id FROM students.csv WHERE name = "Alex Rose"'
# string = 'INSERT INTO students.csv VALUES (John, john@johndoe.com, A, https://blog.johndoe.com);'
# string = 'INSERT INTO students.csv VALUES (John, john@johndoe.com, A, https://blog.johndoe.com);'

# string = "UPDATE students.csv SET email = 'jane@janedoe.com', blog = 'https://blog.janedoe.com' WHERE name = 'Names';"
# string = "INSERT INTO table_name.csv (column1, column2, column3,etc) VALUES (value1, value2, value3, etc);"
# string = "UPDATE students SET email = 'jane@janedoe.com', blog = 'https://blog.janedoe.com' WHERE name = 'Jane';"

# split_args(string)
# create_hash_from_args(string)
# create_hash_from_set_args(string)
# split_args(string)


#  BELOW ALL WORK!!!!

# $ SELECT * FROM students.csv
# $ SELECT * FROM students.csv ORDER BY email
# $ SELECT email, id FROM students.csv WHERE name = 'John'
# $ SELECT * FROM nba_players_test.csv JOIN nba_player_data.csv ON nba_players_test.csv.Player = nba_player_data.csv.name WHERE nba_players_test.csv.height = 180;
# $ SELECT * FROM nba_players_test.csv JOIN nba_player_data.csv ON nba_players_test.csv.Player = nba_player_data.csv.name WHERE nba_players_test.csv.height = 180 AND nba_players_test.csv.weight = 77;
# $ INSERT INTO students.csv VALUES (John, john@johndoe.com, A, https://blog.johndoe.com);
# $ INSERT INTO students.csv (name, email, grade, blog) VALUES (John, john@johndoe.com, A, https://blog.johndoe.com);
# $ INSERT INTO students.csv VALUES ('John', 'john@johndoe.com', 'A', 'https://blog.johndoe.com');
# $ UPDATE students.csv SET email = 'jane@janedoe.com', blog = 'https://blog.jimmy-jo.com' WHERE name = 'Jimmy Jo';
# $ DELETE FROM students.csv WHERE name = 'John';
# $ DELETE FROM students.csv WHERE name = 'John' AND email = 'jane@johndoe.com';
# $ DELETE FROM nba_test_2_copy_2.csv;










# string = "UPDATE students.csv SET email = 'jane@janedoe.com', blog = 'https://blog.janedoe.com' WHERE name = 'Jimmy Jo';"
# puts "#{create_hash_from_set_args(string)}"
string = "INSERT INTO students.csv VALUES ('John', 'john@johndoe.com', 'A', 'https://blog.johndoe.com');"
puts create_hash_from_insert_args(string)
puts "#{split_args(string)}"


