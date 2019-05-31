module.exports = {
  title: "pimatic-harmonyhub device config schema"
  HarmonyHubPowerSwitch: {
    title: "HarmonyHubPowerSwitch config options"
    type: "object"
    properties:
      hubIP:
        description: "IP of the Harmony Hub"
        type: "string"
      activityId:
        description: "id of the harmony activity"
        type: "string"
  },
  HarmonyHubButtonsDevice: {
    title: "HarmonyHubButtonsDevice config options"
    type: "object"
    properties:
      hubIP:
        description: "IP of the Harmony Hub"
        type: "string"
      deviceId:
        description: "ID of device to control"
        type: "number"
      commandType:
        description: "Type of code to send (IRCommand etc.)"
        type: "string"
        default: "IRCommand"
      buttons:
        description: "Buttons to display"
        type: "array"
        default: []
        format: "table"
        items:
          type: "object"
          properties:
            id:
              type: "string"
            text:
              type: "string"
            command:
              description: "Command to send"
              type: "string"
  },
  HarmonyHubActivitiesButtonsDevice: {
    title: "HarmonyHubActivitiesButtonsDevice config options"
    type: "object"
    properties:
      hubIP:
        description: "IP of the Harmony Hub"
        type: "string"
      buttons:
        description: "Activitiy buttons to display"
        type: "array"
        default: []
        format: "table"
        items:
          type: "object"
          properties:
            id:
              type: "string"
            text:
              type: "string"
            activityId:
              description: "ID of the activity to trigger (-1 = off)"
              type: "string"
  },
  HarmonyHubActivitiesPresenceDevice: {
    title: "HarmonyHubActivitiesPresenceDevice config options"
    type: "object"
    properties:
      hubIP:
        description: "IP of the Harmony Hub"
        type: "string"
      activities:
        description: "Activities to look for"
        type: "array"
        default: []
        format: "table"
        items:
          type: "object"
          properties:
            id:
              type: "string"
            text:
              type: "string"
            activityId:
              description: "Activitiy to watch"
              type: "string"
      ignoredActivities:
        description: "Activities that have no influence on presence state"
        type: "array"
        default: []
        format: "table"
        items:
          type: "object"
          properties:
            id:
              type: "string"
            text:
              type: "string"
            activityId:
              description: "Activitiy to ignore"
              type: "string"
  }
}
