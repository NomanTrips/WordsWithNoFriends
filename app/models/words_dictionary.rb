require 'pg'  

		TIMEOUT = 5.0 # seconds to wait for an async operation to complete
		CONN_OPTS = {
		    :dbname => 'words',
		    :user => 'postgres',
		}

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
						sql = select + " POSITION('#{letter}' in word)" # Ignore position
					else
						sql = select + " POSITION('#{letter}' in word)=#{index+1}" # Return only results w letter at index
					end
				else # continue sql statment w AND
					if noPosition then
						sql = sql + " AND " + "POSITION('#{letter}' in word)"
					else
						sql = sql + " AND " + "POSITION('#{letter}' in word)=#{index+1}"
					end
				end
			end
		end

		if not noLength then # Length Specified by passed in option! Only return results == letter array(params)
			sql = sql +" AND "+"CHAR_LENGTH(word) = #{letters.size}"	
		end
		puts sql
		return sql
	end

	# Connects to mysql DB and runs a word search query against it. Returns HMTL string of query results
	def self.find_words(letters, options)
		#con = pg.new('localhost', 'postgres', 'root', 'words') # connect to mysql db



		#con = PGconn.new('localhost', '5432', 'postgres', 'root', 'words')
		con = PGconn.new('ec2-23-21-140-215.compute-1.amazonaws.com', '', '', '', 'hrwupgvufs', 'hrwupgvufs', 'bYnTGuMWqubAuJiUqNo9') 
		#con = PGconn.connect_start( CONN_OPTS )
		rs = con.query(self.build_sql_query(letters, options)) 
		result =""
		# Run query against dictionary with word length and first letter as filters 
		rs.each { |h| result = result + h[0].to_s + '<br>'} # result : concatentated query results as HTML w <br>
		con.close
		return result
	end

end
