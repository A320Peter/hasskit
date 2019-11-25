import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/WebSocket.dart';

enum EntityType {
  lightSwitches,
  climateFans,
  cameras,
  mediaPlayers,
  group,
  accessories,
  scriptAutomation,
}

class Entity {
  final String entityId;
  String deviceClass;
  String friendlyName;
  String icon;
  String state;
  //climate
  List<String> hvacModes;
  double minTemp;
  double maxTemp;
  double targetTempStep;
  double currentTemperature;
  double temperature;
  String fanMode;
  List<String> fanModes;
  String lastOnOperation;
  int deviceCode;
  String manufacturer;
//Fan
  List<String> speedList;
  bool oscillating;
  String speedLevel;
  String speed;
  int angle;
  int directSpeed;
  //Light
  int supportedFeatures;
  int brightness;
  List<int> rgbColor;
  int minMireds;
  int maxMireds;
  int colorTemp;
  //cover
  double currentPosition;
  //input_number
  double initial;
  double min;
  double max;
  double step;
  //media_player
  double volumeLevel;
  bool isVolumeMuted;
  String mediaContentType;
  String mediaTitle;
  String source;
  List<String> sourceList;
  String soundMode;
  List<String> soundModeList;
  String soundModeRaw;

  Entity({
    this.entityId,
    this.deviceClass,
    this.friendlyName,
    this.icon,
    this.state,
    //climate
    this.hvacModes,
    this.minTemp,
    this.maxTemp,
    this.targetTempStep,
    this.currentTemperature,
    this.temperature,
    this.fanMode,
    this.fanModes,
    this.deviceCode,
    this.manufacturer,
    //fan
    this.speedList,
    this.oscillating,
    this.speedLevel,
    this.speed,
    this.angle,
    this.directSpeed,
    //light
    this.supportedFeatures,
    this.brightness,
    this.rgbColor,
    this.minMireds,
    this.maxMireds,
    this.colorTemp,
    //cover
    this.currentPosition,
    //intput_number
    this.initial,
    this.min,
    this.max,
    this.step,
//    media_player
    this.volumeLevel,
    this.isVolumeMuted,
    this.mediaContentType,
    this.mediaTitle,
    this.source,
    this.sourceList,
    this.soundMode,
    this.soundModeList,
    this.soundModeRaw,
  });

  factory Entity.fromJson(Map<String, dynamic> json) {
    try {
      if (json['entity_id'] == null) {
        return null;
      }
      return Entity(
        entityId: json['entity_id'],
        deviceClass: json['attributes']['device_class'],
        icon: json['attributes']['icon'],
        friendlyName: json['attributes']['friendly_name'] != null
            ? json['attributes']['friendly_name']
            : json['entity_id'],
        state: json['state'],
        //climate
        hvacModes: json['attributes']['hvac_modes'] != null
            ? List<String>.from(json['attributes']['hvac_modes'])
            : [],
        minTemp: double.tryParse(json['attributes']['min_temp'].toString()),
        maxTemp: double.tryParse(json['attributes']['max_temp'].toString()),
        targetTempStep:
            double.tryParse(json['attributes']['target_temp_step'].toString()),
        temperature:
            double.tryParse(json['attributes']['temperature'].toString()),

        currentTemperature: double.tryParse(
            json['attributes']['current_temperature'].toString()),
        fanMode: json['attributes']['fan_mode'],
        fanModes: json['attributes']['fan_modes'] != null
            ? List<String>.from(json['attributes']['fan_modes'])
            : [],
        deviceCode: json['attributes']['device_code'],
        manufacturer: json['attributes']['manufacturer'],
        //fan
        speedList: json['attributes']['speed_list'] != null
            ? List<String>.from(json['attributes']['speed_list'])
            : [],
        oscillating: json['attributes']['oscillating'],
        speedLevel: json['attributes']['speed_level'],
        speed: json['attributes']['speed'].toString(),
        angle: json['attributes']['angle'],
        directSpeed: json['attributes']['direct_speed'],
        supportedFeatures: json['attributes']['supported_features'],
        brightness: int.tryParse(json['attributes']['brightness'].toString()),
        rgbColor: json['attributes']['rgb_color'] != null
            ? List<int>.from(json['attributes']['rgb_color'])
            : [],
        minMireds: int.tryParse(json['attributes']['min_mireds'].toString()),
        maxMireds: int.tryParse(json['attributes']['max_mireds'].toString()),
        colorTemp: int.tryParse(json['attributes']['color_temp'].toString()),
        currentPosition:
            double.tryParse(json['attributes']['current_position'].toString()),
        //input_number
        initial: double.tryParse(json['attributes']['initial'].toString()),
        min: double.tryParse(json['attributes']['min'].toString()),
        max: double.tryParse(json['attributes']['max'].toString()),
        step: double.tryParse(json['attributes']['step'].toString()),
        //media_player
        volumeLevel:
            double.tryParse(json['attributes']['volume_level'].toString()),
        isVolumeMuted: json['attributes']['is_volume_muted'],
        mediaContentType: json['attributes']['media_content_type'].toString(),
        mediaTitle: json['attributes']['media_title'].toString(),
        source: json['attributes']['source'].toString(),
        sourceList: json['attributes']['source_list'] != null
            ? List<String>.from(json['attributes']['source_list'])
            : [],
        soundMode: json['attributes']['sound_mode'].toString(),
        soundModeList: json['attributes']['sound_mode_list'] != null
            ? List<String>.from(json['attributes']['sound_mode_list'])
            : [],
        soundModeRaw: json['attributes']['sound_mode_raw'].toString(),
      );
    } catch (e) {
      log.e("Entity.fromJson newEntity $e");
      log.e("json $json");
      return null;
    }
  }

