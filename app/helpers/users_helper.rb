module UsersHelper
  
  def display_user_image(user)
    return image_tag('system_user.png') if user.system?
    return image_tag('empty_user.png') if user.image.nil?
    image_tag(user.image)
  end
  
  def display_user_name(user)
    return 'Carter SMTP Filter' if user.system?
    return user.name if user.name
    ''
  end
  
end
