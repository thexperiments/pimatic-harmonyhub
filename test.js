var harmony = require('harmonyhubjs-client');
 
harmony('192.168.42.137')
.then(function(harmonyClient) {
    harmonyClient.getActivities()
    .then(function(activities) {
        activities.some(function(activity) {
            //console.log(activity.label)
            if(activity.label === 'Watch TV') {
                var id = activity.id

                //harmonyClient.startActivity(id)
                //harmonyClient.end()
                return true
            }
            return false
        })
    })

    harmonyClient.getAvailableCommands()
    .then(function(commands) {
        var devices = commands.device
        devices.some(function(device) {
            console.log(device.label)

            var controlGroups = device.controlGroup

            controlGroups.some(function(controlGroup) {
                console.log("    " + controlGroup.name)
                var deviceFunctions = controlGroup.function

                deviceFunctions.some(function(deviceFunction) {
                    var deviceAction = deviceFunction.action.replace(/\//g, "")
                    //var deviceAction = deviceFunction.action.replace(/\:/g, '::')
                    console.log("      +" + deviceFunction.label +"-->"+deviceAction)
                })
            })
        })
        //console.log(JSON.stringify(commands))
    })
})