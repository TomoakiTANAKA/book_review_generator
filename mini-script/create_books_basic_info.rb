# 書籍APIを使った書評の雛形作成
# 参考：https://openbd.jp/
# 使い方
# ruby create_books_basic_info.rb 4827209324
require 'net/http'
require 'uri'
require 'json'
require 'erb'

class CreateBooksBasicInfo
  END_POINT = "https://api.openbd.jp/v1/get".freeze

  def initialize(isbn)
    @isbn = isbn
  end

  def get_book_info
    url = END_POINT + "?isbn=#{@isbn}"
    uri = URI.parse(url)
    res = Net::HTTP.get_response(uri)
    
    hash = JSON.parse(res.body)
    json_book = hash[0]

    book_info = {
        # for debug
        # "text_content": json_book["onix"]["CollateralDetail"]["TextContent"],
        # "description": json_book["onix"]["DescriptiveDetail"],
        # === onix ===
        "toc": json_book["onix"]["CollateralDetail"]["TextContent"][1]["Text"],
        "page": json_book["onix"]["DescriptiveDetail"]["Extent"][0]["ExtentValue"],
        # === sumamry ===
        "isbn": json_book["summary"]["isbn"],
        "title": json_book["summary"]["title"],
        "publisher": json_book["summary"]["publisher"],
        "pubdate": json_book["summary"]["pubdate"],
        "author": json_book["summary"]["author"],
    }
  end
end

if __FILE__ == $0
  isbn = ARGV[0].to_i
  obj = CreateBooksBasicInfo.new(isbn)
  book_info = obj.get_book_info

  # for-debug
  # pp book_info

  erb = File.open("./template.html.erb").read
  puts ERB.new(erb).result(binding)
end
