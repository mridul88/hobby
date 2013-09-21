age = "dad"
Pi = 4.32
if age > "12"
  1.upto(10) { |x| print "#{age}-#{x} " }
end
puts Pi

class Person
  attr_accessor :name, :age, :country
  
  def come
    puts age
    puts name
  end
end

Person_1 = Person.new
Person_1.age = 45
Person_1.name = "Mridul"
Person_1.come
puts.class

unless Person_1.age > 45 
  puts "#{Person_1.name} is not a young person"
end

str = <<ewnd
Hello, Mridul this is fullstop. Now come the comma, hehhe :).
ewnd

str = str.sub("Mridul", "saranya")
puts str.scan(/\w+/){|ch| print ch +" "} =~ /[0-9]/

x = []
x << "word"
x << "is"
x << "good."

0.upto(3) { |i| puts x[i]}
x = x.join

print x.length
puts x.inspect

dict ={'cat' => 1, 'country' =>2}

dict.each{|key, v| puts "#{key} = #{v}"}

fruit = "orange"
color = case fruit
  when "orange"
    "orange"
  else
    "dddd"
end
 
puts color

class Fixnum
  def hours
    self*60*60
  end
end

puts Time.now + 10.hours

if ('x'..'z').include?('s')
  print "true" 
else
  print "false"
end

puts "Manu".methods.join("->")
