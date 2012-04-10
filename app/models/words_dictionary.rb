require 'pg'  

class WordsDictionary

	# Builds the word search query based of the letters and options hash passed in
	def self.build_sql_query(letters, options)
		
		select = "select * from dictionary_test where"

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
						sql = select + " POSITION(UPPER('#{letter}') in UPPER(word)) >0" # Ignore position
					else
						sql = select + " POSITION(UPPER('#{letter}') in UPPER(word))=#{index+1}" # Return only results w letter at index
					end
				else # continue sql statment w AND
					if noPosition then
						sql = sql + " AND " + "POSITION(UPPER('#{letter}') in UPPER(word)) >0"
					else
						sql = sql + " AND " + "POSITION(UPPER('#{letter}') in UPPER(word))=#{index+1}"
					end
				end
			end
		end

		if not noLength then # Length Specified by passed in option! Only return results == letter array(params)
			sql = sql +" AND "+"CHAR_LENGTH(word) = #{letters.size}"	
		end
		sql = sql +" AND POSITION(' ' in word)= 0" # Narrow results to words with no spaces like 'a priori'
		sql = sql + " LIMIT 100" 
		return sql
	end

	# Connects to pg DB and runs a word search query against it. Returns HMTL string of query results
	def self.find_words(letters, options)
		#con = PGconn.new('ec2-23-21-140-215.compute-1.amazonaws.com', '', '', '', 'hrwupgvufs', 'hrwupgvufs', 'bYnTGuMWqubAuJiUqNo9') 
		con = PGconn.new('localhost', 5432, '', '', 'words', 'postgres', 'root')
		rs = con.exec(self.build_sql_query(letters, options)) 
		puts 'rows: '+ rs.ntuples().to_s
		result =""
		# Run query against dictionary with word length and first letter as filters 
		i = rs.fnumber('word')
		#rs.each { |h| result = result + h[0].to_s + '<br>'} # result : concatentated query results as HTML w <br>
		rs.each_with_index { |h, index| result = result + rs.getvalue(index, i)+ '<br>'} 
		con.close
		return result
	end

end
