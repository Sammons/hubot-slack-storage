# Description:
#  Stores slack conversations for retrieval
#
# Dependencies:
#   "mongodb": ">= 1.2.0"
#
# Configuration:
#   MONGODB_SLACK_USERNAME
#   MONGODB_SLACK_PASSWORD
#   MONGODB_SLACK_HOST
#   MONGODB_SLACK_PORT
#   MONGODB_SLACK_DB
#
# Commands:
#   None
#
# Author:
#   Ben Sammons

Util = require "util"
mongodb = require "mongodb"
Client = mongodb.MongoClient
Collection = mongodb.Collection
Db = mongodb.Db

module.exports = (robot) ->
  user = process.env.MONGODB_SLACK_USERNAME || "admin"
  pass = process.env.MONGODB_SLACK_PASSWORD || "password"
  host = process.env.MONGODB_SLACK_HOST || "localhost"
  port = process.env.MONGODB_SLACK_PORT || "27017"
  dbname = process.env.MONGODB_SLACK_DB || "slack"
  url = ['mongodb://', host, ':', port, '/', dbname].join ''

  error = (err) ->
    robot.logger.info "==SLACK STORAGE UNAVAILABLE=="

  Client.connect url, (err, db) ->
    return error err if err
   
    robot.logger.debug 'Successfully authenticated with mongo'    

    collection = db.collection 'slack_messages'

    getRoomObject = (room) ->
      channels = robot.adapter.client.channels
      groups = robot.adapter.client.groups    
      groupIds = Object.keys groups
      channels = Object.keys channels

    robot.hear /^.*$/, (msg) ->    
      robot.logger.debug msg.message.room
      robot.logger.debug msg.message.id
      robot.logger.debug msg.message.rawMessage.channel
      robot.logger.debug msg.message.user.id
      robot.logger.debug msg.message.user.name
      robot.logger.debug Date.now null
      collection.save {
        "room" : msg.message.room,
        "room_id" : msg.message.rawMessage.channel,
        "user" : msg.message.user.name,
        "user_id" : msg.message.user.id,
        "message_id" : msg.message.id,
        "text" : msg.message.text,
        "timestamp" : Date.now null
      }, (err, res) ->
        return error err if err