nodeio = require 'node.io'
fs = require 'fs'
titles = []
regions = []
bankuais = []
output = []
urls = []
i = 0

class Soufang extends nodeio.JobClass
    input: false
    run: ->
        url = 'http://bj.fangjia.com/ershoufang/'
        self = this
        @getHtml url, (err, $, data) =>
            @exit err if err
            $('div.search_list li').each (li) ->
                if $('label', li).text is "区域："
                    $('div.items a', li).each (a) ->
                        url = 'http://bj.fangjia.com/ershoufang/--r-' + encodeURIComponent a.text
                        self.getHtml url, (err, $, data) =>
                            self.exit err if err
                            $('div.search_list li').each (li) ->
                                if $('label', li).text is "板块："
                                    $('div.items a', li).each (a) ->
                                        #console.log a.text
                                        output.push a.text
                                        self.emit output

    output: (lines) ->
        fw_stream = fs.createWriteStream './out'
        new_array = []
        #new_array.push line for line in lines when line not in new_array
        i = i + 1
        @debug 'Writing to FILE'
        @outputStream fw_stream, 'fileout'
        @output.apply this, arguments
        
    fail: (input, err) ->
        console.log err

@class = Soufang
@job = new Soufang({max:1, timeout:100})
#nodeio.start @job
