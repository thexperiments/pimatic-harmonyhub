# #pimatic-tplink-smartplug configuration options
module.exports = {
  title: "Harmony Hub options"
  type: "object"
  properties: 
    keepalive:
      description: "Default keepalive interval (ms) (currently not used)"
      type: "integer"
      default: 30000
    debug:
      description: "Flag for activating debug output"
      type: "boolean"
      default: false
}