#!/usr/bin/env ruby

require 'colorize'
require 'set'
require 'thread'

class PGen
  SPC = %w[! @ # $ % ^ & * ? _ - + =].freeze          
  FAV = %w[0 1 2 3 4 5 6 7 8 9 10 20 2020 100 12 123  
           1234 12345 123456 1234567 12345678 123456789
           1234567890 000 111 222 333 444 555 666 777
           888 999 0000 1111 2222 3333 4444 5555 6666
           7777 8888 9999].freeze
  LEET = { 'a' => '4', 'e' => '3', 'i' => '1', 'o' => '0',  
           's' => '5', 't' => '7' }.freeze
  def initialize
    @fn = @ln = @bd = @ph = ''      # first name, last name, birthday, phone
    @sug = ''                   
    @cnt = 0                     
    @mtx = Mutex.new                 
  end
  def cls
    Gem.win_platform? ? system('cls') : system('clear')
  end
  def banner
    bnr = %q(
       /\
      /  \.--./\
     /    \  /  \
    /      \/    \        .--.
   /     |\_/|    \       |   | .---.
  /     / o o\     \      |   | |   | .---.
 /      /(   )\     \     |   `-'   |_|   |
/       / \#/ \      \    |         ._____'
        |     |           `---.     |
        | | | |                |    |
      (~\ | | /~)              |    |
     __\_|| ||_/__             |    |
___///_//_| |_\\__\\\____________|____|
).colorize(:magenta)
    puts bnr
    puts "\tDeveloper : Monji".colorize(:green)
    puts "\tVersion : 2.0.0 ".colorize(:green)
  end
  def get_inputs
    print "\t[+] ".colorize(:green) + "first Name ".colorize(:blue) + ": "
    @fn = gets.chomp.strip.downcase
    print "\t[+] ".colorize(:green) + "last Name ".colorize(:blue) + ": "
    @ln = gets.chomp.strip.downcase
    print "\t[+] ".colorize(:green) + "birthday (YYYY/MM/DD) ".colorize(:blue) + ": "
    @bd = gets.chomp.strip
    print "\t[+] ".colorize(:green) + "phone Number ".colorize(:blue) + ": "
    @ph = gets.chomp.strip
    print "\t[+] ".colorize(:green) + "any suggested words? (comma separated, Enter to skip) ".colorize(:blue) + ": "
    @sug = gets.chomp.strip.downcase

    die('First name, last name, birthday and phone are required!') if [@fn, @ln, @bd, @ph].any?(&:empty?)
  end
  def die(msg)
    puts msg.colorize(:red)
    exit 1
  end
  def parse_birthday
    @yr = @bd[2..3]      
    @yrs = @bd[0..3]    
    @mn = @bd[5..6]      
    @dy = @bd[8..9]      
    die('invalid birthday format use YYYY/MM/DD') if [@yr, @yrs, @mn, @dy].any?(&:nil?)
  end

  def parse_suggested
    @sug_list = @sug.empty? ? [] : @sug.split(',').map(&:strip)
  end


  def bv
    fn_v = [@fn, @fn.capitalize, @fn.upcase]
    ln_v = [@ln, @ln.capitalize, @ln.upcase]
    comb = fn_v.product(ln_v).map(&:join)

    all = (fn_v + ln_v + comb + @sug_list).to_set

    leet_v = all.map { |w| w.gsub(/[aeiost]/i, LEET) }
    (all + leet_v).to_a
  end

  def write_line(f, str)
    @mtx.synchronize do
      f.puts str
      @cnt += 1
    end
  end

  def stage1(f, bases)
    puts "[1] Generating base words...".colorize(:yellow)
    bases.each { |b| write_line(f, b) }
  end

  def stage2(f, bases)
    puts "[2] Adding year/phone combinations...".colorize(:yellow)
    bases.each do |b|
      write_line(f, b + @yr)
      write_line(f, b + @yrs)
      write_line(f, b + @dy + @mn + @yr)
      write_line(f, b + @ph[0..2]) if @ph.length >= 3
      write_line(f, b + @ph[3..5]) if @ph.length >= 6
      write_line(f, b + @ph[6..9]) if @ph.length >= 10
    end
  end

  def stage3(f, bases)
    puts "[3] Adding special characters...".colorize(:yellow)
    bases.each do |b|
      SPC.each do |ch|
        write_line(f, b + ch)
        write_line(f, b + ch + @yr)
        write_line(f, b + ch + @yrs)
        write_line(f, b + ch + @dy + @mn + @yr)
        write_line(f, b + ch + @ph[0..2]) if @ph.length >= 3
        write_line(f, b + ch + @ph[3..5]) if @ph.length >= 6
        write_line(f, b + ch + @ph[6..9]) if @ph.length >= 10
      end
    end
  end
  def stage4(f, bases)
    puts "[4] Adding favorite numbers...".colorize(:yellow)
    bases.each do |b|
      FAV.each do |num|
        write_line(f, b + num)
        SPC.each do |ch|
          write_line(f, b + ch + num)
        end
      end
    end
  end
  def run
    cls
    banner
    get_inputs
    parse_birthday
    parse_suggested

    bases = bv
    puts "[*] Total b->v: #{bases.size}".colorize(:cyan)

    File.open('pass.txt', 'w') {}

    stages = [method(:stage1), method(:stage2), method(:stage3), method(:stage4)]

    stages.each_with_index do |stage, idx|
      q = Queue.new
      bases.each { |b| q << b }

      thr = []
      4.times do
        thr << Thread.new do
          File.open('pass-p.txt', 'a') do |f|
            while !q.empty? && (b = q.pop(true) rescue nil)
              stage.call(f, [b]) 
            end
          end
        end
      end
      thr.each(&:join)
    end

    fsize = File.size('passlist_progressive.txt')
    puts "\n[✓] Done! Passwords generated: #{@cnt}, File size: #{fsize} bytes".colorize(:green)
  end
end

PGen.new.run if __FILE__ == $PROGRAM_NAME
