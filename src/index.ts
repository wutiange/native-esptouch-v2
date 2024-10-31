import { NativeModules, Platform, NativeEventEmitter } from 'react-native';
import type { EspProvisioningListenerResult, SyncListenerResult } from './type';

const eventEmitter = new NativeEventEmitter(NativeModules.NativeEsptouchV2);
const LINKING_ERROR =
  `The package '@wutiange/native-esptouch-v2' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const NativeEsptouchV2 = NativeModules.NativeEsptouchV2
  ? NativeModules.NativeEsptouchV2
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

const { EspProvisioningListener, SyncListener } =
  NativeEsptouchV2.getConstants();

export const addEspProvisioningListener = (
  handle: (data: EspProvisioningListenerResult) => void
) => {
  const sub = eventEmitter.addListener(EspProvisioningListener, handle);
  return sub.remove;
};

export const addSyncListener = (handle: (data: SyncListenerResult) => void) => {
  const sub = eventEmitter.addListener(SyncListener, handle);
  return sub.remove;
};

export async function espProvisionerInit() {
  return NativeEsptouchV2.espProvisionerInit();
}

export function stopSync() {
  NativeEsptouchV2.stopSync();
}

export function close() {
  NativeEsptouchV2.close();
}

export async function getEspTouchVersion() {
  return NativeEsptouchV2.getEspTouchVersion();
}

interface EspProvisioningRequest {
  ssid?: string;
  bssid?: string;
  password?: string;
  aesKey?: string;
  customData?: string;
}

export async function startProvisioning(options: EspProvisioningRequest) {
  return NativeEsptouchV2.startProvisioning(options);
}

export function stopProvisioning() {
  NativeEsptouchV2.stopProvisioning();
}

export async function isProvisioning() {
  return NativeEsptouchV2.isProvisioning();
}
