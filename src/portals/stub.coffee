CLI = require('../cli').CLI

exports.Stub = class Stub
   constructor : (rNr) ->
      @RnR = rNr

   server : (request, response) =>
      date = new Date()
      hours = "0#{date.getHours()}".slice -2
      minutes = "0#{date.getMinutes()}".slice -2
      seconds = "0#{date.getSeconds()}".slice -2
      outputMsg = "#{hours}:#{minutes}:#{seconds} -> #{request.method} #{request.headers.host}#{request.url}"

      data = null
      request.on 'data', (chunk) ->
         data = data ? ''
         data += chunk

      request.on 'end', =>
         criteria =
            url : request.url
            method : request.method
            post : data
         success = (rNr) ->
            response.writeHead rNr.status, rNr.headers
            if typeof rNr.body is 'object' then rNr.body = JSON.stringify rNr.body
            response.write rNr.body if rNr.body?
            response.end()
            CLI.success outputMsg
         error = ->
            response.writeHead 500, {}
            CLI.error "#{outputMsg} unexpectedly generated a server error"
            response.end()
         notFound = ->
            response.writeHead 404, {}
            response.end()
            CLI.warn "#{outputMsg} is not a registered endpoint"

         try
            rNr = @RnR.find criteria, success, notFound
         catch e
            error()
