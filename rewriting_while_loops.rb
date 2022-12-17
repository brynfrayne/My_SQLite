def parse_args_from_input(query)
  arg_values = []
  @user_input.each_index do |i|
    if @user_input[i] == query
      i += 1
      @user_input[i..-1].each do |input|
        break if @valid_query_methods.include?(input) || !input
        if input == 'INTO' || input == 'into'
          i += 1;
        elsif input == 'ON'
          i += 1
        elsif query == 'JOIN' && input == '='
          i += 1
        end

        args = input
        arg_values.push(args)
        i += 1
      end

  end
  return arg_values
end


# while !@valid_query_methods.include?(@user_input[i]) && @user_input[i]
#   # rewrite the above into .each do |element| and .include? element



#     if @user_input[i] == 'INTO' || @user_input[i] == 'into'
#       i += 1;
#     elsif @user_input[i] == 'ON'
#       i += 1
#     elsif query == 'JOIN' && @user_input[i] == '='
#       i += 1
#     end

#     args = @user_input[i]
#     arg_values.push(args)
#     i += 1

#   end
# end