  toggleState() {
    var domain = entityId.split('.').first;
    if (domain == "group") domain = "homeassistant";
    var service = '';
    if (state == 'on' ||
        this.state == 'turning on...' ||
        domain == 'climate' && state != 'off') {
      this.state = 'turning off...';
      service = 'turn_off';
    } else if (state == 'off' || state == 'turning off...') {
      this.state = 'turning on...';
      service = 'turn_on';
    } else if (state == 'open' || state == 'opening...') {
      this.state = 'closing...';
      service = 'close_cover';
    } else if (state == 'closed' || state == 'closing...') {
      this.state = 'opening...';
      service = 'open_cover';
    } else if (state == 'locked' || state == 'locking...') {
      this.state = 'unlocking...';
      domain = "lock";
      service = 'unlock';
    } else if (state == 'unlocked' || state == 'unlocking...') {
      this.state = 'locking...';
      domain = "lock";
      service = 'lock';
    } else if (domain == "scene") {
      service = 'turn_on';
    }

    var outMsg = {
      "id": gd.socketId,
      "type": "call_service",
      "domain": domain,
      "service": service,
      "service_data": {"entity_id": entityId}
    };

    var message = json.encode(outMsg);
    webSocket.send(message);
  }

  EntityType get entityType {
    if (entityId.contains('fan.') || entityId.contains('climate.')) {
      return EntityType.climateFans;
    } else if (entityId.contains('camera.')) {
      return EntityType.cameras;
    } else if (entityId.contains('media_player.')) {
      return EntityType.mediaPlayers;
    } else if (entityId.contains('group.')) {
      return EntityType.group;
    } else if (entityId.contains('script.') ||
        entityId.contains('automation.') ||
        entityId.contains('scene.')) {
      return EntityType.scriptAutomation;
    } else if (entityId.contains('light.') ||
        entityId.contains('switch.') ||
        entityId.contains('cover.') ||
        entityId.contains('input_boolean.') ||
        entityId.contains('lock.') ||
        entityId.contains('vacuum.')) {
      return EntityType.lightSwitches;
    } else {
      return EntityType.accessories;
    }
  }

  int get fanModeIndex {
    return fanModes.indexOf(fanMode);
  }

  int get hvacModeIndex {
    return hvacModes.indexOf(state);
  }

  IconData get mdiIcon {
    return gd.mdiIcon(getDefaultIcon);
  }

  String get getOverrideIcon {
    if (gd.entitiesOverride[entityId] != null &&
        gd.entitiesOverride[entityId].icon != null &&
        gd.entitiesOverride[entityId].icon.length > 0) {
      return gd.entitiesOverride[entityId].icon;
    }
    return "";
  }

