import { useEffect, useState } from 'react';
import {
  StyleSheet,
  View,
  Text,
  PermissionsAndroid,
  type Permission,
} from 'react-native';
import { fetch, type NetInfoWifiState } from '@react-native-community/netinfo';

const checkAndRequestPermission = async () => {
  try {
    const permissions: Permission[] = [
      'android.permission.ACCESS_FINE_LOCATION',
      'android.permission.ACCESS_COARSE_LOCATION',
    ];
    if (!permissions[0]) {
      return;
    }
    const isAgree = await PermissionsAndroid.check(permissions[0]);
    if (isAgree) {
      return;
    }
    const resultObj = await PermissionsAndroid.requestMultiple(permissions);
    console.log(resultObj, '----resultObj---');
  } catch (err) {
    console.warn(err);
  }
};

export default function App() {
  const [wifiInfo, setWifiInfo] = useState<NetInfoWifiState>();
  useEffect(() => {
    checkAndRequestPermission().finally(() => {
      fetch().then((state) => {
        setWifiInfo(state as NetInfoWifiState);
      });
    });
  }, []);

  const wifiArr = [
    { label: 'SSID', value: wifiInfo?.details?.ssid },
    { label: 'BSSID', value: wifiInfo?.details?.bssid },
    { label: 'IP', value: wifiInfo?.details?.ipAddress },
  ];

  return (
    <View style={styles.container}>
      {wifiArr.map((item) => (
        <View key={item.label} style={styles.itemBox}>
          <Text style={styles.label}>{item.label}:</Text>
          <Text>{item.value}</Text>
        </View>
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
    gap: 8,
  },
  itemBox: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  label: {
    marginRight: 8,
    color: '#ff5983',
  },
});
