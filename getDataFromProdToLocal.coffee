fs = require('fs')
exec = require('child_process').exec
meteorUrl = process.argv[2]
exec "meteor mongo -U #{meteorUrl}", (error, stdoutMeteorMongo, stderr) ->
  # sample: mongodb://client-d07d18qe:7795a6dc-3e1a-a4fe-ab3f-e632basd1e44d@production-db-c12.meteor.io:27017/example_meteor_com
  [f, user, pass, host, db] = stdoutMeteorMongo.match /mongodb:\/\/(\S*?):(\S*?)@(\S*?)\/(\S*)/
  mongoExportCommand = "mongoexport -u #{user} -p #{pass} -h #{host} -d #{db} -c families --jsonArray"
  console.log mongoExportCommand
  exec mongoExportCommand, (error, stdoutMongoExport, stderr) ->
    console.log stdoutMongoExport
    exportFile = "families.json"
    fs.writeFile exportFile, stdoutMongoExport, (e) ->
      if e
        throw e
      else
        mongoImportCommand = "mongoimport --jsonArray < #{exportFile}"