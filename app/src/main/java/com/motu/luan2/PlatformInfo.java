
package com.motu.luan2;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.LineNumberReader;
import java.io.Reader;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Locale;

import com.motu.sdk.ChannelAndroid;

//import com.motu.sdk.ChannelUtils;

import android.R.bool;
import android.app.ActivityManager;
import android.bluetooth.BluetoothAdapter;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.graphics.Point;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.net.wifi.WifiManager;
import android.os.BatteryManager;
import android.os.Build;
import android.os.Environment;
import android.os.PowerManager;
import android.os.PowerManager.WakeLock;
import android.provider.Settings.Secure;
import android.telephony.TelephonyManager;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.WindowManager;


public class PlatformInfo{
 
	private static PlatformInfo platform = null;
	private static WakeLock mWakeLock = null;
	private static boolean preModel=true;
	public static synchronized PlatformInfo PlatformInstance() {
		if(platform != null) {
			return platform;
		}
		if(platform == null) {
			platform = new PlatformInfo() {
			}; 
		}
		return platform;
	}
	
	private static void releaseWakeLock(){
		if(mWakeLock != null) {  
		    mWakeLock.release();  
		    mWakeLock = null;  
		 }
	}
	public static void keepScreenOn(boolean on,boolean dimModel) {
		System.out.println("on ="+on);
		if (on) {
			if (preModel != dimModel) {
				releaseWakeLock();
			}
			preModel = dimModel;
			if(mWakeLock == null) {
				PowerManager powerManager = (PowerManager)AppActivity.getActivity().getSystemService(Context.POWER_SERVICE);
				if (dimModel) {
					mWakeLock = powerManager.newWakeLock(PowerManager.SCREEN_DIM_WAKE_LOCK | PowerManager.ON_AFTER_RELEASE, "luan2");					
				}else {
					mWakeLock = powerManager.newWakeLock(PowerManager.SCREEN_BRIGHT_WAKE_LOCK | PowerManager.ON_AFTER_RELEASE, "luan2");
				}
			}
			System.out.println("on");
			mWakeLock.acquire();  
		}else {
			releaseWakeLock();
		}
	}
	public static boolean hasObbData() {
		return ChannelAndroid.hasObb;
	}
	public static boolean isWifi(){
		ConnectivityManager connManager = (ConnectivityManager)AppActivity.getActivity().getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo mWifi = connManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
		if (mWifi.isConnected()) {
			return true ;
		}
		return false ;
	}
	
	public static String getLocalLanguage(){
		Locale locale = AppActivity.getActivity().getResources().getConfiguration().locale;
        String language = locale.toString();
        return language;
	}
	
	public static String getPackageName(){
		return AppActivity.getActivity().getPackageName();
	}
	
