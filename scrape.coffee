nodeio = require 'node.io'
fs = require 'fs'

class Soufang extends nodeio.JobClass
    input: (start, num, callback) ->
        return false if start is not 0
        url = 'http://bj.fangjia.com/ershoufang/'
        @getHtml url, (err, $, data) =>
            @exit err if err
            for li in $('div.search_list li')
                if $('label', li).text is "区域："
                    for a in $('div.items a', li)
                        callback [a.children[0]['data']]
                        #output.push a.children[0]['data']
                    break
            callback null, false
         
    run: (tag) ->
        console.log tag
        url = 'http://bj.fangjia.com/ershoufang/--r-' + encodeURIComponent tag
        output = []
        @getHtml url, (err, $, data) =>
            @exit err if err
            try
                for li in $('div.search_list li')
                    if $('label', li).text is "板块："
                        for a in $('div.items a', li)
                            output.push a.children[0]['data']
                        break
            catch err
                console.log err
            @emit output

    output: './out'
        
    fail: (input, err) ->
        console.log err

@class = Soufang
@job = new Soufang({max:1, timeout:10})
#nodeio.start @job
