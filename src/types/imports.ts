export enum DeviceTypeCode {
  Radio = "RADIO",
  ZIAD = "ZIAD",
  MOBILITY = "MOBILITY",
  Other = "OTHER",
}

export type ImportErrorItem = {
  row_number: number;
  serial?: string;
  code: string;
  message: string;
  fields?: Record<string, unknown>;
};

export type ImportDevicesResponse = {
  processed: number;
  inserted: number;
  updated: number;
  marked_removed: number;
  failed: number;
  errors: ImportErrorItem[];
};
