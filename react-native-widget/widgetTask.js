import { requestWidgetUpdate } from 'react-native-android-widget';
import { ServerWidget } from './ServerWidget';

export async function widgetTask() {
  try {
    // 1. Fetch the live data from your Node.js API that I built into your Next.js app!
    const response = await fetch('https://vanakam.me/api/status');
    const data = await response.json();

    // 2. Push the new data to the Home Screen Widget
    requestWidgetUpdate({
      widgetName: 'ServerStatusWidget',
      renderWidget: () => (
        <ServerWidget
          status={data.server}
          players={data.players}
          admins={data.admins_online}
        />
      ),
    });
  } catch (error) {
    console.error('Widget update failed:', error);
    
    // Fallback: If the fetch fails, show the server as offline
    requestWidgetUpdate({
      widgetName: 'ServerStatusWidget',
      renderWidget: () => <ServerWidget status="offline" players={0} admins={0} />,
    });
  }
}
