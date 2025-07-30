module UsersHelper
  def gravatar_for user
    gravatar_id = Digest::MD5.hexdigest user.email.downcase
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}"
    image_tag gravatar_url, alt: user.name, class: "gravatar"
  end

  def gender_options
    User.genders.keys.map do |gender|
      [t("activerecord.attributes.user.genders.#{gender}"), gender]
    end
  end
end
