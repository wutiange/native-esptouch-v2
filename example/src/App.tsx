import { useEffect } from 'react';
import { StyleSheet, View, Text } from 'react-native';
import { espProvisionerInit } from '@wutiange/native-esptouch-v2';

export default function App() {
  useEffect(() => {
    console.log(espProvisionerInit, '----espProvisionerInit---');
  }, []);

  return (
    <View style={styles.container}>
      <Text>Hello World</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
