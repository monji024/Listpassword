#!/usr/bin/env ruby
# -*- coding:utf-8 -*-
require 'colorize'
require 'io/console'
if Gem.win_platform?;system("cls")
else;system("clear")
end
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
puts "\tDeveloper : Hosein Monji.".colorize(:green)
puts "\tVersion : 1".colorize(:green)

puts "\n"
j = 0
file = File.open('passlist.txt', 'w')
name_list = []
last_name_list = []
first_name_list = []
special_number = ['!', '@', '#', '$', '%', '^', '&', '*', '?', '_', '-', '+', '=']
favorite_number = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10',
                   '20', '2020', '100', '12', '123', '1234', '12345',
                   '123456', '1234567', '12345678', '123456789']


print "\t[+] ".colorize(:green)+""+"First Name ".colorize(:blue)+"" +": "
first_name = gets.chomp.strip
print "\t[+] ".colorize(:green)+""+"Last Name ".colorize(:blue)+"" +": "
last_name = gets.chomp.strip
print "\t[+] ".colorize(:green)+""+"Birthday (1376/03/12) ".colorize(:blue)+"" +": "
birthday = gets.chomp.strip
print "\t[+] ".colorize(:green)+""+"Phone Number (09120000000) ".colorize(:blue)+"" +": "
phone_number = gets.chomp.strip
print "\t[+] ".colorize(:green)+""+"Special Name (cat,dog) ".colorize(:blue)+"" +": "
special_name = gets.chomp.strip

if first_name.empty? || last_name.empty? || birthday.empty? || phone_number.empty?
  puts "Please fill in all fields."
  exit
end

year = birthday[2..3]
years = birthday[0..3]
month = birthday[5..6]
day = birthday[8..9]

if year.nil? || years.nil? || month.nil? || day.nil?
  puts "Invalid birthday format.".colorize(:red)
  exit
end

first_name.downcase!
first_name_1 = first_name.capitalize
first_name_2 = first_name.upcase
last_name.downcase!
last_name_1 = last_name.capitalize
last_name_2 = last_name.upcase

name_list.push(first_name, first_name_1, first_name_2, last_name, last_name_1, last_name_2)

first_name_list.push(first_name, first_name_1, first_name_2)
last_name_list.push(last_name, last_name_1, last_name_2)

first_name_list.each do |fn|
  last_name_list.each do |ln|
    name_list.push(fn + ln)
  end
end

name_list.each do |name|
  file.puts(name)
  file.puts(name + year)
  file.puts(name + years)
  file.puts(name + day + month + year)
  file.puts(name + phone_number[0..2])
  file.puts(name + phone_number[3..5])
  file.puts(name + phone_number[6..9])
  j += 6

  special_number.each do |item|
    file.puts(name + item)
    file.puts(name + item + year)
    file.puts(name + item + years)
    file.puts(name + item + day + month + year)
    file.puts(name + item + phone_number[0..2])
    file.puts(name + item + phone_number[3..5])
    file.puts(name + item + phone_number[6..9])
    j += 7

    favorite_number.each do |spc_num|
      file.puts(name + spc_num)
      file.puts(name + item + spc_num)
      j += 2
    end
  end
end

file_size = File.size(file.path)
puts "\nFile Created:) -> Number Of Password: #{j}, size: #{file_size}".colorize(:green)
file.close

