require 'xxhash'
require 'matrix'
require 'benchmark'

class Time
  def to_ms
    (self.to_f * 1000.0).to_i
  end
end

class String
  def ascii_to_dec
    self.ord
  end
end

class Array
  # nb. this function DO NOT convert ints from 0 to 9!
  def dec_to_ascii
    self.map!{ |el| el.class == Fixnum ? el.dec_to_ascii_safe : el }
  end
  def clusterize(group_size)
    self.each_slice(group_size).to_a
  end
end

class Integer
  # nb. this function DO NOT convert ints from 0 to 9!
  def dec_to_ascii_safe
    self.between?(0,9) ? self : self.chr 
  end
  def dec_to_ascii
    self.chr
  end
  def even?
    self % 2 == 0 ? true : false
  end
end

class Foken
  def initialize
    @mults = []
    @app_key = "sonofiga"
    @window = (60 * 10 + 1).to_i #5 min window
  end
  
  def xxhash(from, seed)
    hash = XXhash.xxh32(@app_key, seed).to_s
    if hash.size < 10
      tmp_hash = ""
      (10-hash.size).times { tmp_hash << '0' }
      hash = tmp_hash + hash
    end
    hash
  end
  
  def diagonal(from, dx)
    if dx == 0
      from.map.with_index { |n,i| n[i] } 
    else
      from.map.with_index { |n,i| n[n.size-i-1] }
    end
  end
  
  # http://stackoverflow.com/a/23844729
  def combos(n,k,min = 0, cache = {})
    #if n < k || n < min
    if n < min
      return []
    end
    cache[[n,k,min]] ||= begin
      if k == 1
        return [n]
      end
      (min..n-1).flat_map do |i|
        combos(n-i,k-1, i, cache).map { |r| [i, *r] }
      end
    end
  end
  
  def matrix(r, c)
    Array.new(r) { Array.new(c) }
  end
  
  def make_matrix
    matrix(7, 7)
  end
  
  def rand_ascii_dec
    case rand(0..2)
      when 0 then rand(48..57) # [0..9]
      when 1 then rand(65..90) # [A..Z]
      when 2 then rand(97..122) # [a..z]
    end
  end
  
  def even_rand(even)
    found = nil
    loop do # WARN: no safe exit condition
      found = rand_ascii_dec
      case found % 2
      when 0
        break if even
      when 1
        break if !even
      end
    end
    found
  end
  
  def place_inner_rand(in_matrix)
    #in_matrix.map.with_index { |row, i| row.map.with_index { |col, j| col = 666 if i == j } }
    #in_matrix.map!.with_index { |row, i| row.map.with_index { |col, j|
      #( i != j and i > 0 and i < 6 and j < 6 ) ? rand_ascii_dec : col } }
    in_matrix.map!.with_index { |row, i| row.map.with_index { |col, j| (i < 6 and col.nil?) ? rand_ascii_dec : col } }
  end
  
  def find_sequence(sum, size, in_matrix)
    possibilities = combos(sum, size)
    #p possibilities
    chosen = rand(0..9)
    reverse = Time.now.to_ms % 2 == 0 ? even_rand(true) : even_rand(false)
    #p chosen
    #p reverse
    # save chosen in n05
    in_matrix[0][4] = chosen
    in_matrix[0][5] = reverse
    # return the chosen sequence (inverted if 'reverse' is uneven)
    reverse % 2 == 0 ? possibilities[chosen] : possibilities[chosen].reverse
  end
  
  def place_sequence(in_matrix)
    sum = in_matrix[6][6]
    chosen_sequence = find_sequence(sum, 6, in_matrix)
    #p chosen_sequence
    in_matrix.each_with_index { |row, i| row[6] = chosen_sequence[i] if i < 6 } 
    in_matrix
  end
  
  def place_sum(in_matrix)
    #p in_matrix
    sum_array = in_matrix.select.with_index { |row, i| i < 6 }.transpose.map {|x| x.reduce(:+)}
    #in_matrix[6] = *sum_array
    #p in_matrix
    #p sum_array
    sum_array.each_with_index { |n, j| in_matrix[6][j] = constrain(n) }
    #p in_matrix
  end
  
  def expand(number, mult)
    
    #p number
    
    base = number + 192 + (62*mult)
    short = nil
    
    case number
    when 48..57 then short = base-48
    when 65..90 then short = base+10-65
    when 97..122 then short = base+10+26-97
    end
    #p short
    short
  end
  
  def constrain(number)
    mult = 0
    #p number
    case number
    # these are the only possible combinations
    # (sets of 62 - as the alphabet allowed)
    when 192+62*0..192+62*1-1 then mult = 0 #192..253
    when 192+62*1..192+62*2-1 then mult = 1 #254..315
    when 192+62*2..192+62*3-1 then mult = 2 #316..377
    when 192+62*3..192+62*4-1 then mult = 3 #378..439
    when 192+62*4..192+62*5-1 then mult = 4 #440..501
    when 192+62*5..192+62*6-1 then mult = 5 #502..563
    when 192+62*6..192+62*7-1 then mult = 6 #564..619
    end
    
    @mults << mult
    
    base = number - 192 - (62*mult)
    short = nil
    #p base
    
    case
    when base < 10 then short = base+48
    when (base >= 10 and base < 10+26) then short = base-10+65
    when (base >= 10+26 and base < 10+26+26) then short = base-10-26+97 
    #TODO: vedi per bene come gestire gli input fasulli, un po ovunque...
    end
    #p short
    short

  end
  
  def get_mults
    mults = @mults.join.sub!(/^(0?)+/,'').to_i.to_s(25)
    @mults.clear
    mults
    #@mults.map { |m| 
    #  case m
    #  when 0 then 101.dec_to_ascii
    #  when 1 then 68.dec_to_ascii
    #  when 2 then 50.dec_to_ascii
    #  when 3 then 120.dec_to_ascii
    #  when 4 then 110.dec_to_ascii
    #  when 5 then 49.dec_to_ascii
    #  when 6 then 71.dec_to_ascii
    #  end
    #}
  end
  
  def pack_hash(in_matrix)
    #p in_matrix
    #p @mults
    packed_hash = []
    d1 = diagonal(in_matrix, 0)
    i = 0
    packed_hash.push(get_mults)
    #p packed_hash
    7.times {
      packed_hash.push(*pick_col(in_matrix, i))
      #p packed_hash
      i += 1
    }
    #p packed_hash
    packed_hash = packed_hash.dec_to_ascii
    #p packed_hash
    ascii = packed_hash.join
    #p ascii
    ascii
  end
  
  def pick_row(in_matrix, index)
    in_matrix[index]
  end
  
  def pick_col(in_matrix, i)
    buf = []
    in_matrix.each { |row| buf << row[i] }
    buf
  end
  
  def place_hash(in_matrix)
    secret = make_hash
    in_matrix[0][0] = secret[0].to_i #n01
    in_matrix[0][1] = secret[1].to_i
    in_matrix[0][2] = secret[2].to_i
    in_matrix[0][3] = secret[3].to_i
    in_matrix[1][1] = secret[4].to_i
    in_matrix[2][2] = secret[5].to_i
    in_matrix[3][3] = secret[6].to_i
    in_matrix[4][4] = secret[7].to_i
    in_matrix[5][5] = secret[8].to_i
    in_matrix[5][6] = secret[9].to_i
    in_matrix
  end
  
  def make_hash
    now = Time.now
    seed = now.to_i
    app_hash = xxhash(@app_key, seed)
  end
    

  def unpack_hash(hash)
    pos = [ [0,0], [0,1], [0,2], [0,3], [1,1], [2,2], [3,3], [4,4], [5,5], [5,6] ]
    
    digested_mult = hash.reverse.split(//).each_slice(7).to_a.last.reverse
    #p digested_mult
    @mults = discover_mult(digested_mult)
    #p @mults
    matrix = hash.slice((digested_mult.size)..-1).split(//).each_slice(7).to_a
    #p matrix
    matrix = invert_rows_cols(matrix)
    #p matrix
    matrix.each_with_index { |row, i| row.map!.with_index { |el, j| (!pos.include? [i,j]) ? el.ascii_to_dec : el.to_i } }
    #p matrix
    matrix
  end
  
  
  def discover_mult(from_array)
    guess = from_array.join.to_i(25).to_s.split(//).map{ |el| el.to_i }
    (7-guess.size).times { guess.insert(0,0) } if guess.size < 7
    guess
  end
  
  def invert_rows_cols(in_matrix) #only for quadratic matrices!
    inverted = []
    j = 0
    (in_matrix.size).times {
      inverted << in_matrix.map.with_index { |row, i| row[j] }
      j+=1
    }
    inverted
  end
  
  def reconstruct_sum(in_matrix)
    #p in_matrix
    obfuscated_sum = in_matrix.last.map!.with_index { |el, i| expand(el, @mults[i]) }
    @mults.clear
    #p obfuscated_sum
    in_matrix[6] = obfuscated_sum
    in_matrix
    #p in_matrix
  end
  
  
  def extract_hash(in_matrix)
    
    app_hash = ""
    app_hash += in_matrix[0][0].to_s
    app_hash += in_matrix[0][1].to_s
    app_hash += in_matrix[0][2].to_s
    app_hash += in_matrix[0][3].to_s
    app_hash += in_matrix[1][1].to_s
    app_hash += in_matrix[2][2].to_s
    app_hash += in_matrix[3][3].to_s
    app_hash += in_matrix[4][4].to_s
    app_hash += in_matrix[5][5].to_s
    app_hash += in_matrix[5][6].to_s
    
    #p app_hash
    
    try_hashes(app_hash)
    
  end
  
  def try_hashes(expected_hash)
    found = false
    test_hashes = []
    now = Time.now
    seed = now.to_i
    i = 0
    @window.times { 
      new_hash = xxhash(@app_key, seed-i)
      if new_hash == expected_hash
        found = true
        break;
      else
        i+=1
      end
    }
    found
  end
  
  def first_validation(in_matrix)
    #p in_matrix
    matrix = Matrix[*in_matrix]
    matrix.determinant == 0
  end
  
  def encode
    m = make_matrix
    place_hash(m)
    place_inner_rand(m)
    place_sum(m)
    pack_hash(m)
  end
  
  
  def decode(hash)
    m = unpack_hash(hash)
    reconstruct_sum(m)
    if first_validation(m)
      extract_hash(m)
    else
      false
    end
  end
  
end

f = Foken.new
hash = nil
valid = nil
20.times { 
  hash = f.encode
  valid = f.decode(hash) ? 'valid' : 'invalid'
  print Time.now.strftime('%H:%M:%S.%L')
  puts "  |  #{hash}  |  #{valid}"
  #Benchmark.realtime { hash = f.encode } * 1000
  sleep 0.5
}