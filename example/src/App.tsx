import { useEffect, useState } from 'react';
import {
  StyleSheet,
  View,
  PermissionsAndroid,
  type Permission,
} from 'react-native';
import { fetch, type NetInfoWifiState } from '@react-native-community/netinfo';
import { TextInput, Button, Text } from 'react-native-paper';

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

const is5G = (frequency: number) => {
  return frequency > 4900 && frequency < 5900;
};

export default function App() {
  const [wifiInfo, setWifiInfo] = useState<NetInfoWifiState>();

  const [apPassword, setApPassword] = useState('');
  const [deviceCount, setDeviceCount] = useState('');
  const [aesKey, setAesKey] = useState('');
  const [customData, setCustomData] = useState('');
  const [hint, setHint] = useState('');
  const [message, setMessage] = useState('');
  const [passwordVisible, setPasswordVisible] = useState(false);
  const [aesKeyVisible, setAesKeyVisible] = useState(false);
  useEffect(() => {
    checkAndRequestPermission()
      .catch(() => {
        setMessage('需要位置权限来获取 Wi-Fi 信息。 \n点击申请权限');
      })
      .finally(() => {
        fetch().then((state) => {
          const tempState = state as NetInfoWifiState;
          setWifiInfo(tempState);
          if (is5G(tempState?.details?.frequency ?? 0)) {
            setHint('当前连接的是 5G Wi-Fi, 请确定您的设备是否支持。');
          }
        });
      });
  }, []);

  const wifiArr = [
    { label: 'SSID', value: wifiInfo?.details?.ssid },
    { label: 'BSSID', value: wifiInfo?.details?.bssid },
    { label: 'IP', value: wifiInfo?.details?.ipAddress },
  ];

  const handleConfirm = () => {
    // 处理确认按钮点击事件
  };

  return (
    <View style={styles.container}>
      {wifiArr.map((item) => (
        <View key={item.label} style={styles.itemBox}>
          <Text style={styles.label}>{item.label}:</Text>
          <Text>{item.value}</Text>
        </View>
      ))}
      <TextInput
        mode="outlined"
        label="WiFi密码"
        value={apPassword}
        onChangeText={setApPassword}
        secureTextEntry={!passwordVisible}
        right={
          <TextInput.Icon
            icon={passwordVisible ? 'eye-off' : 'eye'}
            onPress={() => setPasswordVisible(!passwordVisible)}
          />
        }
        style={styles.input}
      />

      <TextInput
        mode="outlined"
        label="设备数量"
        value={deviceCount}
        onChangeText={setDeviceCount}
        keyboardType="numeric"
        style={styles.input}
      />

      <TextInput
        mode="outlined"
        label="AES密钥"
        value={aesKey}
        onChangeText={setAesKey}
        secureTextEntry={!aesKeyVisible}
        right={
          <TextInput.Icon
            icon={aesKeyVisible ? 'eye-off' : 'eye'}
            onPress={() => setAesKeyVisible(!aesKeyVisible)}
          />
        }
        style={styles.input}
      />

      <TextInput
        mode="outlined"
        label="自定义数据"
        value={customData}
        onChangeText={setCustomData}
        style={styles.input}
      />

      {hint ? <Text style={styles.hintText}>{hint}</Text> : null}

      <View style={styles.messageContainer}>
        <Text>{message}</Text>
      </View>

      <Button mode="contained" onPress={handleConfirm} style={styles.button}>
        确认
      </Button>
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
  input: {},
  hintText: {
    color: 'red',
  },
  messageContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    marginVertical: 16,
  },
  button: {
    marginTop: 16,
    marginBottom: 16,
  },
});
