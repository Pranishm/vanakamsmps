import React from 'react';
import { FlexWidget, TextWidget } from 'react-native-android-widget';

export function ServerWidget({ status, players, admins }) {
  const isOnline = status === 'online';

  return (
    <FlexWidget
      style={{
        height: 'match_parent',
        width: 'match_parent',
        backgroundColor: '#121212',
        borderRadius: 16,
        padding: 16,
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'center',
      }}
    >
      <TextWidget
        text="VANAKAM SMP"
        style={{ fontSize: 18, color: '#FFFFFF', fontWeight: 'bold', marginBottom: 8 }}
      />
      
      {/* Status Indicator */}
      <FlexWidget style={{ flexDirection: 'row', alignItems: 'center', marginBottom: 12 }}>
        <FlexWidget
          style={{
            width: 12,
            height: 12,
            borderRadius: 6,
            backgroundColor: isOnline ? '#55FF55' : '#FF5555',
            marginRight: 8,
          }}
        />
        <TextWidget
          text={isOnline ? 'ONLINE' : 'OFFLINE'}
          style={{ fontSize: 14, color: isOnline ? '#55FF55' : '#FF5555', fontWeight: 'bold' }}
        />
      </FlexWidget>

      {/* Live Stats */}
      <TextWidget 
        text={`Players: ${players}`} 
        style={{ fontSize: 15, color: '#E0E0E0', marginBottom: 4 }} 
      />
      <TextWidget 
        text={`Admins: ${admins}`} 
        style={{ fontSize: 15, color: '#AAAAAA' }} 
      />
    </FlexWidget>
  );
}
