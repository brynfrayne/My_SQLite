class SQLiteParser
  attr_accessor :valid_query_methods

  def initialize
    require 'Readline'
    require 'CSV'
    require './my_sqlite_request'
    @valid_query_methods = ["SELECT", "FROM", "INSERT", "UPDATE", "VALUES", "SET", "JOIN", "WHERE", "ORDER", "DELETE", "ASC", "DESC", "AND"]
  end

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
    delimiters = ['"', "'"]
    split_str = string.split(Regexp.union(delimiters))
    strings_outside_quotes_array = []

    split_str.each_with_index do |element, i|
      if i % 2 == 0
        split_str_outside_quotes = element.split(' ')
        strings_outside_quotes_array.push(split_str_outside_quotes)
      end
    end

    strings_outside_quotes_array.each do |array|
      array.each_with_index do |element, i|
        if element == ','
          split_str.slice!(i)
        end

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

        if element.match? /\A\d+\z/
          array[i] = element.to_i
        end
      end
    end

    j = 0
    i = 0
    while i < split_str.length
      if i % 2 == 0
        split_str[i] = strings_outside_quotes_array[j]
        j += 1
      end
      i += 1
    end

    split_str = split_str