  String get getDefaultIcon {
    if (gd.entitiesOverride[entityId] != null &&
        gd.entitiesOverride[entityId].icon != null &&
        gd.entitiesOverride[entityId].icon.length > 0) {
      return getOverrideStateString(gd.entitiesOverride[entityId].icon);
    }

    if (!["", null].contains(icon)) {
      return getOverrideStateString(icon);
    }

    var deviceClass = entityId.split('.')[0];
    var deviceName = entityId.split('.')[1];

    if ([null, ''].contains(deviceClass) || [null, ''].contains(deviceName)) {
      return 'mdi:help-circle';
    }

    if (gd.classDefaultIcon(deviceClass) != "") {
      return '${getOverrideStateString(gd.classDefaultIcon(deviceClass))}';
    }

    if (deviceName.contains('automation')) {
      return 'mdi:home-automation';
    }

    if (deviceName.contains('cover')) {
      return isStateOn ? 'mdi:garage-open' : 'mdi:garage';
    }

    if (deviceName.contains('device')) {
      return 'mdi:tablet-cellphone';
    }
    if (deviceName.contains('door_window')) {
      return isStateOn ? 'mdi:window-closed' : 'mdi:window-open';
    }

    if (deviceName.contains('fan')) {
      return isStateOn ? 'mdi:fan' : 'mdi:fan-off';
    }

    if (deviceName.contains('illumination')) {
      return 'mdi:brightness-4';
    }

    if (deviceName.contains('humidity')) {
      return 'mdi:water-percent';
    }

    if (deviceName.contains('light')) {
      return isStateOn ? 'mdi:lightbulb-on' : 'mdi:lightbulb';
    }

    if (deviceName.contains('lock')) {
      return isStateOn ? 'mdi:lock-open' : 'mdi:lock';
    }

    if (deviceName.contains('motion')) {
      return isStateOn ? 'mdi:run' : 'mdi:walk';
    }

    if (deviceName.contains('pressure')) {
      return 'mdi:gauge';
    }

    if (deviceName.contains('remote')) {
      return 'mdi:remote';
    }

    if (deviceName.contains('script')) {
      return 'mdi:script-text';
    }
    if (deviceName.contains('smoke')) {
      return 'mdi:fire';
    }
    if (deviceName.contains('temperature')) {
      return 'mdi:thermometer';
    }
    if (deviceName.contains('time')) {
      return 'mdi:clock';
    }
    if (deviceName.contains('switch')) {
      return 'mdi:toggle-switch';
    }
    if (deviceName.contains('vacuum')) {
      return 'mdi:robot-vacuum';
    }
    if (deviceName.contains('water_leak')) {
      return 'mdi:water-off';
    }
    if (deviceName.contains('water')) {
      return 'mdi:water';
    }
    if (deviceName.contains('yr_symbol')) {
      return 'mdi:weather-partlycloudy';
    }

    return 'mdi:help-circle';
  }

  String getOverrideStateString(String normalState) {
    if (isStateOn && normalState == "mdi:bell") return "mdi:bell-ring";
    if (!isStateOn && normalState == "mdi:bell-ring") return "mdi:bell";

    if (isStateOn && normalState == "mdi:blinds") return "mdi:blinds-open";
    if (!isStateOn && normalState == "mdi:blinds-open") return "mdi:blinds";

    if (isStateOn && normalState == "mdi:door-closed") return "mdi:door-open";
    if (!isStateOn && normalState == "mdi:door-open") return "mdi:door-closed";

    if (isStateOn && normalState == "mdi:fan-off") return "mdi:fan";
    if (!isStateOn && normalState == "mdi:fan") return "mdi:fan-off";

    if (isStateOn && normalState == "mdi:garage") return "mdi:garage-open";
    if (!isStateOn && normalState == "mdi:garage-open") return "mdi:garage";

    if (isStateOn && normalState == "mdi:lightbulb") return "mdi:lightbulb-on";
    if (!isStateOn && normalState == "mdi:lightbulb-on") return "mdi:lightbulb";

    if (isStateOn && normalState == "mdi:lightbulb-outline")
      return "mdi:lightbulb-on-outline";
    if (!isStateOn && normalState == "mdi:lightbulb-on-outline")
      return "mdi:lightbulb-outline";

    if (isStateOn && normalState == "mdi:lock") return "mdi:lock-open";
    if (!isStateOn && normalState == "mdi:lock-open") return "mdi:lock";
    if (isStateOn && normalState == "mdi:window-closed")
      return "mdi:window-open";
    if (!isStateOn && normalState == "mdi:window-open")
      return "mdi:window-closed";
    if (isStateOn && normalState == "mdi:walk") return "mdi:run";
    if (!isStateOn && normalState == "mdi:run") return "mdi:walk";

    if (isStateOn && normalState == "mdi:window-shutter")
      return "mdi:window-shutter-open";
    if (!isStateOn && normalState == "mdi:window-shutter-open")
      return "mdi:window-shutter";

    return normalState;
  }

  bool get isStateOn {
    var stateLower = state.toLowerCase();
    if ([
      'on',
      'turning on...',
      'open',
      'opening...',
      'unlocked',
      'unlocking...'
    ].contains(stateLower)) {
      return true;
    }

    if (entityId.split('.')[0] == 'climate' && state.toLowerCase() != 'off') {
      return true;
    }
    return false;
  }

  bool get showAsBigButton {
    return entityType == EntityType.cameras;
  }

