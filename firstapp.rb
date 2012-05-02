Camping.goes :FirstApp

module FirstApp
	module Models
		class Twit < Base
			validates :content, :presence => true, :length => { :maximum => 200 }
		end

		class Fields < V 1.0
			def self.up
				create_table Twit.table_name do |t|
					t.text	:content
					t.timestamps
				end
			end

			def self.down
				drop_table Twit.table_name
			end
		end
	end

	module Controllers
		class Index < R '/'
			def get
				@tweets = Twit.all( :order => 'created_at DESC' )
				render 	:index
			end
		end

		class Show < R '/(\d+)'
			def get( id )
				@tweet = Twit.find_by_id(id)

				unless @tweet
					render :notweet
				else
					render :show
				end
			end
		end

		class Add < R '/new'
			def get
				@tweet = Twit.new
				render :add
			end

			def post
				# Why Do I have to do this when I already initialized it in get? :s
				@tweet = Twit.new

				@tweet.content = @input.content

				if @tweet.save
					redirect Show, @tweet.id
				else
					redirect Add
				end
			end
		end
	end

	module Views
		def layout
			html do
				head do
					title "Twatter"
				end

				body do
					h2 "Twatter"
					self << yield
				end
			end
		end

		def index
			p do
				a "new tweet!", :href => R( Add )
			end

			br

			@tweets.each do |tweet|
				self << tweet.content
				2.times do br end	# Two line breaks!
			end
		end

		def show
			self << @tweet.content
		end

		def notweet
			p "That tweet does not exist"
		end

		def add
			h3 "New tweet"
			if @err; p @err end
			form :action => R( Add ), :method => :post do
				textarea @tweet.content, :name => :content,
					:rows => 3, :cols => 20

				br
				
				input :type => :submit, :value => "Submit!"
			end
		end
	end

	def self.create
		FirstApp::Models.create_schema
	end
end
