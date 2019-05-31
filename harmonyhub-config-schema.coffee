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
    scanforpowerswitches:
      description: "Autodiscover all PowerSwitches"
      type: "boolean"
      default: true
    scanforbuttonsdevices:
      description: "Autodiscover all ButtonsDevices"
      type: "boolean"
      default: true
    scanforactivitybuttonsdevices:
      description: "Autodiscover all ActivitiesButtonsDevices"
      type: "boolean"
      default: true
    scanforactivitiespresencedevices:
      description: "Autodiscover all ActivitiesPresence"
      type: "boolean"
      default: true
}