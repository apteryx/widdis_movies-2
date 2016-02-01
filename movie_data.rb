require_relative 'movie_helper.rb'
require_relative 'movie_test.rb'

class MovieData
  include Helper

  @@train_options = [:u1, :u2, :u3, :u4, :u5]

  def initialize root, option=nil
    base_file = find_base option
    test_file = find_test option
    @base = read (root + "/" + base_file)
    @test = read (root + "/" + test_file) if test_file
    draw_maps
  end

  #if option valid, return option.base; else u.data
  def find_base option
    (@@train_options.include? option) ? (option.to_s + ".base") : "u.data"
  end

  #if option valid, return option.test; else nil
  def find_test option
    option.to_s + ".test" if @@train_options.include? option
  end

  #create maps from base data
  def draw_maps
    #{user => {movie => rating}}
    @usr_rating = Hash.new(Hash.new())
    #{movie => avg_rating}
    @avg_rating = Hash.new()
    #{movie => {usr => rating}}
    @mv_rating = Hash.new(Hash.new())

    @base.each do |usr, mv, r|
      @usr_rating.nest_store usr, {mv => r}
      @mv_rating.nest_store mv, {usr => r}
    end

    #calculate averages
    @mv_rating.each do |mv, usr_hash|
      @avg_rating.store(mv, usr_hash.val_avg)
    end
  end

  #return user u's rating of movie m
  def rating u, m
    @usr_rating[u][m]
  end

  #predict rating u would give m
  def predict u, m
    #for each movie mw watched my u, determine mw's prediction for r
    predictions = movies(u).map do |mw|
      #rw = u's rating of movie mw
      rw = rating(u, mw)
      #for all users ux that have given mw the same rating as u, record ux's  rating for m
      r_given_rw = Array.new(0)
      @mv_rating[mw].each do |ux, rwx|
        rx = rating ux, m
        #record ux's rating for m if agree with u on rating for mw
        r_given_rw.push(rx) if rx && rwx == rw
      end

      #mw's prediction for r(m) is average of all user's rating of m that have agreed with u on mw
      return r_given_rw.mean.round unless r_given_rw.empty?
    end

    #default to 3 because neutral rating
    return predictions.median_ish || 3
  end

  #movies viewed by u
  def movies u
    @usr_rating[u].keys
  end

  #users who have viewed m
  def viewers m
    @mv_rating[m].keys
  end

  #average similarity in ratings between u1 and u2
  def similarity u1, u2
    u1_r = @usr_rating[u1]
    u2_r = @usr_rating[u2]
    common = u1_r.keys & u2_r.keys

    mean_diff = 0
    common.each do |mv|
      mean_diff += diff(u1_r[mv], u2_r[mv]).to_f / common.length
    end
    return ((5 - mean_diff)/5).round(2)
  end

  #map from other users to similarity to u1
  def similarities u1
    sims = Hash.new()
    (@usr_rating.keys - [u1]).each do |u2|
      sims.store(u2, similarity(u1, u2))
    end
    return sims
  end

  #return test object with first k rows in test data
  def run_test k=@test.size
    puts "No test data specified!" unless @test

    results = Array.new(Array.new)
    @test.first(k).each do |usr, mv, r|
      results.push([usr, mv, r, predict(usr, mv)])
    end

    MovieTest.new results
  end
end

m = MovieData.new 'ml-100k', :u1
t = m.run_test
puts "mean: #{t.mean}"
puts "stddev: #{t.stddev}"
puts "rms: #{t.rms}"
