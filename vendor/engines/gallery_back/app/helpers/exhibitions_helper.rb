module ExhibitionsHelper

	def exhibition_in_array(exhib)
		users = exhib.exhibitions_users
		return link_to(exhib, item_path(exhib))+"(#{users.size},
			#{users.delete_if{ |e| e.state != 'invited'}.size},
			#{users.delete_if{ |e| e.state != 'refused'}.size},
			#{users.delete_if{ |e| e.state != 'accepted'}.size},
			#{users.delete_if{ |e| e.state != 'validated'}.size}
		)"
	end

end
