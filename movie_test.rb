require_relative 'movie_helper.rb'

class MovieTest
  include Helper

  def initialize results
    #2D array of tuples in form [usr, mv, rating, predicted_rating]
    @results = results
    @err = results.map { |usr, mv, r, pr| diff(r, pr) }
  end

  #average prediction error
  def mean
    @err.mean.round(2)
  end

  #standard deviation of the error from the mean
  def stddev
    m = mean
    #variance = avg squared deviation from mean
    variance = @err.map { |e| diff(e, m) * 2 }.mean
    #stddev = square_root(variance)
    return Math.sqrt(variance).round(2)
  end

  #root mean square = square root of mean of squares
  def rms
    squares = @err.map { |e| e*2 }
    return Math.sqrt(squares.mean)
  end

  def to_a
    @results
  end
end
