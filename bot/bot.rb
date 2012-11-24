require 'yaml'
require './wordplay' 

# A basic implementation of a chatter box
class Bot
 attr_reader :name
 
 # Initialize the bot object, loads in the external YAML data
 # file and sets the bot's name. Raises an exception if 
 # the data loading process fails. 
 def initialize(options)
  @name = options[:name] || "Unnamed bot"
  begin 
   @data = YAML.load(File.open(options[:data_file]).read)
  rescue
   raise "Can't load bot data"
  end
 end
 
  # Returns a random greeting as specified in the bot's data file 
 def greeting
   random_response :greeting
 end
 
  # Returns a random farewell as specified in the bot's data file 
 def farewell
   random_response :farewell
 end
 
  # Responds to input text as given by the user
 def response_to(input)
  prepared_input = preprocess(input.downcase)
  sentence = best_sentence(prepared_input)
  reversed_sentence = WordPlay.switch_pronouns(sentence) 
  responses = possible_responses(sentence)
  responses[rand(responses.length)]
 end
  
 private
 
 # Choses a random response phrase from the :response hash
 # and substitutes metadata into the phrase 
 def random_response(key)
   random_index = rand(@data[:responses][key].length)
   @data[:responses][key][random_index].gsub(/\[name\]/, @name)
 end
 
 # Performs preprocessing apon all input to the bot
 def preprocess(input)
  perform_substitutions input
 end

 # Substitutes words and phrases on supplieed input as dictated by
 # the bot's :presubs data
 def perform_substitutions(input)
  @data[:presubs].each { |s| input.gsub!(s[0], s[1]) }
  input
 end
 
 # Using the single word keys in :responses and search for the
 # sentence that uses the most of them, as it is likely to be the
 # 'best' sentence to parse
 def best_sentence(input)
  hot_words = @data[:responses].keys.select do |k|
   k.class == String && k =~ /^\w+$/
  end
  
  WordPlay.best_sentence(input.sentences, hot_words)
 end  
  
  # Using a supplied sentence, go through the bot's :responses
  # data set and coolect together all phrases that could
  # be used as responses
  def possible_responses(sentence)
  responses = []
  
  # Find all patterns to try to much against
  @data[:responses].keys.each do |pattern|
   next unless pattern.is_a?(String)
   
   # For each pattern, see if the suppplied sentence contains a a match
   # Remove substitution symbols (*) before checking.
   # Push all reponses to the responses array.
   if sentence.match('\b' + pattern.gsub(/\*/, '') + '\b')
    # If the pattern contains substitution placeholders,
    # perform the substitutions
    if pattern.include?('*')
     responses << @data[:reponses][pattern].collect do |phrase|
      # First, erase everything before the placeholder
      # leaving everything after it
      matching_section = sentense.sub(/^.*{pattern}\s+/, '')
      
      # Then substitute the text after the placeholder, with
      # the pronouns switched
      phrase.sub('*', WordPlay.switch_pronouns(matching_section))
     end
    else 
     # No placeholders, just add the phrases to the array
     responses << @data[:responses][pattern]
    end
   end
  end 
  
  # If there were no matches, add the default ones
  responses << @data[:responses][:default] if responses.empty?
  
  # Flatten the block of responses to a flat array
  responses.flatten
 end
  

     
end 

    

