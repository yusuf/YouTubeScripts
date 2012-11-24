#!/usr/bin/ruby
require 'open-uri'
require 'cgi'
# for ruby 1.9.2 + use
# require 'uri'

rgVerifyAge = 'verify-age-thumb'
rgCaptcha = 'das_captcha'
# rgTitle = Regexp.new(/(.*) – YouTube/)
rgTitle = Regexp.new(/\<meta name="title" content=.*/)
rgEncoded = Regexp.new(/stream_map=(.[^&]*?)&/i)
rgLink = Regexp.new(/^(.*?)\\u0026/)
# rgLink = Regexp.new(/url=.*\\u0026/)

# http = Net::HTTP.new(@host, @port)
# http.read_timeout = 500

# youtubepath = 'http://www.youtube.com/watch?v=D-iT8lPvwyE'
# youtubepath = 'http://www.youtube.com/watch?v=BV3GygD51Mw' #adult video
# youtubepath = 'http://www.youtube.com/watch?v=Kk6HpPnsU74' #removed video
youtubepath = 'http://www.youtube.com/watch?v=0ksI-LwbFtk'
# youtubepath = 'http://localhost/tmp/yt.html'
puts "Fetching HTML Source From YouTube"
uri = URI.parse(youtubepath)
if(!uri)
	puts "Invalid YouTube Link"
else
	open(uri) do |file|
		
		htmlSource = file.read
		# rescue Timeout::Error => e
		# 		p e
		puts "HTML Source Fetch Done!"

		def prompt default, *args
		  print *args
		  result = gets.strip
		  return result.empty? ? default : result
		end

		def download vidLink, vidFile
			puts "Downloading Video..."
			# open(vidFile, 'wb') do |vFile|
			# 	vFile.print open(vidFile).read
			# end
			writeOut = open(vidFile, "wb")
			writeOut.write(open(vidLink).read)
			rescue Timeout::Error => e
				p e
				exit
			writeOut.close
		end

		# search for adult video
		if htmlSource.match rgVerifyAge
			puts "Adult Video, Stop!"
			exit
		end

		# search for Captcha
		if htmlSource.match rgCaptcha
			puts "Captcah Requested!"
			exit
		end

		# search for the download link
		if rgEncoded.match(htmlSource)
			vidEncodedSrc = rgEncoded.match(htmlSource)
			# p vidEncodedSrc
			# exit
			puts "Found Video Links!"
		else
			puts "Download URL not found!"
			exit
		end
		
		# p vidEncodedSrc
		# exit
		vidDecodedSrc = CGI::unescape(vidEncodedSrc[1])

		#for ruby 1.9.2 + use
		# vidDecodedSrc = URI.unescape(vidEncodedSrc[0])
		# vidDecodedSrc = URI.decode_www_form_component(vidEncodedSrc[0])
		
		 # p vidDecodedSrc
		 # exit
		
		vidLinks = rgLink.match(vidDecodedSrc)
		 # p vidLinks
		 # exit
		
		vidDecodedSrc = vidLinks[1].split('"')
		# p vidDecodedSrc
		# exit
		
		# vidLink = CGI::unescape(vidLink[1])
		# vidLink = vidLink.gsub('%2C',',')
		# vidLink = vidLink.gsub('\u0026','')
		
		foundLinks = {}
		for urls in vidDecodedSrc
			urls.split(",").each do |url|
				uc = url.split("&")
				um = uc[1].split('=')
				ul = uc[0].split("=")
				si = uc[4].split("=") 
				u = CGI::unescape(CGI::unescape(um[1]))
				foundLinks[ul[1]]=u+'&signature='+si[1]
			end
		end

		#  search for the title
		if rgTitle.match(htmlSource)
			vidTitle = []
			vidTitle = rgTitle.match(htmlSource)
			vidTitle = vidTitle[0].gsub("<meta name=\"title\" content=\"","").gsub("&quot;\">","").gsub("&quot;","").gsub(" ","").gsub("\">","").strip
			vidTitle = CGI::escape(vidTitle)
			# vidTitle = vidTitle.gsub(" ","")
		else
			vidTitle = "YouTube Video"
		end
		
		# p vidfile
		@formats = {}
		@formats[13] = ['3gp','Low Quality']
		@formats[17] = ['3gp','Medium Quality']
		@formats[36] = ['3gp','High Quality']
		@formats[5] = ['flv','Low Quality']
		@formats[6] = ['flv','Low Quality']
		@formats[34] = ['flv','High Quality (320p)']
		@formats[35] = ['flv','High Quality (480p)']
		@formats[18] = ['mp4','High Quality (480p)']
		@formats[22] = ['mp4','High Quality (720p)']
		@formats[37] = ['mp4','High Quality (1080p)']

		@vidFile = {}
		for format in @formats
			if(foundLinks.has_key?(format[0].to_s))
				@vidFile[format[0]] = Hash["ext",format[1][0],"type",format[1][1],"url",foundLinks[format[0].to_s]+'&title='+CGI::escape(vidTitle)]
			end
		end

		if(@vidFile.empty?)
			puts "No Downloadable Videos Found!"
			exit
		end
		# Prompt for desired Video Quality
		downQuality = @vidFile.keys[0]
		puts "Available Video Qualities:"
		for aQ in @vidFile
			puts aQ[0].to_s+": "+aQ[1]["type"]+" "+aQ[1]["ext"]
		end
		downQuality = prompt(downQuality.to_i, "Select Video Quality: ("+downQuality.to_s+"): ")
		# check prompt value
		if(foundLinks.has_key?(downQuality))
			# p downQuality
			# p @vidFile		
			# vidDLink = URI.encode(@vidFile[downQuality.to_i]['url'].strip.gsub('"',''))
			vidDLink = (@vidFile[downQuality.to_i]['url'].strip.gsub('"',''))
			# p vidDLink
			# vidDLink = "http://o-o---preferred---sn-qipg55b0-haxe---v19---lscache1.c.youtube.com/videoplayback?upn=uLrOUb26hUw&sparams=cp%2Cgcr%2Cid%2Cip%2Cipbits%2Citag%2Cratebypass%2Csource%2Cupn%2Cexpire&fexp=906717%2C912307%2C912708%2C910100%2C916611%2C922401%2C920704%2C912806%2C927201%2C925706%2C922403%2C913546%2C913556%2C916805%2C920201%2C901451&ms=au&expire=1353717747&itag=37&ipbits=8&gcr=mv&sver=3&ratebypass=yes&mt=1353693848&ip=27.114.134.32&mv=m&source=youtube&key=yt1&cp=U0hUSFdMVV9JUUNONF9PRllIOkljclpza0d0YUN2&id=2a4e87a4f9ec53be&newshard=yes&signature=B171F8C50E5EB38A9433B5C0AFCA913061DE5A41.42039EF8E8042E912B46AE50F37CA73EBF4EEF33&title=YouTube"
			vidFileName = vidTitle+'-'+@vidFile[downQuality.to_i]['type']+'.'+@vidFile[downQuality.to_i]['ext']
			vidFileName = (vidFileName.strip).gsub(" ","")
			# p vidTitle
			# p vidFileName
			# exit
		
			download(vidDLink,vidFileName)

			puts "Download Done!"
		else
			puts "Invalid Quality, Try Again"
		end
	end

end