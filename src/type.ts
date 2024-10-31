type EspProvisioningResponseAddress = {
  address: string;
  hostName: string;
  canonicalHostName: string;
  hostAddress: string;
  isMulticastAddress: boolean;
  isAnyLocalAddress: boolean;
  isLoopbackAddress: boolean;
  isLinkLocalAddress: boolean;
  isSiteLocalAddress: boolean;
  isMCGlobal: boolean;
  isMCNodeLocal: boolean;
  isMCLinkLocal: boolean;
  isMCSiteLocal: boolean;
  isMCOrgLocal: boolean;
};

type EspProvisioningResponse = {
  address?: EspProvisioningResponseAddress;
  bssid?: string;
};

type EspProvisioningListenerResult = {
  name: 'response' | 'start' | 'stop' | 'error';
  data: null | EspProvisioningResponse;
  err?: string;
};

type SyncListenerResult = {
  name: 'start' | 'stop' | 'error';
  err?: string;
};

export {
  type EspProvisioningListenerResult,
  type SyncListenerResult,
  type EspProvisioningResponse,
  type EspProvisioningResponseAddress,
};
