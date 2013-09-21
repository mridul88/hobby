character_count =0 
charwithoutspace_count=0
line_count = 0
para_count =0 
sentence_count =0 
word_count =0
vowel_count =0 
words = []
  
File.open("text.txt").each do
  |line|
  
  line_count +=1
  
  if(line)
    
    character_count += line.length
    
    line.scan(/\S/){|ch| 
    if(ch) 
       charwithoutspace_count += 1
    end
  }
      
  
  line.scan(/\w+/){|word| 
    if(word) 
       word_count += 1
       words << word
    end
  }
  
  line.scan(/[aeiou]/i){|vowel|
      print vowel, 
      vowel_count+=1
    }
 
  line.scan(/\.|\?|\!/){|sentence| 
    if(sentence)
      sentence_count+=1
    end
  }
  
  
  
  line.scan(/^\n/){|para|
    if(para)
      para_count+=1
     end
  }
  end

end

puts "character count = #{character_count}"
puts "word count = #{word_count}"
puts "character without space count = #{charwithoutspace_count}"
puts "sentence count = #{sentence_count}"
puts "line count = #{line_count}"
puts "para count = #{para_count}"
puts "No. of Vowel =#{vowel_count}"
 

stop_words = File.readlines("stop_words.txt").join
stop_words.split(',')


keywords = words.select{|word| !stop_words.include?(word)}

puts "stop_words_count = #{keywords.join(' ').scan(/\w+/).length}"
