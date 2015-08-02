require 'xxhash'
require 'benchmark'
#require 'bcrypt'

class Time
  def to_ms
    (self.to_f * 1000.0).to_i
  end
end

class String
  def read_int(at_pos)
    self.split(//)[at_pos].to_i if at_pos < self.size
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
    self.map!{ |el| el.class == Fixnum ? el.dec_to_ascii_safe : el }.join
  end
  def clusterize(group_size)
    self.each_slice(group_size).to_a
  end
end

class Integer
  # nb. this function DO NOT convert ints from 0 to 9!
  def dec_to_ascii_safe
    !(self >= 0 and self <= 9) ? self.chr : self
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
    @app_key = "sonofiga"
    @window = (60 * 10 + 1).to_i #5 min window
  end
  
  def diagonal(from, dx)
    if dx == 0
      from.map.with_index { |n,i| n[i] } 
    else
      from.map.with_index { |n,i| n[n.size-i-1] }
    end
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
  
  def rand_ascii_dec(how_many)
  foken_array = [] 
    how_many.times {
      foken_array <<
        case rand(0..2)
        when 0 then rand(48..57) # [0..9]
        when 1 then rand(65..90) # [A..Z]
        when 2 then rand(97..122) # [a..z]
        end
    }
    foken_array
  end
  
  def obfuscate(number)
    #p number
    now = Time.now
    #seed = (now.day - ( now.min >= @window / 60 ? ( now.hour == 0 ? 23 : now.hour-1 ) : now.hour )).abs # 5 min grace
    seed = now.hour
    case seed
    when 0..7
      number = seed.even? ? number+65 : number+65+9
    when 8..14
      number = seed.even? ? number+97 : number+97+9
    when 15..23
      number = seed.even? ? number+48 : number+97+9
    end
    #p number
    number.dec_to_ascii
    #p conv
    #conv
  end
  
  def de_obfuscate(character)
    number = character.ascii_to_dec
    #p number
    #p number
    now = Time.now
    #seed = (now.day - ( now.min >= @window / 60 ? ( now.hour == 0 ? 23 : now.hour-1 ) : now.hour )).abs # 5 min grace
    seed = now.hour
    case number
    when 65..83 # -7 to 90
      number = seed.even? ? (number-65).abs : (number-65-9).abs
    when 97..115 # -7 to 121
      number = seed.even? ? (number-97).abs : (number-97-9).abs
    when 48..57
      number = (number-48).abs
    end
    number
  end
  
  def web_key
  end
  
  def app_key
  end
  
  def encode
    foken_array = rand_ascii_dec(39)
    #p foken_array
    #puts
    
    
    now = Time.now
    # continua ad usare un seme dell'ora prima nei primi 10 minuti di un'ora nuova
    # serve ad evitare che si capisca che il seme cambia allo scattare dell'ora precisa
    #seed = now.year / now.day + ( (now.min >= 0 and now.min <= 10) ? now.hour-1 : now.hour )
    #seed = (Time.now.to_f % 2).to_s.split('.')[1]
    seed = now.to_i
    # NB si dovrà fare in modo che i token siano generati NON in una finestra di tempo in cui il seme vari!
    # ..cioè, il token deve essere re-issued allo scattare dei primi 15 minuti di un'ora
    # se il token è stato issuato poco prima, si salta direttamente ai primi 15 minuti dell'ora SUCCESSIVA per il reissue
    # come? Lato server, si guarda alla scadenza del token (messa alla sua creazione), se il token è stato creato 
    app_hash = xxhash(@app_key, seed)
    #p app_hash
    #puts
  
    j = 0
    r0 = foken_array.select.with_index { |n,i| i < 3 }; j += 3
    r1 = foken_array.select.with_index { |n,i| i >= j and i < j+6 }; j += 6
    r2 = foken_array.select.with_index { |n,i| i >= j and i < j+6 }; j += 6
    r3 = foken_array.select.with_index { |n,i| i >= j and i < j+6 }; j += 6
    r4 = foken_array.select.with_index { |n,i| i >= j and i < j+6 }; j += 6
    r5 = foken_array.select.with_index { |n,i| i >= j and i < j+6 }; j += 6
    r6 = foken_array.select.with_index { |n,i| i >= j and i < j+6 }; j += 6
  
  
    # web key
    n00 = app_hash.read_int(3)
    n01 = app_hash.read_int(0)
    n02 = app_hash.read_int(1)
    n03 = app_hash.read_int(2)
  
    n11 = app_hash.read_int(4)
    n22 = app_hash.read_int(5)
    n33 = app_hash.read_int(6)
    n44 = app_hash.read_int(7)
    n55 = app_hash.read_int(8)
    n66 = app_hash.read_int(9)
  
    #riga 0
    r0.insert(0, n03)
    r0.insert(0, n02)
    r0.insert(0, n01)
    r0.insert(0, n00)
    
  
    #riga 1
    r1.insert(1, n11)
  
    #riga 2
    r2.insert(2, n22)
  
    #riga 3
    r3.insert(3, n33)
  
    #riga 4
    r4.insert(4, n44)
  
    #riga 5
    r5.insert(5, n55)
  
    #riga 6
    r6.insert(6, n66)
    
  
    foken_array = []
    foken_array.push(*r0)
    foken_array.push(*r1)
    foken_array.push(*r2)
    foken_array.push(*r3)
    foken_array.push(*r4)
    foken_array.push(*r5)
    foken_array.push(*r6)
    
    foken_array = foken_array.clusterize(7)
  
    #foken_array
    #puts
  
    packed_hash = []
  
    i = 0
    
    d1 = diagonal(foken_array, 0)
    d2 = diagonal(foken_array, 1)
    #p d1,d2
    #puts
    
    packed_hash.push(*rand_ascii_dec(9))
    packed_hash.push(obfuscate(d1[0]))
    
    packed_hash.push(*rand_ascii_dec(7))
    packed_hash.push(obfuscate(d1[1]))
    packed_hash.push(*rand_ascii_dec(2))
    
    packed_hash.push(*r0[0])
    packed_hash.push(obfuscate(*r0[1]))
    packed_hash.push(obfuscate(*r0[2]))
    packed_hash.push(obfuscate(*r0[3]))
    packed_hash.push(*r0[4])
    packed_hash.push(*r0[5])
    packed_hash.push(*r0[6])
    packed_hash.push(obfuscate(d1[2]))
    packed_hash.push(obfuscate(d1[3]))
    packed_hash.push(*rand_ascii_dec(1))
    
    packed_hash.push(*r3)
    packed_hash.push(obfuscate(d1[4]))
    packed_hash.push(obfuscate(d1[5]))
    packed_hash.push(*rand_ascii_dec(1))
    
    packed_hash.push(*r6)
    packed_hash.push(obfuscate(d1[6]))
    packed_hash.push(*rand_ascii_dec(2))
    
    packed_hash.push(*rand_ascii_dec(3))
    
    #p packed_hash
    #puts
    
    #p packed_hash.clusterize(10)
    
    ascii = packed_hash.dec_to_ascii
    #p ascii
    
  end
  
  def decode(key)
    #p key
    # "Cw0cb0S5Z 0   Xs60W1U 1 7k   Y1Qr3sA 0 1n   2oj0XBb 46 p   UuyE939 9 pW   yk2"
    # "0E4n1ElLm 1   oYF979p 0 AT   1 984 b72 6 Z1   Y2a64aP 98 0   M6s8TQ4 4 57   ggK"
    #key = "0E4n1ElLm1oYF979p0AT1984b726Z1Y2a64aP980M6s8TQ4457ggK"
    store = key.split(//).each_slice(10).to_a
    app_hash = ""
    
    app_hash += de_obfuscate(store[2][1]).to_s
    app_hash += de_obfuscate(store[2][2]).to_s
    app_hash += de_obfuscate(store[2][3]).to_s
    
    app_hash += de_obfuscate(store[0][9]).to_s
    
    app_hash += de_obfuscate(store[1][7]).to_s
    
    app_hash += de_obfuscate(store[2][7]).to_s
    app_hash += de_obfuscate(store[2][8]).to_s
    
    app_hash += de_obfuscate(store[3][7]).to_s
    app_hash += de_obfuscate(store[3][8]).to_s
    
    app_hash += de_obfuscate(store[4][7]).to_s
    
    #p app_hash
    
    try_hashes(app_hash)
    
    #key.split(*//).each_slice(10).to_a.map { |s| s.delete_if.with_index { |el, i| i >= 7 } }.keep_if { |e| e.size == 7 }
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
  
end
r = Foken.new
key = ""
res = false
puts
print "* Encoding: "; puts Benchmark.realtime { key = r.encode } * 1000
print "* Decoding: "; puts Benchmark.realtime { res = r.decode(key) } * 1000
#10.times {
#key = r.encode
#res = r.decode(key)
#puts "#{Time.now}  |  #{key}"
#sleep 1
#}
puts
p key
puts
puts res ? ' ---> All OK.' : ' ---> ERROR!'
puts
#p r.obfuscate(0)
#p r.de_obfuscate('2')
#puts Benchmark.measure { BCrypt::Password.create("my password") }