  String get getOverrideName {
    if (gd.entitiesOverride[entityId] != null &&
        gd.entitiesOverride[entityId].friendlyName != null &&
        gd.entitiesOverride[entityId].friendlyName.length > 0) {
      return gd.entitiesOverride[entityId].friendlyName;
    } else {
      return getFriendlyName;
    }
  }

  String get getFriendlyName {
    if (friendlyName != null) {
      return friendlyName;
    } else if (entityId != null) {
      return entityId;
    } else {
      return "???";
    }
  }

  //https://community.home-assistant.io/t/supported-features/43696
  List<String> supportedFeaturesLightList = [
    "SUPPORT_BRIGHTNESS",
    "SUPPORT_COLOR_TEMP",
    "SUPPORT_EFFECT",
    "SUPPORT_FLASH",
    "SUPPORT_RGB_COLOR",
    "SUPPORT_TRANSITION",
    "SUPPORT_XY_COLOR",
    "SUPPORT_WHITE_VALUE",
  ];
  String get getSupportedFeaturesLights {
    if (supportedFeatures == null) {
      return "";
    }
    var recVal = "";
    var binaryText = supportedFeatures.toRadixString(2);
    int index = 0;
    for (int i = binaryText.length; i > 0; i--) {
      var x = binaryText.substring(i - 1, i);
      if (x == "1") {
        recVal = recVal + supportedFeaturesLightList[index] + " | ";
      }
      index++;
    }
//    print("recVal $recVal");
    return recVal;
  }

  // https://github.com/home-assistant/home-assistant/blob/dev/homeassistant/components/media_player/const.py
  // [media_player.denon_avr_x3000] [state: on] 69004 SUPPORT_VOLUME_SET | SUPPORT_VOLUME_MUTE | SUPPORT_TURN_ON | SUPPORT_TURN_OFF | SUPPORT_VOLUME_STEP | SUPPORT_SELECT_SOURCE | SUPPORT_SELECT_SOUND_MODE |

  //[media_player.apple_tv] [state: unknown] 21427 SUPPORT_PAUSE | SUPPORT_SEEK | SUPPORT_PREVIOUS_TRACK | SUPPORT_NEXT_TRACK | SUPPORT_TURN_ON | SUPPORT_TURN_OFF | SUPPORT_PLAY_MEDIA | SUPPORT_STOP | SUPPORT_PLAY |

  //[media_player.living_room_tv] [state: unavailable] 21389 SUPPORT_PAUSE | SUPPORT_VOLUME_SET | SUPPORT_VOLUME_MUTE | SUPPORT_TURN_ON | SUPPORT_TURN_OFF | SUPPORT_PLAY_MEDIA | SUPPORT_STOP | SUPPORT_PLAY |

  //Available services: turn_on, turn_off, toggle, volume_up, volume_down, volume_set, volume_mute, media_play_pause, media_play, media_pause, media_stop, media_next_track, media_previous_track, clear_playlist, shuffle_set

  List<String> supportedFeaturesMediaPlayerList = [
    "SUPPORT_PAUSE",
    "SUPPORT_SEEK",
    "SUPPORT_VOLUME_SET",
    "SUPPORT_VOLUME_MUTE",
    "SUPPORT_PREVIOUS_TRACK",
    "SUPPORT_NEXT_TRACK",
    "",
    "SUPPORT_TURN_ON",
    "SUPPORT_TURN_OFF",
    "SUPPORT_PLAY_MEDIA",
    "SUPPORT_VOLUME_STEP",
    "SUPPORT_SELECT_SOURCE",
    "SUPPORT_STOP",
    "SUPPORT_CLEAR_PLAYLIST",
    "SUPPORT_PLAY",
    "SUPPORT_SHUFFLE_SET",
    "SUPPORT_SELECT_SOUND_MODE",
  ];
  String get getSupportedFeaturesMediaPlayer {
    if (supportedFeatures == null) {
      return "";
    }
    var recVal = "";
    var binaryText = supportedFeatures.toRadixString(2);
    int index = 0;
    for (int i = binaryText.length; i > 0; i--) {
      var x = binaryText.substring(i - 1, i);
      if (x == "1") {
        recVal = recVal + supportedFeaturesMediaPlayerList[index] + " | ";
      }
      index++;
    }
//    print("recVal $recVal");
    return recVal;
  }

  String get getStateDisplay {
    if (isStateOn && entityId.contains("fan.")) {
      if (speedLevel != null && speedLevel.length > 0 && speedLevel != "null")
        return speedLevel;
      if (speed != null && speed.length > 0 && speed != "null") return speed;
    }
    return state;
  }

  double get getTemperature {
    if (temperature != null) return temperature;
    if (currentTemperature != null) return currentTemperature;
    return 0;
  }
}
