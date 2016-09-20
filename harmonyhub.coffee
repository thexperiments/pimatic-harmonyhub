# #Plugin template

# This is an plugin template and mini tutorial for creating pimatic plugins. It will explain the 
# basics of how the plugin system works and how a plugin should look like.

# ##The plugin code
# Your plugin must export a single function, that takes one argument and returns a instance of
# your plugin class. The parameter is an environment object containing all pimatic related functions
# and classes. See the [startup.coffee](http://sweetpi.de/pimatic/docs/startup.html) for details.
module.exports = (env) ->

  # ###require modules included in pimatic
  # To require modules that are included in pimatic use `env.require`. For available packages take 
  # a look at the dependencies section in pimatics package.json

  # Require the  bluebird promise library
  Promise = env.require 'bluebird'

  # Include you own dependencies with nodes global require function:
  #  
  #     someThing = require 'someThing'
  #  

  HarmonyHubClient = require 'harmonyhubjs-client'
  HarmonyHubDiscover = require 'harmonyhubjs-discover'

  class HarmonyHub extends env.plugins.Plugin

    # ####init()
    # The `init` function is called by the framework to ask your plugin to initialise.
    #  
    # #####params:
    #  * `app` is the [express] instance the framework is using.
    #  * `framework` the framework itself
    #  * `config` the properties the user specified as config for your plugin in the `plugins` 
    #     section of the config.json file 

    init: (app, @framework, @config) =>
      # get the device config schemas
      deviceConfigDef = require("./device-config-schema")
      env.logger.info("Starting pimatic-harmonyhub plugin")
      env.logger.logDebug = true

      @framework.deviceManager.registerDeviceClass("HarmonyHubPowerSwitch", {
        configDef: deviceConfigDef.HarmonyHubPowerSwitch,
        createCallback: (config, lastState) =>
          return new HarmonyHubPowerSwitch(config, @, lastState)
      })

      @framework.deviceManager.registerDeviceClass("HarmonyHubButtonsDevice", {
        configDef: deviceConfigDef.HarmonyHubButtonsDevice,
        createCallback: (config, lastState) =>
          return new HarmonyHubButtonsDevice(config, @)
      })

      @framework.deviceManager.on 'discover', () =>
        env.logger.debug("Starting discovery")
        @framework.deviceManager.discoverMessage(
          'pimatic-harmonyhub', "Searching for devices"
        )

        @HarmonyHubDiscoverInstance = new HarmonyHubDiscover(61991)
        
        @HarmonyHubDiscoverInstance.on 'online', (hub) =>
          @hubIP = hub.ip
          env.logger.debug("Discovered hub@#{@hubIP}")

          HarmonyHubClient(@hubIP).then (hubInstance) =>
            @hubIP = @hubIP
            env.logger.debug("Getting available commands for hub@#{@hubIP}")
            hubInstance.getAvailableCommands().then (commands) =>
              devices = commands.device
              env.logger.debug("looking for device commands on hub@#{@hubIP}")
              for currentDevice in devices
                controlGroups = currentDevice.controlGroup
                env.logger.debug("looking for control groups on hub@#{@hubIP}")
                for currentControlGroup in controlGroups
                  #create a Buttons device for each ControlGroup
                  deviceFunctions = currentControlGroup.function
                  buttonsArray = []
                  commandType = ""

                  env.logger.debug("found controll group #{currentControlGroup.name} on hub@#{@hubIP}")

                  deviceConfig = 
                    class: "HarmonyHubButtonsDevice"
                    name: "#{currentDevice.label}(#{currentControlGroup.name})"
                    id: "#{currentDevice.label.replace(" ","-")}-#{currentControlGroup.name.replace(" ","-")}"
                    hubIP: @hubIP
                    deviceId: currentDevice.id
                    commandType: ""

                  for currentDeviceFunction in deviceFunctions
                    deviceAction = JSON.parse(currentDeviceFunction.action)
                    #fill the buttons with the different functions
                    buttonConfig = 
                      id : "#{currentDevice.label.replace(" ","-")}-#{currentControlGroup.name.replace(" ","-")}-#{currentDeviceFunction.name.replace(" ","-")}"
                      text : currentDeviceFunction.label
                      command : deviceAction.command
                    buttonsArray.push(buttonConfig)

                    deviceConfig.commandType = deviceAction.type

                  deviceConfig.buttons = buttonsArray

                  #notify about the discovered device
                  @framework.deviceManager.discoveredDevice(
                    'pimatic-harmonyhub', "#{deviceConfig.name}", deviceConfig
                  )

        @HarmonyHubDiscoverInstance.start()

        stopDiscovery = () =>
          @HarmonyHubDiscoverInstance.stop()

        setTimeout stopDiscovery, 20000

    sendHarmonyHubCommand: (hubInstance, command, commandType, deviceId) =>
      @hubInstance = hubInstance
      action = 
        command: command
        type: commandType
        deviceId: "#{deviceId}"

      env.logger.debug("sending command #{JSON.stringify(action)} to #{hubInstance.toString()}")

      @encodedAction = JSON.stringify(action).replace(/\:/g, '::')

      requestPromise = hubInstance.send('holdAction', 'action=' + @encodedAction + ':status=press').then () =>
        @hubInstance.send('holdAction', 'action=' + @encodedAction + ':status=release')

      return requestPromise

    _generateDeviceId: (prefix, lastId = null) ->
      start = 1
      if lastId?
        m = lastId.match /.*-([0-9]+)$/
        start = +m[1] + 1 if m? and m.length is 2
      for x in [start...1000] by 1
        result = "#{prefix}-#{x}"
        matched = @framework.deviceManager.devicesConfig.some (element, iterator) ->
          element.id is result
        return result if not matched

  class HarmonyHubPowerSwitch extends env.devices.PowerSwitch
    #
    constructor: (@config, @plugin, lastState) ->
      @name = @config.name
      @id = @config.id
      @hubIP = @config.hubIP
      @commandType = @config.commandType
      @onCommand = @config.onCommand
      @offCommand = @config.offCommand
      @deviceId = @config.deviceId

      @hubInstance
      HarmonyHubClient(@hubIP).then (hubInstance) =>
        @hubInstance = hubInstance
      super()

    destroy: () ->
      @requestPromise.cancel() if @requestPromise?
      super()

    getState: () ->
      #not currently implemented
      return Promise.resolve @_state

    changeStateTo: (state) ->
      env.logger.debug "setting state to #{state}"
      command = if state then onCommand else offCommand
      @requestPromise = @Plugin.sendHarmonyHubCommand(@hubInstance, command, @commandType, @deviceId).then(() =>
        env.logger.debug "setting state success"
        @_setState(state)
      ).catch((error) =>
        env.logger.error("Unable to set power state of device: " + error.toString())
        #return Promise.reject
      ) 

  class HarmonyHubButtonsDevice extends env.devices.ButtonsDevice
    constructor: (@config, @plugin) ->
      @name = @config.name
      @id = @config.id
      @hubIP = @config.hubIP
      @commandType = @config.commandType
      @buttons = @config.buttons
      @deviceId = @config.deviceId

      @hubInstance
      HarmonyHubClient(@hubIP).then (hubInstance) =>
        @hubInstance = hubInstance

      super(@config)
      

    destroy: () ->
      @requestPromise.cancel() if @requestPromise?
      super()

    buttonPressed: (buttonId) ->

      for b in @config.buttons
        if b.id is buttonId
          @_lastPressedButton = b.id
          @emit 'button', b.id

          command = b.command
          @requestPromise = @plugin.sendHarmonyHubCommand(@hubInstance, command, @commandType, @deviceId).then(() =>
            env.logger.debug "sending command state success"
          ).catch((error) =>
            env.logger.error("Unable to send command to device: " + error.toString())
          )           
          return @requestPromise
      throw new Error("No button with the id #{buttonId} found")
      command = if state then onCommand else offCommand


  # ###Finally
  # Create a instance of my plugin
  myHarmonyHub = new HarmonyHub
  # and return it to the framework.
  return myHarmonyHub