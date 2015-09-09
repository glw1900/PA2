require 'set'
require_relative 'MovieTest'

##
#This is the MovieData Class, I store all the data from the test file and the base file in this class,
#and also include the predicting algorithm  
class MovieData

	attr_reader :movie_data, :user_data, :test_entry, :simi_hash

	##
	#This is the initializer, it first reads in the data, and then use two helper function to load the data.
	def initialize(filename, extension = :u)
		if extension == :u
			base_data = open(filename + "//" + extension.to_s + ".data").read
		else 
			base_data = open(filename + "//" + extension.to_s + ".base").read
			test_data = open(filename + "//" + extension.to_s + ".test").read
		end

		entry = prepare_data(base_data)
		load_data(entry)

		@test_entry = prepare_data(test_data)
		@simi_hash = {}
	end

	##
	#This method parse the big string to the an array with user, movie and rating information in a organized way. 
	def prepare_data(data)
		entry = []
		data.each_line do |line|
			u,m,r = line.split(' ')
			u = u.to_i
			m = m.to_i
			r = r.to_i
			entry.push({user:u, movie:m, rating:r})
		end
		return entry
	end

	##
	#This method store the data in a more convenient way to do the computation such as predict and get similarity list.
	def load_data(entry)
		@user_data = {}
		@movie_data = {}
		entry.each do |e|
			if @user_data.has_key?(e[:user])
				@user_data[e[:user]].add(e[:movie],e[:rating])
			else
				@user_data[e[:user]] = User.new(e[:user],e[:movie],e[:rating])
			end

			if @movie_data.has_key?(e[:movie])
				@movie_data[e[:movie]].add(e[:user],e[:rating])
			else
				@movie_data[e[:movie]] = Movie.new(e[:movie],e[:user],e[:rating])
			end
		end
	end

	##
	#This method returns the rating of the movie m of user u, which can be looked up in the user object. 
	def rating(u,m)
		user = user_data[u]
		u_hash = user.u_hash
		if u_hash.has_key?(m)
			return u_hash[m]
		else 
			return 0
		end
	end

	##
	#This method returns the arrays of all the movie user u has seen
	def movies(u)
		return user_data[u].u_hash.keys
	end

	##
	#This method predict the rating of movie m by user u from it similar_list
	def predict(u,m)
		
		#this part is the cache I have done to avoid same computation of getting the similar_list for many times
		if simi_hash.has_key?(u)
			simi_list = simi_hash[u]
		else 
			simi_hash[u] = most_similar(u)
			simi_list = simi_hash[u]
		end

		#my algorithm is pretty straightforward, I just get the top 10 user who are both seen the movie m and in the list of user u's simi_list.
		counter = 0;
		rating = 0;
		simi_list.each do |user|
			if counter > 10
				break
			elsif user_data[user].u_hash.has_key?(m) 
				rating += user_data[user].u_hash[m]
				counter += 1
			end
		end
		return rating.to_f/counter
	end

	##
	#This method just return all the viewers of the movie m.
	def viewers(m)
		return movie_data[m].m_hash.keys
	end

	##
	#This method return a MovieTest object which contents the result of the test.
	def run_test(k = test_entry.length)
		counter = 0;
		result = []
		@test_entry.each do |entry|
			if counter >= k
				break
			else
				predict_rating = predict(entry[:user],entry[:movie])
				result.push({user:entry[:user],movie:entry[:movie],rating:entry[:rating],pred_rating:predict_rating})
				counter += 1
			end	
		end
		return MovieTest.new(result)
	end

	##
	#This method return the array of most similar users to user u.
	def most_similar(u)
		u_list = movies(u)
		simi_hash = {}
		@user_data.each do |k,v|
			if k != u
				simi_hash[k] = (movies(k) & u_list).length
			end
		end
		return Hash[simi_hash.sort_by{|k,v| v}.reverse].keys
	end
end 

##
#This Movie class contents the number of the movie, and a hash that store the users who have seen this movie and the rating of the movie given
#by the user.
class Movie

	attr_reader :m_number, :m_hash

	def initialize(number,person,rating)
		@m_number = number
		@m_hash = {person => rating}
	end

	#This method just add a new pair of viewer and rating to the hash.
	def add(person,rating)
		@m_hash[person] = rating
	end

end

##
#This User class contents the number of the user, and a hash that store the movie the user seen and its rating in a hash.
class User 
	attr_reader :u_number, :u_hash

	def initialize(number,movie,rating)
		@u_number = number
		@u_hash = {movie => rating}
	end

	#This method just add a new pair of movie and rating to the hash.
	def add(movie,rating)
		@u_hash[movie] = rating
	end
end

## This is the test section 

p = MovieData.new("ml-100k",:ua)
# puts p.rating(1,3)
# puts p.movies(1)
# puts p.viewers(1)
# puts p.predict(1,33)
t = p.run_test()
# puts t.mean
# puts t.stddev
# puts t.rms
puts t.to_a


