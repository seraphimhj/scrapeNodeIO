nodeio = require 'node.io'
fs = require 'fs'

output = []
sample_input = {url: "http://bj.fangjia.com/ershoufang/", currpage: 0, seen: true, desc: "首页"}

class Soufang extends nodeio.JobClass
    input: false
    run: (input) ->
        type = @options.args[0]
        #sample_url = "http://bj.fangjia.com/#{type}/--r-#{encodeURIComponent "东城"}%7Cb-#{encodeURIComponent "金宝街"}"
        sample_input.url = "http://bj.fangjia.com/#{type}/"
        input = sample_input if input is null
        ori_url = input['url']
        curr_page = parseInt input['currpage']
        if curr_page isnt 0
            page_text = "%7Ce-#{curr_page}"
        else
            page_text = ""
        url = "#{ori_url}#{page_text}"
        seen = input['seen']
        desc = input['desc']
        @getHtml url, (err, $, data) =>
            @exit err if err
            try
                if curr_page is 0
                    for li in $('div.search_list li')
                        if $('label', li).text is "区域："
                            next_input = []
                            for a in $('div.items a', li)
                                next_input_instance = new Object
                                next_input_instance.url = "#{url}--r-#{encodeURIComponent a.children[0]['data']}"
                                next_input_instance.currpage = 0
                                next_input_instance.desc = "区域:#{a.children[0]['data']}"
                                next_input.push next_input_instance
                            console.log next_input
                            @add next_input
                        if $('label', li).text is "板块："
                            next_input = []
                            for a in $('div.items a', li)
                                next_input_instance = new Object
                                next_input_instance.url = "#{url}%7Cb-#{encodeURIComponent a.children[0]['data']}"
                                next_input_instance.currpage = 1
                                next_input_instance.desc = "#{desc} 板块:#{a.children[0]['data']}"
                                next_input.push next_input_instance
                            console.log next_input
                            @add next_input
                else
                    $('li[name="__page_click_area"]').each (li) ->
                        house = []
                        house['url'] = $('a.h_name', li).attribs.href
                        house['desc'] = desc
                        house['title'] = $('span.tit', li).text
                        house['addr'] = $('span.address', li).text
                        house['attribs'] = $('span.attribute', li).text
                        house['price'] = $('span.xq_aprice', li).striptags
                        console.log house
                        output.push house
                    #output.push "#{desc} #{$('div#flashChartFragment').striptags}"
                    # Prepare for next page
                    try
                        pageinc = $('a[class="next"]')
                        curr_page += 1
                        next_input_instance = new Object
                        next_input_instance.url = ori_url
                        next_input_instance.currpage = "#{curr_page}"
                        next_input_instance.desc = desc
                        @add [next_input_instance]
                    catch err
                        console.log err
                        #@emit output
            catch err
                console.log err
                @emit output
            @emit output

    #output: './out'
     
    output: (output) ->
        output.forEach (line) ->
            console.log line

    complete: ->
        #console.log output
        fw = fs.createWriteStream './output2'
        output.forEach (line) ->
            fw.write line
        fw.close

    fail: (input, err) ->
        console.log err
        @skip

@class = Soufang
@job = new Soufang({max:3, timeout:10})
