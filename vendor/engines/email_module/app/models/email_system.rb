require 'rubygems'
require 'net/imap'

class EmailSystem

	attr_accessor 'host', 'username', 'password', 'port', 'ssl', 'connection'

  def initialize#(host, username, password, port, ssl)
		conf = BlankConfiguration::ConfigFile.open('mailing.yml').hash
		@host     = conf['host']
		@username = conf['user_name']
		@password = conf['password']
		@port     = conf['port'] #993
		@ssl      = conf['ssl']
		@connection = nil
	end

	def connecting
		imap = Net::IMAP.new(self.host, self.port, self.ssl)
		imap.login(self.username, self.password)
		self.connection = imap
	end

	def retrieving_email_ids_matching_with(email_address)
		res = []
		self.connection.examine('INBOX')
		res += self.connection.search(["FROM", email_address, "NOT", "DELETED"])
		#self.connection.search(["TO", email_address, "NOT", "DELETED"])
#		.each do |uid|
#			envelope = self.connection.fetch(uid, "ENVELOPE")[0].attr["ENVELOPE"]
#			body = self.connection.fetch(uid, "BODY")[0].attr["BODY"]
#			msg = self.connection.fetch(message_id, 'UID')
	end

	def retrieving_email_matching_with(uid)
		
	end

	def extracting_data_from_uid(uid)
		source = self.connection.uid_fetch(uid, ['RFC822']).first.attr['RFC822']
		email = TMail::Mail.parse(source)
		return {
			:uid => uid,
			:date => email.date,
			:from => email.from,
			:to => email.to.join(', '),
			:subject => email.subject,
			:body => email.body
		}
	end

	def self.test
		@fetcher = Fetcher.create({
				:type => :imap,
				:receiver => ActionMailer::Base,
				:server => 'imap.gmail.com',
				:username => 'test@pragtech.co.in',
				:password => 'test123'
			})
		@fetcher.fetch

	end

	def self.all_in_one(email_address)
		em=EmailSystem.new
		em.connecting
		res = []
		em.retrieving_email_ids_matching_with(email_address).each do |msg|
			res << em.extracting_data_from_uid(msg)
		end
		return res
	# NoResponseError and ByResponseError happen often when imap'ing
  rescue Net::IMAP::NoResponseError => e
		return []
    # send to log file, db, or email
  rescue Net::IMAP::ByeResponseError => e
		return []
    # send to log file, db, or email
  rescue => e
    p e
  end

end


# ## select the INBOX as the mailbox to work on #$imap.select('INBOX')
#
# #messages_to_archive = []
#
# ## retrieve all messages in the INBOX that ## are not marked as DELETED
# (archived in Gmail-speak) #$imap.search(["NOT", "DELETED"]).each do
# |message_id|
#  # the mailbox the message was sent to
#  # addresses take the form of {mailbox}@{host}
#  mailbox = $imap.fetch(message_id, 'ENVELOPE')[0].attr['ENVELOPE'].to[0].mailbox
#
#  # give us a prettier mailbox name -
#  # this is the label we'll apply to the message
#  mailbox = mailbox.gsub(/([_\-\.])+/, ' ').downcase
#  mailbox.gsub!(/\b([a-z])/) { $1.capitalize }
#
#  begin
#    # create the mailbox, unless it already exists
#    $imap.create(mailbox) unless $imap.list('', mailbox)
#  rescue Net::IMAP::NoResponseError => error
#  end
#
#  # copy the message to the proper mailbox/label
#  $imap.copy(message_id, mailbox)
#
#  messages_to_archive << message_id
# #end
#
# ## archive the original messages #$imap.store(messages_to_archive, "+FLAGS",
# [:Deleted]) unless messages_to_archive.empty?
#
# #$imap.logout
#
# #end
