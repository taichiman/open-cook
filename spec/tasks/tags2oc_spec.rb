require "spec_helper"
require "#{Rails.root}/lib/tasks/includes/helpers.rb"
require "#{Rails.root}/lib/tasks/includes/connect_ae_db.rb"

describe "Compare" do
  # before(:each) do
  #   UsersMacros.create_admin
  #   @post = PostsMacros.create_post_for(User.root)
  #   Comment.delete_all
  # end

  # it "Articles count should be equal" do
  #   result = compare_articles_quantity Post, Post
  #   result.should == 0
  # end

  # it "Articles count should not be equal" do
  #   result = compare_articles_quantity Post, Comment
  #   result.should == [1,0]
  # end
end

describe "Article Tags trans" do
  before(:each) do
    UsersMacros.create_admin
    @post = PostsMacros.create_post_for(User.root)
    # puts "!! taggble?: #{ Post.taggable? }"
    # @post.name_list="denis, dima"
    # puts "!!! from spec: @post #{ap @post}"
    # puts "!!! from spec: names: #{ap @post.name_list}"
  end
  
  it "should can trans tag" do
    old_article = AE_Article.find 13
    new_article = @post
    create_tags old_article, new_article
    # create_tags old_article, new_article.id
    new_article.reload
    puts "in spec: new_article name_list #{ap new_article}"

    ["Артур Кларк", "Рихард Штраус", "Стэнли Кубрик"].should  == new_article.name_list
    # old_article.word_list.should  == new_article.word_list
    # old_article.title_list.should == new_article.title_list

  end

end

# просто делает запрос к базе, тестируя sql запрос
describe "Old base tags"do
  it "test sql query " do
    sql="select name from tags inner join taggings on tags.id = taggings.tag_id where taggable_id = 13 and taggable_type='Article' and context='names'"
    result = AE_FullDatabase.connection.execute(sql)
    
    puts result.inspect

    result.each do |row| 
      puts row
    end 

    # puts record_array.inspect
    1.should == 1
  end

  # проверяет как работает helper получения тегов из старой базы, так как там другя версия гема acts_as_aggable-on и по другому получить теги я не получится
  it "should good transform old tags to hash" do
    result = get_tags_by_context AE_Article.find(13), :names, :titles, :words
    result[:names].should eq ["Артур Кларк", "Рихард Штраус", "Стэнли Кубрик"]
    result[:titles].should eq ["Путешествие на Луну", "Доктор Стрейнджлав", "Широко закрытые глаза", "2001.Космическая Одиссея"]
    result[:words].should eq ["Космос", "Кино", "Science Fiction"]
  end
end