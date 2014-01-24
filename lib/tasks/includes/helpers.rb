# helpers
def create_hub_category category
  user_root = User.root
  slug = make_slug category

  hub_category = Hub.new(
    title: category.title,
    slug: slug,
    keywords: category.meta_keywords,
    description: category.meta_description.to_s[0..250],
    state: :published,
    user: user_root,
    legacy_url: make_legacy_url_for_hub(category)
  )
  hub_category
end

def make_legacy_url_for_hub category
  legacy_url = if category.try(:category_id)
    parent_cat = AE_Category.find category.category_id
    "#{parent_cat.slug}/#{category.slug}"
  else
    "#{category.slug}"
  end
end

def find_ae_category category
  AE_Category.find category.id
end

def find_ae_subcategory category
  AE_Subcategory.find category.category_id
end

def find_parent_category category
  ae_category = (category.try(:category_id))? find_ae_subcategory(category) : find_ae_category(category)

  hub_category = Hub.find_by_slug ae_category.slug
  hub_category
end

def check_slug category
  hub = Hub.find_by_slug category.slug
  hub.present?
end

def make_slug category
  if check_slug category
    parent_hub_category = find_parent_category category
    if parent_hub_category.present?
      "#{parent_hub_category.slug}-#{category.slug}"
    else
      salt = (0..8).map { (65 + rand(26)).chr }.join
      "#{salt}-#{category.slug}"
    end
  else
    category.slug
  end
end

def find_user node
  begin
    return_user node
  rescue
    User.root
  end
end

def return_user node
  ae_user = AE_User.find node.user_id
  user = User.where('username = ?', ae_user.nick)
  user.first
end

def create_comment node, parent = nil
  print '*'

  user = find_user node
  obj = return_obj_for_comment node

  if obj
    root_comment = obj.comments.create!(
      user:        user,
      commentable: obj,
      raw_content: node.text,
      referer:     node.referer,
      user_agent:  node.user_agent,
      ip:          node.ip,
      parent_id:   parent.try(:id)
    )

    children = return_children_comment node
    children.each {|comment| create_comment comment, root_comment} if children.present?
  end
end

def return_blog id
  begin
    blog = AE_Blog.find id
    return Post.find_by_title blog.name
  rescue ActiveRecord::RecordNotFound
    return false
  end
end

def return_article id
  begin
    article = AE_Article.find id
    return Post.find_by_title article.title
  rescue ActiveRecord::RecordNotFound
    return false
  end
end

def return_obj_for_comment comment
  obj = case comment.commentable_type
    when 'Blog' then return_blog comment.commentable_id
    when 'Article' then return_article comment.commentable_id
  end
end

def return_children_comment comment
  AE_Comment.where('parent_id = ?', comment.id)
end

def return_obj_for_storage node
  obj = case node.storage_type
    when 'Blog' then return_blog node.storage_id
    when 'Article' then return_article node.storage_id
  end
end

def create_attached_files node, old_file
  user = find_user node
  obj  = return_obj_for_storage node

  if obj && File.exists?(old_file)
    obj.attached_files.create(
      user: user,
      attachment: File.open(old_file)
    )
  else
    puts old_file.to_s.red
  end
end

def create_main_image_file obj, old_file
  if File.exists?(old_file)
    obj.main_image(main_image: File.open(old_file))
    print '(f*)' if obj.save
  else
    puts old_file.to_s.yellow
  end
end

def puts_error obj, index, obj_count
  puts ''
  puts "#{obj.errors.to_a.to_s.red} => #{index+1}/#{obj_count}"
  puts ''
end

def create_blog node, hub
  user = find_user node

  blog = Post.new(
    title: node.name,
    raw_intro: node.body,
    raw_content: node.body,
    hub: hub,
    user: user,
    legacy_url: "blogs/#{node.id}"
  )
  blog
end

def create_post node
  user = find_user node
  article_category_slug = make_legacy_url_for_hub(AE_Subcategory.find(node.subcategory_id))
  hub = find_parent_category AE_Subcategory.find node.subcategory_id 

  post = Post.new(
    user: user,
    hub: hub,
    keywords: node.meta_keywords,
    description: node.meta_description.to_s[0..250],
    title: node.title,
    raw_intro: node.description,
    raw_content: node.body,
    state: node.state,
    legacy_url: "#{article_category_slug}/#{node.id}"
  )
  post
end

def create_tags old_article, new_article
  tags = get_tags_by_context old_article, :names, :titles, :words
  new_article.name_list  = "foo, bar, zoo"
  # new_article.name_list  = tags[:names ].join ','
  # new_article.title_list = tags[:titles].join ','
  # new_article.word_list  = tags[:words ].join ','
  if new_article.save
    puts '*'
    puts "in create tags: save: #{Post.find( new_article.id).name_list}"
  else
    puts_error old_article
  end
end

def get_tags_by_context old_article, *contexts
  tags = {}
  contexts.each do | context |
    tags[ context ] = []
    result = AE_FullDatabase.connection.execute "select name from tags inner join taggings on tags.id = taggings.tag_id where taggable_id = #{old_article.id} and taggable_type='Article' and context='#{ context.to_s }'"
    result.each(as: :array)  do | row |
      tags[ context ]+= row
    end
  end
  # puts "!! Hello #{ tags }"
  tags
end

# def create_tag tag
#   tag = ActsAsTaggableOn::Tag.new(
#     id: tag.id,
#     name: tag.name
#   )
#   tag
# end

# def create_tagging tagging
#   tagging = ActsAsTaggableOn::Tagging.new(
#     id:            tagging.id,
#     tag_id:        tagging.tag_id,
#     taggable_id:   tagging.taggable_id,
#     taggable_type: tagging.taggable_type,
#     tagger_id:     tagging.tagger_id,
#     tagger_type:   tagging.tagger_type,
#     context:       tagging.context,
#     created_at:    tagging.created_at
#   )

#   tagging.taggable_type = 'Post' if tagging.taggable_type == 'Article'

#   tagging
# end

# def compare_article art_old, art_new 
#     # art_old.user        = art_new.user,
#     # art_old.hub         = art_new.hub,
#     # art_old.keywords    = art_new.meta_keywords,
#     # art_old.description = art_new.meta_description.to_s[0..250],
#     # art_old.title       = art_new.title,
#     # art_old.raw_intro   = art_new.description,
#     # art_old.raw_content = art_new.body,
#     # art_old.state       = art_new.state,
#     # ???art_old.legacy_url  = art_new"#{article_category_slug}/#{node.id}"
#     0
# end

# def compare_articles_quantity old_articles, new_articles
#   old_count = old_articles.count; new_count = new_articles.count
#   if old_count == new_count
#     0
#   else
#     [old_count, new_count]
#   end
# end
