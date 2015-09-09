##
#This MovieTest class content the predicting result and some information about the accuracy of the result. 
class MovieTest
	
	attr_reader :data

	def initialize(data)
		@data = data
	end

	##
	#This method return the mean error of the predict.
	def mean
		error = 0
		data.each do |entry|
			error += (entry[:rating] - entry[:pred_rating]).abs
		end
		return error.to_f/data.length
	end

	##
	#This method return the standard deviation error of the predict.
	def stddev
		sum = 0
		data.each do |entry|
			sum += ((entry[:rating] - entry[:pred_rating]).abs - self.mean)**2
		end
		return Math.sqrt(sum.to_f/(data.length))
	end

	##
	#This method return the root mean square error of the predict.
	def rms
		sum = 0
		data.each do |entry|
			sum += (entry[:rating] - entry[:pred_rating])**2
		end
		return Math.sqrt(sum.to_f/data.length)
	end

	##
	#This method return an array of the result.
	def to_a
		return data.map { |e| e.values }
	end
end

