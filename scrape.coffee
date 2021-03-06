nodeio = require 'node.io'
fs = require 'fs'
                    
search_desc = []
search_url = []
                    
output = []
i = 0
sample_input = url: "http://bj.fangjia.com/ershoufang/", currpage: 0, desc: "首页"
if_use = ["区域：": true, "地铁：": true, "面积：": true, "总价：": true, "房型：": false, "楼层：": false, "类型：": false, "标签：": false]
#select_search = 

class Soufang extends nodeio.JobClass
    input: false
    run: (input) ->
        type = @options.args[0]
        # For test
        #sample_input.url = "http://bj.fangjia.com/#{type}/--r-#{encodeURIComponent "东城"}%7Cb-#{encodeURIComponent "金宝街"}"
        #sample_input.currpage = 1
        sample_input.url = "http://bj.fangjia.com/#{type}/"
        input = sample_input if input is null
        console.log input
        ori_url = input['url']
        curr_page = parseInt input['currpage']
        if curr_page isnt 0
            page_text = "|e-#{curr_page}"
        else
            page_text = ""
        url = "#{ori_url}#{page_text}"
        @debug url
        desc = input['desc']
        @getHtml url, (err, $, data) =>
            self = this
            @exit err if err
            try
                if curr_page is 0
                    next_input = []
                    #search_desc = []
                    #search_url = []
                    $('div.search_list li').each (li) ->
                        desc = $('label', li).text
                        console.log "#{encodeURIComponent "|"} #{desc}"
                        search_desc[desc] = []
                        search_url[desc] = []
                        $('div.items a', li).each (a) ->
                            search_desc[desc].push a.children[0]['data']
                            url = a.attribs.href.split "--", 2
                            search_url[desc].push url[1]
                        console.log search_desc[desc]
                        console.log search_url[desc]
                        #for flag, desc in if_use
                        #    if flag
                        #        next_input = next_input search_url for j in search_url
                        #        first_true = i if first_true isnt 0
                        #        for url_in, j in next_input
                        #            next_input = "#{next_input[j]}#{encodeURIComponent "|"}#{url_part}" for url_part in search_url[desc]
                        #            desc_input = "

                        ###
                            next_input_instance = new Object
                            next_input_instance.url = "#{url}--r-#{encodeURIComponent a.children[0]['data']}"
                            next_input_instance.currpage = 0
                            next_input_instance.desc = "区域:#{a.children[0]['data']}"
                            next_input.add [next_input_instance]
                    if $('label', $('div.search_list li')).text is "板块："
                        $('div.items a', $('div.search_list li')).each (a) ->
                            next_input_instance = new Object
                            next_input_instance.url = "#{url}%7Cb-#{encodeURIComponent a.children[0]['data']}"
                            next_input_instance.currpage = 1
                            next_input_instance.desc = "#{desc} 板块:#{a.children[0]['data']}"
                            self.add [next_input_instance]
                        ###
                else
                    for li in $('li[name="__page_click_area"]')
                        house = []
                        house['url'] = $('a.h_name', li).attribs.href
                        house['desc'] = desc
                        house['title'] = $('span.tit', li).text
                        house['addr'] = $('span.address', li).text
                        house['attribs'] = $('span.attribute', li).text
                        house['price'] = $('span.xq_aprice', li).striptags
                        house['price'] = house['price'].replace "\n", ""
                        #console.log house
                        output.push house

                    # Prepare for next page
                    pageinc = $('a[class="next"]')
                    curr_page += 1

                    next_input_instance = new Object
                    next_input_instance.url = ori_url
                    next_input_instance.currpage = "#{curr_page}"
                    next_input_instance.desc = desc
                    @add [next_input_instance]
            catch err
                console.log url + " " + err
                @skip
            @emit output

    output: './out'
     
    complete: ->
        type = @options.args[0]
        fw = fs.createWriteStream "./#{type}_output"
        #for house in output
        #    fw.write "#{house['desc']} #{house['title']} #{house['price']} #{house['addr']} #{house['attribs']} #{house['url']}"
        #    fw.write "\n\n"
        for desc, list of search_desc
            fw.write "#{desc}\n#{list}\n"
        fw.close

    fail: (input, err) ->
        console.log err
        @skip

@class = Soufang
@job = new Soufang({max:3, timeout:10})
