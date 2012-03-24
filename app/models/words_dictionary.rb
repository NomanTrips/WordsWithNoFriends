require 'mysql'  

class WordsDictionary

	# Builds the word search query based of the letters and options hash passed in
	def self.build_sql_query(letters, options)
		
		select = "select * from dictionary where"

		if (not options.nil?) and ( options.include?('noPosition')) then # Set position boolean to given HTML parameter
			noPosition = true
		else
			noPosition = false
		end

		if (not options.nil?) and ( options.include?('noLength')) then # No required length 
			noLength = true
		else
			noLength = false
		end

		# Begin sql generation based off passed off above parameters
		sql =''
		letters.each_with_index do
			|letter, index| 
			if letter != '' then 
				if sql.empty? then # Start the sql string
					if noPosition then 
						sql = select + " INSTR(word, '#{letter}')" # Ignore position
					else
						sql = select + " INSTR(word, '#{letter}')=#{index+1}" # Return only results w letter at index
					end
				else # continue sql statment w AND
					if noPosition then
						sql = sql + " AND " + "INSTR(word, '#{letter}')"
					else
						sql = sql + " AND " + "INSTR(word, '#{letter}')=#{index+1}"
					end
				end
			end
		end

		if not noLength then # Length Specified by passed in option! Only return results == letter array(params)
			sql = sql +" AND "+"CHAR_LENGTH(word) = #{letters.size}"	
		end
		
		return sql
	end

	# Connects to mysql DB and runs a word search query against it. Returns HMTL string of query results
	def self.find_words(letters, options)
		con = Mysql.new('localhost', 'root', 'root', 'test') # connect to mysql db
		rs = con.query(self.build_sql_query(letters, options)) 
		result =""
		# Run query against dictionary with word length and first letter as filters 
		rs.each { |h| result = result + h[0] + '<br>'} # result : concatentated query results as HTML w <br>
		con.close
		return result
	end

end
