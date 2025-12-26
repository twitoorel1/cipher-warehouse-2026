import { DeviceTypeCode } from "../types/imports.js";

export const deviceTypeByMakat: Record<string, DeviceTypeCode> = {
  "319653269": DeviceTypeCode.Radio, // מגן מכלול
  "310902748": DeviceTypeCode.Radio, // מח 710
  "319667169": DeviceTypeCode.Radio, // טל 88
  "310902683": DeviceTypeCode.ZIAD, // מח 721
};

export const makatByDeviceType: Record<DeviceTypeCode, string[]> = {
  [DeviceTypeCode.Radio]: ["319653269", "310902748", "319667169"],
  [DeviceTypeCode.ZIAD]: ["310902683"],
  [DeviceTypeCode.MOBILITY]: [],
  [DeviceTypeCode.Other]: [],
};

/*
device_name: "Radio Model X",
makat: "1234567890",
type: DeviceType.Radio,
*/
