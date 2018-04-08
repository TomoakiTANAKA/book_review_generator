# QiitaのAPIを利用して、指定したタグの記事をcsvに吐き出すスクリプト
# APIの返り値 : 
# 利用制限 : https://qiita.com/api/v2/docs#%E5%88%A9%E7%94%A8%E5%88%B6%E9%99%90

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
        "table-of-content": json_book["onix"]["CollateralDetail"]["TextContent"][1]["Text"],
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
  # API叩く
  isbn = 4806134325
  obj = CreateBooksBasicInfo.new(isbn)
  book_info = obj.get_book_info

  pp book_info

  erb = File.open("./template.html.erb").read
  puts ERB.new(erb).result(binding)
end
