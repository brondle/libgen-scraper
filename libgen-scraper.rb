# initial code taken from https://github.com/athityakumar/libgen-scraper - repo is out of date but i am eternally grateful nonetheless
require 'mechanize'
require 'henkei'
def search(input) 
  mechanize = Mechanize.new
  mechanize.history_added = Proc.new { sleep 3 }
  mechanize.follow_meta_refresh = true 
  mechanize.verify_mode = OpenSSL::SSL::VERIFY_NONE
  mechanize.pluggable_parser.default = Mechanize::Download 


  input , hash_list , select = input.gsub("  "," ").gsub(" ","+") , [] , 0
  query = "http://gen.lib.rus.ec/search.php?&req=#{input}&phrase=1&view=simple&column=def&sort=def&sortmode=ASC&page=1"
  page = mechanize.get(query)
  count = page.search(".c tr").count
  puts "\n FINDING TOP RESULTS (25 OPTIONS AT MAX) \n"

  for i in (1..count-1)
    auth , book = page.search(".c tr")[i].search("td")[1].text , page.search(".c tr")[i].search("td")[2].children.last.text  
    puts "(#{i}) #{book} - #{auth} "
    hash = page.search(".c tr")[i].search("td")[2].children.last["href"].split("md5=")[1]
    hash_list.push([hash,auth,book])
  end

  while !(select >= 1 && select <= i)
    puts "Select a book (1 - #{i}) : "
    select = gets.chomp.to_i
    if (select >= 1 && select <= i)
      filename =  hash_list[select-1][2]
   + " " +  hash_list[select-1][1]
      filename = filename.gsub(" ","%20")
      puts "#{hash_list[select-1][0]}/#{filename}"
      puts "Starting download of #{filename}"
      page = mechanize.get("http://download.library1.org/main/#{hash_list[select-1][0]}/#{filename}")
      puts page
      links = "#{page.links_with(:text => 'GET')}"
      if (links.length < 1)
        puts "No links available."
        puts "Search for a book : "
        input , filename = gets.chomp , ""
        search(input)
      else
        newfile = page.links_with(:text => 'GET')[0].click.save
        data = File.read "#{newfile}"
        text = Henkei.read :text, data
        file = File.open("#{filename}_txt_.txt", "w")
        file.puts text
        file.close
      end
    else
      puts "Invalid choice."
      puts "Search for a book : "
      input , filename = gets.chomp , ""
      search(input)
     
    end
  end
  puts "Search for a book : "
  input , filename = gets.chomp , ""
  search(input)
end

unless Dir.exist? "pdf"
    Dir.mkdir("pdf")
    puts "Created folder 'pdf' to download books into."
end 
Dir.chdir("pdf")

if ARGV[0] == "testing"
  input = "beer mechanics" 
  ARGV[0].clear
else
  puts "Search for a book : "
  input , filename = gets.chomp , ""
  search(input)
end

