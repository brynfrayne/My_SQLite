val1 = @where_query.each_index do |i|
        next if i % 3 != 0
        @where_query_not_match = false
        where_column_value = row["#{@where_query[i]}"]
        where_comparison_operator = @where_query[i+1]
        where_criteria_value = @where_query[i+2]

        if !compare(where_comparison_operator, where_column_value, where_criteria_value)
          @where_query_not_match = true
          break
        end
      end

val2 = @where_query.each_index do |i|
  next if i % 3 != 0
  @where_query_not_match = false
  where_column_value = row["#{@where_query[i]}"]
  where_comparison_operator = @where_query[i+1]
  where_criteria_value = @where_query[i+2]
  if !compare(where_comparison_operator, where_column_value, where_criteria_value)
    @where_query_not_match = true
    break
  end
end

puts val1 == val2



# require 'csv'
# # def parse_args_from_input(query)
# #   arg_values = []
# #   @user_input.each_index do |i|
# #     if @user_input[i] == query
# #       i += 1
# #       @user_input[i..-1].each do |input|
# #         break if @valid_query_methods.include?(input) || !input
# #         if input == 'INTO' || input == 'into'
# #           i += 1;
# #         elsif input == 'ON'
# #           i += 1
# #         elsif query == 'JOIN' && input == '='
# #           i += 1
# #         end

# #         args = input
# #         arg_values.push(args)
# #         i += 1
# #       end

# #   end
# #   return arg_values
# # end


# # # while !@valid_query_methods.include?(@user_input[i]) && @user_input[i]
# # #   # rewrite the above into .each do |element| and .include? element



# # #     if @user_input[i] == 'INTO' || @user_input[i] == 'into'
# # #       i += 1;
# # #     elsif @user_input[i] == 'ON'
# # #       i += 1
# # #     elsif query == 'JOIN' && @user_input[i] == '='
# # #       i += 1
# # #     end

# # #     args = @user_input[i]
# # #     arg_values.push(args)
# # #     i += 1

# # #   end
# # # end
# @hash_table = []
# @array_table = []
# @column_titles = []

# def table_data_array_to_hash(column_titles, table)
#   table_data_hash_array = []
#   id = 0

#   table.each do |row|

#     hash = {}
#     id += 1
#     hash["id"] = id
#     row.each_index do |i|
#       if row[i] && row[i].match?(/\A\d+\z/)
#         row[i] = row[i].to_i
#       end
#       hash["#{column_titles[i]}"] = row[i]
#     end
#     table_data_hash_array.push(hash)
#   end

#   if !column_titles.include?("id")
#     column_titles.unshift("id")
#   end

#   return table_data_hash_array
# end

# def read_table_data(file_name, array_table, column_titles, hash_table)
#   array_table = CSV.parse(File.read(file_name))
#   puts "#{array_table}"
#   column_titles = array_table.shift
#   hash_table = table_data_array_to_hash(column_titles, array_table)
#   puts "#{hash_table}"
#   return array_table, column_titles, hash_table
# end

# @, @column_titles = read_table_data('students.csv', @array_table, @column_titles, @hash_table)
# puts "hash_table: #{@hash_table}" #why is this nil? but the puts in the method works?

# puts @column_titles
