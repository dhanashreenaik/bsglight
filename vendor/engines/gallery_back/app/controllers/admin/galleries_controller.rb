# This controller is managing the different actions relative to the Image item.
#
# It is using a mixin function called 'acts_as_item' from the ActsAsItem::ControllerMethods::ClassMethods,
# so see the documentation of that module for further informations.
#
class Admin::GalleriesController < Admin::ApplicationController

	# Method defined in the ActsAsItem:ControllerMethods:ClassMethods (see that library fro more information)
	acts_as_item

end