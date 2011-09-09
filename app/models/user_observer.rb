# This observer is in charge to manage some actions relative to users.
#
class UserObserver < ActiveRecord::Observer 

	# Library included to get the application configuration methods
	include BlankConfiguration

  # Sending Activation Mail to User
  #
  # This method will send signup notification mail if the user activation mandatory,
	#  else it will just activate directly the user.
  #
  # Parameter :
  # - user: User instance
	def after_create(user)
		get_configuration
		
		if is_mandatory_user_activation?
			#QueuedMail.add('UserMailer', 'signup_notification', [user], 0, false)
			QueuedMail.add('UserMailer', 'login_notification', [user.profile.email_address,"Login Notification","The Email Is Just For Login Introduction",user], 0, true,user.profile.email_address,"test@pragtech.co.in")
		else
			user.activate
		end
	end


  # Deliver Reset Notification
  #
  # This method will check the User object after each databse save on it,
	# and so deliver a reset notification if the user have asked a reset request.
	#
	# Parameter :
  # - user: User instance
  def after_save(user)
		QueuedMail.add('UserMailer', 'reset_notification', [user], 0, false) if user.recently_reset?
  end
	
end