	public static int getBatteryLevel(){
		IntentFilter ifilter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);
		Intent batteryStatus = AppActivity.getActivity().registerReceiver(null, ifilter);
		int status = batteryStatus.getIntExtra(BatteryManager.EXTRA_STATUS, -1);
		boolean isCharging =(status == BatteryManager.BATTERY_STATUS_CHARGING || status == BatteryManager.BATTERY_STATUS_FULL);
		if(isCharging){
			return -1;
		}
		//当前剩余电量
		int level = batteryStatus.getIntExtra(BatteryManager.EXTRA_LEVEL, -1);
		//电量最大值
		int scale = batteryStatus.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
		//电量百分比
		int batteryPct = level*100/scale;
		return batteryPct;
	}
	
	public static int getVersionCode(){
		PackageManager pm = AppActivity.getActivity().getPackageManager();
		PackageInfo pinfo = null;
		try {
			pinfo = pm.getPackageInfo(AppActivity.getActivity().getPackageName(), PackageManager.GET_CONFIGURATIONS);
		} catch (NameNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return pinfo.versionCode;
	}
	public static String getVersionName(){
		PackageManager pm = AppActivity.getActivity().getPackageManager();
		PackageInfo pinfo = null;
		try {
			pinfo = pm.getPackageInfo(AppActivity.getActivity().getPackageName(), PackageManager.GET_CONFIGURATIONS);
		} catch (NameNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return pinfo.versionName;
	}
	public static String getDevice() {
		return android.os.Build.MODEL;
	}
	
	public static String getOSVersion() {
		return android.os.Build.VERSION.RELEASE;
	}
	
	public static int  getSDKNum() {
		return Build.VERSION.SDK_INT;
	}
	// 获得可用的内存
    public static long getMemoryUnused() {
        long men_unused=0;
        ActivityManager am = (ActivityManager) AppActivity.getActivity().getSystemService(Context.ACTIVITY_SERVICE);
        ActivityManager.MemoryInfo mi = new ActivityManager.MemoryInfo();
        am.getMemoryInfo(mi);
        men_unused = mi.availMem / 1024;
        return men_unused;
    }
    
	public static long getMemoryTotal() {
        long mTotal=0;
        // /proc/meminfo读出的内核信息进行解释
        String path = "/proc/meminfo";
        String content = null;
        BufferedReader br = null;
        try {
            br = new BufferedReader(new FileReader(path), 8);
            String line;
            if ((line = br.readLine()) != null) {
                content = line;
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (br != null) {
                try {
                    br.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
        // beginIndex
        int begin = content.indexOf(':');
        // endIndex
        int end = content.indexOf('k');
        // 截取字符串信息
        content = content.substring(begin + 1, end).trim();
        mTotal = Integer.parseInt(content);
        return mTotal;
    }
	public static void openURL(String url) 
	{ 
		try {
			Intent i = new Intent(Intent.ACTION_VIEW);  
			i.setData(Uri.parse(url));
			AppActivity.getActivity().startActivity(i);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			Log.e("openURL", "Exception", e);  
		}
	}
	//The BT MAC Address string 
	public static String getBTMacAddress()
	{
		try {
			BluetoothAdapter m_BluetoothAdapter = null;// Local Bluetooth adapter      
			m_BluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
			String m_szBTMAC = m_BluetoothAdapter.getAddress();
			System.out.println("m_szBTMAC = " + m_szBTMAC);
			return m_szBTMAC;
		} catch (Exception e) {
			// TODO: handle exception
			System.out.println("error at getBTMacAddress");
			return "0";
		}
	}

//Combined Device ID MD5 
	public static String getCombinedDeviceID()
	{
		try {
			String m_szImei = getIMEI();
			String m_szDevIDShort = getUniqueID();
			String m_szAndroidID = getAndroidID();
			String m_szWLANMAC = getWLanMacAddress();
			String m_szBTMAC = getBTMacAddress();
			String m_szLongID = m_szImei + m_szDevIDShort + m_szAndroidID
					+ m_szWLANMAC + m_szBTMAC;// compute md5     
			MessageDigest m = null;
			try {
				m = MessageDigest.getInstance("MD5");
			} catch (NoSuchAlgorithmException e) {
				e.printStackTrace();
			}
			m.update(m_szLongID.getBytes(), 0, m_szLongID.length());// get md5 bytes   
			byte p_md5Data[] = m.digest();// create a hex string   
			String m_szUniqueID = new String();
			for (int i = 0; i < p_md5Data.length; i++) {
				int b = (0xFF & p_md5Data[i]);// if it is a single digit, make sure it have 0 in front (proper padding)    
				if (b <= 0xF)
					m_szUniqueID += "0";// add number to string    
				m_szUniqueID += Integer.toHexString(b);
			}// hex string to uppercase   
			m_szUniqueID = m_szUniqueID.toUpperCase();
			System.out.println("m_szUniqueID = " + m_szUniqueID);
			return m_szUniqueID;
		} catch (Exception e) {
			// TODO: handle exception
			System.out.println("error at getCombinedDeviceID");
			return "0";
		}
	}

	//The IMEI: 
	public static String getIMEI()
	{
		try {
			TelephonyManager TelephonyMgr = (TelephonyManager) AppActivity.getActivity().getSystemService(Context.TELEPHONY_SERVICE);
			String szImei = TelephonyMgr.getDeviceId();
			System.out.println("szImei = " + szImei);
			return szImei;
		} catch (Exception e) {
			// TODO: handle exception
			System.out.println("error at getIMEI");
			return "0";
		}
	}

	//Pseudo-Unique ID, 
	public static String getUniqueID()
	{
		try {
			String m_szDevIDShort = "35"
					+ //we make this look like a valid IMEI 
					Build.BOARD.length() % 10 + Build.BRAND.length() % 10
					+ Build.CPU_ABI.length() % 10 + Build.DEVICE.length() % 10
					+ Build.DISPLAY.length() % 10 + Build.HOST.length() % 10
					+ Build.ID.length() % 10 + Build.MANUFACTURER.length() % 10
					+ Build.MODEL.length() % 10 + Build.PRODUCT.length() % 10
					+ Build.TAGS.length() % 10 + Build.TYPE.length() % 10
					+ Build.USER.length() % 10;//13 digits
			System.out.println("m_szDevIDShort = " + m_szDevIDShort);
			return m_szDevIDShort;
		} catch (Exception e) {
			// TODO: handle exception
			System.out.println("error at getUniqueID");
			return "0";
		}
	}
	//The Android ID
	public static String getAndroidID()
	{
		try {
			String m_szAndroidID = Secure.getString(AppActivity.getActivity().getContentResolver(),
					Secure.ANDROID_ID);
			System.out.println("m_szAndroidID = " + m_szAndroidID);
			return m_szAndroidID;
		} catch (Exception e) {
			// TODO: handle exception
			System.out.println("error at getAndroidID");
			return "0";
		}
	}
	//The WLAN MAC Address string
	public static String getWLanMacAddress()
	{
//		try {
//			WifiManager wifi = (WifiManager) AppActivity.getActivity().getSystemService(Context.WIFI_SERVICE);
//			String macAddress = wifi.getConnectionInfo().getMacAddress();
//			System.out.println("wlan mac address = " + macAddress);
//			return macAddress;
//		} catch (Exception e) {
//			// TODO: handle exception
//			System.out.println("error at getWLanMacAddress");
//			return "0";
//		}
        String str="";  
        String macSerial="";  
        try {  
            Process pp = Runtime.getRuntime().exec(  
                    "cat /sys/class/net/wlan0/address ");  
            InputStreamReader ir = new InputStreamReader(pp.getInputStream());  
            LineNumberReader input = new LineNumberReader(ir);  
  
            for (; null != str;) {  
                str = input.readLine();  
                if (str != null) {  
                    macSerial = str.trim();// 去空格  
                    break;  
                }  
            }  
        } catch (Exception ex) {  
            ex.printStackTrace();  
        }  
        if (macSerial == null || "".equals(macSerial)) {  
            try {  
                return loadFileAsString("/sys/class/net/eth0/address")  
                        .toUpperCase().substring(0, 17);  
            } catch (Exception e) {  
                e.printStackTrace();  
                  
            }  
              
        } 
        System.out.println("macSerial = "+macSerial);
        return macSerial;  
	}
	public static String loadFileAsString(String fileName) throws Exception {  
        FileReader reader = new FileReader(fileName);    
        String text = loadReaderAsString(reader);  
        reader.close();  
        return text;  
    }  
	public static String loadReaderAsString(Reader reader) throws Exception {  
        StringBuilder builder = new StringBuilder();  
        char[] buffer = new char[4096];  
        int readLength = reader.read(buffer);  
        while (readLength >= 0) {  
            builder.append(buffer, 0, readLength);  
            readLength = reader.read(buffer);  
        }  
        return builder.toString();  
    }
	public static String getMacAddress() {
		String macAddress = "";
		try {
			WifiManager wifi = (WifiManager) AppActivity.getActivity().getSystemService(Context.WIFI_SERVICE);
			macAddress = wifi.getConnectionInfo().getMacAddress();

			if(macAddress == null) {
				macAddress = getBTMacAddress();
			}
			
			if (macAddress == null) {
				macAddress = "00:00:00:00:00:00";
			}
			
//			System.out.println("macAddress = " + macAddress);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			Log.e("getMacAddress", "Exception", e); 
		}
		return macAddress;
	}

	public static String getSDCardDir() {
		String path = "";
		try {
			path = Environment.getExternalStorageDirectory().getAbsolutePath() + "/";
		} catch (Exception e) {
			Log.e("getSDCardDir" ,"Exception", e);
		}
		Log.d("getSDCardDir", path);
		return path;
	}
	
	public static float getScaleSize() {
		float scale =1;
		int screenx=0;
		int screeny=0;
		DisplayMetrics metric = new DisplayMetrics();
		WindowManager wm = (WindowManager) AppActivity.getActivity().getSystemService(Context.WINDOW_SERVICE);
		wm.getDefaultDisplay().getMetrics(metric);
		float density = metric.density;
		int width = metric.widthPixels;
		scale = (float)width/(960*density);
		return scale;
	}
	public void onPause() { 
		//keepScreenOn(false);
	}
	public void onResume() { 
		//keepScreenOn(isScreenOn);
	}
	public void onDestroy() { 
		//keepScreenOn(false);
	}

}
