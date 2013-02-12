nodeio = require 'node.io'
fs = require 'fs'

output = []
sample_input = {url: "http://bj.fangjia.com/ershoufang/", currpage: 0, seen: true, desc: "首页"}
fw = fs.createWriteStream './output2'

class Soufang extends nodeio.JobClass
    input: false
    run: (input) ->
        type = @options.args[0]
        #sample_url = "http://bj.fangjia.com/#{type}/--r-#{encodeURIComponent "东城"}%7Cb-#{encodeURIComponent "金宝街"}"
        sample_input.url = "http://bj.fangjia.com/#{type}/"
        input = sample_input if input is null
        console.log input
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
            self = this
            @exit err if err
            try
                if curr_page is 0
                    for li in $('div.search_list li')
                        if $('label', li).text is "区域："
                            $('div.items a', li).each (a) ->
                                next_input_instance = new Object
                                next_input_instance.url = "#{url}--r-#{encodeURIComponent a.children[0]['data']}"
                                next_input_instance.currpage = 0
                                next_input_instance.desc = "区域:#{a.children[0]['data']}"
                                next_input_instance.seen = false
                                self.add [next_input_instance]
                        if $('label', li).text is "板块："
                            $('div.items a', li).each (a) ->
                                next_input_instance = new Object
                                next_input_instance_2 = new Object

                                next_input_instance.url = "#{url}%7Cb-#{encodeURIComponent a.children[0]['data']}"
                                next_input_instance.currpage = 1
                                next_input_instance.desc = "#{desc} 板块:#{a.children[0]['data']}"
                                next_input_instance.seen = false
                                self.add [next_input_instance]

                                next_input_instance_2.url = "#{url}%7Cb-#{encodeURIComponent a.children[0]['data']}"
                                next_input_instance_2.currpage = 1
                                next_input_instance_2.desc = "#{desc} 板块:#{a.children[0]['data']}"
                                next_input_instance_2.seen = true
                                self.add [next_input_instance_2]
                else
                    if seen is true
                        next_input = []
                        # Prepare for next page
                        pageinc = $('a[class="next"]', true)
                        if pageinc is false
                            @skip
                        curr_page += 1

                        next_input_instance = new Object
                        next_input_instance_2 = new Object
                                 
                        next_input_instance.url = ori_url
                        next_input_instance.currpage = "#{curr_page}"
                        next_input_instance.desc = desc
                        next_input_instance.seen = false
                        next_input.push next_input_instance

                        next_input_instance_2.url = ori_url
                        next_input_instance_2.currpage = "#{curr_page}"
                        next_input_instance_2.desc = desc
                        next_input_instance_2.seen = true
                        next_input.push next_input_instance_2
                        @add next_input
                    else if seen is false
                        $('li[name="__page_click_area"]').each (li) ->
                            house = []
                            house['url'] = $('a.h_name', li).attribs.href
                            house['desc'] = desc
                            house['title'] = $('span.tit', li).text
                            house['addr'] = $('span.address', li).text
                            house['attribs'] = $('span.attribute', li).text
                            house['price'] = $('span.xq_aprice', li).striptags
                            #console.log house
                            output.push house
                            self.emit house
                        #@emit output
            catch err
                console.log url + err
                @skip
                #@emit output
            @emit output

    #output: './out'
     
    output: (output) ->
        output.forEach (line) ->
            fw.write line

    complete: ->
        fw.close

    fail: (input, err) ->
        console.log err
        @skip

@class = Soufang
@job = new Soufang({max:3, timeout:10})
