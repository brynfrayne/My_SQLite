require 'Readline'
require 'CSV'
require './my_sqlite_request.rb'

@valid_query_methods = ["SELECT", "FROM", "INSERT", "UPDATE", "VALUES", "SET", "JOIN", "WHERE", "ORDER", "DELETE", "ASC", "DESC", "AND"]

def parse_args_from_input(query)
  arg_values = []
  @user_input.each_index do |i|
    if (@user_input[i] == query)
      i += 1
      while !@valid_query_methods.include?(@user_input[i]) && @user_input[i]

        if @user_input[i] == 'INTO' || @user_input[i] == 'into'
          i += 1;
        elsif @user_input[i] == 'ON'
          i += 1
        elsif query == 'JOIN' && @user_input[i] == '='
          i += 1
        end

        puts "17 - user_input[i]:#{@user_input[i]}"
        args = @user_input[i]
        arg_values.push(args)
        i += 1

      end
    end
  end
  return arg_values
end

def split_args(string)



  # split all values by quotes, seperating values inside and outside quotes
  delimiters = ['"', "'"]
  split_str = string.split(Regexp.union(delimiters))
  strings_outside_quotes_array = []

  # go through the split string and split and elements at index value outside of quotations and push to new array
  split_str.each_with_index do |element, i|

    # split all values outside of quotes
    if i % 2 == 0
      # push all split values outside of quotes into a new array
      split_str_outside_quotes = element.split(' ')
      strings_outside_quotes_array.push(split_str_outside_quotes)

    end

  end

  # go through the array of subarrays containing the split strings
  strings_outside_quotes_array.each do |array|
    # go through the subarray of the split strings
    array.each_with_index do |element, i|

      # remove any elements == ','
      if element == ','
        split_str.slice!(i)
      end

      # remove any occcurences of ',' in an element
      if element.include?(',')
        element.slice!(element.index(','))
      end

      if element.include?('(')
        element.slice!(element.index('('))
      end

      if element.include?(')')
        element.slice!(element.index(')'))
      end

      if element.include?(';')
        element.slice!(element.index(';'))
      end

      if element == ';'
        array.slice!(i)
      end

      # check for any numeric values and convert to integers
      if element.match? /\A\d+\z/
        array[i] = element.to_i
      end

    end
  end

  j = 0
  i = 0
  # go through the string split on quotations, and replace the strings outside quotes with their corresponding filtered array
  while i < split_str.length
    if i % 2 == 0
      split_str[i] = strings_outside_quotes_array[j]
      j += 1
    end
    i += 1
  end

  split_str = split_str.flatten
  return split_str

end

def create_hash_from_insert_args(string)
  columns = []
  result_hash = {}

  if string.count('(') > 1
    insert_column_values = string[string.index('(')+1..string.index(')')-1];
    string.slice!(string.index('(')..string.index(')'))
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

  insert_values.each_with_index do |value, i|
    insert_values[i] = value.delete_prefix("'").delete_suffix("'")
  end

  columns.each_with_index do |value, i|
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

  return result_hash
end

def parse_input(args)

  if args.split(' ').include?('INSERT')
    @values_hash = create_hash_from_insert_args(args)
    @request = @request.values(@values_hash)
  end

  if args.split(' ').include?('UPDATE')
    @values_hash = create_hash_from_set_args(args)
    @request = @request.set(@values_hash)
  end

  @user_input = split_args(args)
  i = 0

  @user_input.each do |query|
    case query
    when 'SELECT'
      select_request = parse_args_from_input('SELECT')
      @request = @request.select(select_request)
    when 'INSERT'
      insert_request = parse_args_from_input('INSERT')
      @request = @request.insert(insert_request[0])
    when 'UPDATE'
      update_request = parse_args_from_input('UPDATE')
      @request = @request.update(update_request[0])
    when 'DELETE'
      delete_request = parse_args_from_input('DELETE')
      @request = @request.delete
    when 'FROM'
      from_request = parse_args_from_input('FROM')
      @request = @request.from(from_request[0])
    when 'WHERE'
      where_request = parse_args_from_input('WHERE')
      @request = @request.where(where_request[0], where_request[2])
      @request = @request.where_comparison_operator(where_request[1], 0)
    when 'JOIN'
      join_request = parse_args_from_input('JOIN')
      @request = @request.join(join_request[1], join_request[0], join_request[2])
    when 'ORDER'
      order_request = parse_args_from_input('ORDER')
      @request = @request.order(order_request[1])
    when 'DESC'
      @request = @request.desc_order()
    when 'AND'
      i += 1;
      second_where_request = parse_args_from_input('AND')
      @request = @request.where(second_where_request[0], second_where_request[2])
      @request = @request.where_comparison_operator(second_where_request[1], i)
    end
  end
  return @request.run
end

def run
  puts "MySQLite version 0.1 2022-11-21"
  loop do
    user_args = Readline.readline("my_sqlite_cli> ", true)
    if user_args == 'quit'
      break
    end
    @request = MySqliteRequest.new
    @request = @request.args_from_cli
    parse_input(user_args)
  end
end

run()

#  i want to rewrite the above code to be object oriented
#  i want to create a class for each of the following
#  SELECT, INSERT, UPDATE, DELETE, FROM, WHERE, JOIN, ORDER, DESC, AND
#  i want to create a class for each of the following



# when 'VALUES'
    #   values_request = parse_args_from_input('VALUES')
    #   @request = @request.values(@values_hash)
# when 'SET'
    #   set_request = parse_args_from_input('SET')
    #   @request = @request.set(@values_hash)
# when 'ON' # need to add these iunput values to the join request
    #   on_request = parse_args_from_input('ON')
    #   @request = @request.on(on_request)

